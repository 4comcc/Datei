import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../services/attachment_store.dart';
import 'backup_crypto.dart';

/// What a backup contains (shown before restoring).
class BackupSummary {
  const BackupSummary({required this.createdAt, required this.appVersion, required this.schemaVersion, required this.counts, required this.fileCount});
  final DateTime createdAt;
  final String appVersion;
  final int schemaVersion;

  /// table name → row count.
  final Map<String, int> counts;
  final int fileCount;

  int count(String table) => counts[table] ?? 0;
}

/// A backup read and verified, ready to restore.
class LoadedBackup {
  const LoadedBackup(this.summary, this._tables, this._files);
  final BackupSummary summary;
  final Map<String, List<Map<String, dynamic>>> _tables;
  final Map<String, List<int>> _files;
}

class BackupNewerVersionException implements Exception {
  const BackupNewerVersionException(this.backupVersion);
  final int backupVersion;
}

/// Full backup/restore of the local database and attachments (ADR-064).
///
/// Archive (zip): `manifest.json` (format, versions, counts, SHA-256 of every
/// entry) · `data.json` (rows per table) · `attachments/…`. Optionally wrapped
/// by [BackupCrypto]. Account/profile tables are not exported; rows are
/// re-owned by the current local profile on restore.
class BackupService {
  BackupService(this._db, this._files, {required this.appVersion});
  final AppDatabase _db;
  final AttachmentStore _files;
  final String appVersion;

  static const format = 'datei-backup';
  static const formatVersion = 1;

  static const _skipTables = {'local_user_profiles', 'account_metadata'};

  /// Device-specific settings that should not travel to another phone.
  static const _skipSettings = {'notifications.enabled', 'notifications.precise'};

  /// Tables in foreign-key order (drift declares them parents-first).
  List<TableInfo<Table, dynamic>> get _tables =>
      [for (final t in _db.allTables) if (!_skipTables.contains(t.actualTableName)) t];

  Future<Uint8List> create({String? password, DateTime? now}) async {
    final tables = <String, List<Map<String, dynamic>>>{};
    for (final t in _tables) {
      final rows = await _db.customSelect('SELECT * FROM "${t.actualTableName}"').get();
      tables[t.actualTableName] = [
        for (final r in rows)
          if (t.actualTableName != 'app_settings' || !_skipSettings.contains(r.data['key'])) r.data,
      ];
    }
    final data = utf8.encode(jsonEncode({'tables': tables}));
    final archive = Archive()..addFile(ArchiveFile.bytes('data.json', data));
    final hashes = <String, String>{'data.json': sha256.convert(data).toString()};

    for (final row in tables['attachments'] ?? const <Map<String, dynamic>>[]) {
      final path = row['relative_path'] as String;
      final file = _files.fileFor(path);
      if (!await file.exists()) continue;
      final bytes = await file.readAsBytes();
      archive.addFile(ArchiveFile.bytes(path, bytes));
      hashes[path] = sha256.convert(bytes).toString();
    }

    final manifest = {
      'format': format,
      'formatVersion': formatVersion,
      'schemaVersion': _db.schemaVersion,
      'appVersion': appVersion,
      'createdAt': (now ?? DateTime.now()).toUtc().toIso8601String(),
      'counts': {for (final e in tables.entries) e.key: e.value.length},
      'sha256': hashes,
    };
    archive.addFile(ArchiveFile.bytes('manifest.json', utf8.encode(jsonEncode(manifest))));
    final zip = Uint8List.fromList(ZipEncoder().encode(archive));
    return password == null || password.isEmpty ? zip : BackupCrypto.encrypt(zip, password);
  }

  /// Reads and verifies a backup. Throws [BackupPasswordException] (wrong/missing
  /// password), [BackupFormatException] (not a Datei backup / damaged) or
  /// [BackupNewerVersionException].
  Future<LoadedBackup> load(Uint8List bytes, {String? password}) async {
    var zipBytes = bytes;
    if (BackupCrypto.isEncrypted(bytes)) {
      if (password == null || password.isEmpty) throw const BackupPasswordException();
      zipBytes = await BackupCrypto.decrypt(bytes, password);
    }
    final Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(zipBytes, verify: true);
    } catch (_) {
      throw const BackupFormatException('not a zip');
    }
    List<int> read(String name) {
      final f = archive.findFile(name);
      if (f == null) throw BackupFormatException('missing $name');
      try {
        return f.content; // decompressed lazily; damaged data throws here
      } catch (_) {
        throw BackupFormatException('damaged $name');
      }
    }

    final Map<String, dynamic> manifest;
    try {
      manifest = jsonDecode(utf8.decode(read('manifest.json'))) as Map<String, dynamic>;
    } on FormatException {
      throw const BackupFormatException('bad manifest');
    }
    if (manifest['format'] != format) throw const BackupFormatException('not a Datei backup');
    final schema = manifest['schemaVersion'] as int? ?? 0;
    if (schema > _db.schemaVersion || (manifest['formatVersion'] as int? ?? 0) > formatVersion) {
      throw BackupNewerVersionException(schema);
    }
    final hashes = (manifest['sha256'] as Map<String, dynamic>? ?? const {}).cast<String, String>();
    final files = <String, List<int>>{};
    for (final e in hashes.entries) {
      // Only `data.json` and files inside `attachments/` (no path tricks) are accepted.
      final safe = e.key == 'data.json' ||
          (e.key.startsWith('attachments/') && !e.key.contains('..') && !e.key.contains(r'\'));
      if (!safe) throw BackupFormatException('unexpected entry ${e.key}');
      final content = read(e.key);
      if (sha256.convert(content).toString() != e.value) throw BackupFormatException('checksum ${e.key}');
      if (e.key != 'data.json') files[e.key] = content;
    }
    final Map<String, List<Map<String, dynamic>>> tables;
    try {
      final data = jsonDecode(utf8.decode(read('data.json'))) as Map<String, dynamic>;
      tables = {
        for (final e in (data['tables'] as Map<String, dynamic>).entries)
          e.key: (e.value as List<dynamic>).cast<Map<String, dynamic>>(),
      };
    } on BackupFormatException {
      rethrow;
    } catch (_) {
      throw const BackupFormatException('bad data');
    }
    final createdAt = DateTime.tryParse(manifest['createdAt'] as String? ?? '');
    if (createdAt == null) throw const BackupFormatException('bad manifest');
    return LoadedBackup(
      BackupSummary(
        createdAt: createdAt.toLocal(),
        appVersion: manifest['appVersion'] as String? ?? '?',
        schemaVersion: schema,
        counts: {for (final e in tables.entries) e.key: e.value.length},
        fileCount: files.length,
      ),
      tables,
      files,
    );
  }

  /// Replaces all local data with the backup in one transaction, then swaps the
  /// attachment files. Nothing changes if the database part fails.
  Future<void> restore(LoadedBackup backup, {required String profileId}) async {
    final known = {for (final t in _tables) t.actualTableName: t};
    await _db.transaction(() async {
      for (final t in _tables.reversed) {
        if (t.actualTableName == 'app_settings') {
          // Keep this device's own settings (reminders permission state etc.).
          final keep = _skipSettings.map((k) => "'$k'").join(', ');
          await _db.customStatement('DELETE FROM app_settings WHERE key NOT IN ($keep)');
        } else {
          await _db.customStatement('DELETE FROM "${t.actualTableName}"');
        }
      }
      for (final t in _tables) {
        final rows = backup._tables[t.actualTableName];
        if (rows == null) continue;
        final columns = {for (final c in known[t.actualTableName]!.$columns) c.name};
        for (final row in rows) {
          final r = {
            for (final e in row.entries)
              if (columns.contains(e.key)) e.key: e.key == 'owner_profile_id' ? profileId : e.value,
          };
          if (r.isEmpty) continue;
          if (t.actualTableName == 'app_settings' && _skipSettings.contains(r['key'])) continue;
          final names = r.keys.map((k) => '"$k"').join(', ');
          final marks = List.filled(r.length, '?').join(', ');
          await _db.customStatement(
            'INSERT OR REPLACE INTO "${t.actualTableName}" ($names) VALUES ($marks)',
            r.values.toList(),
          );
        }
      }
    });
    // Raw statements don't notify Drift's stream queries; tell open screens to re-read.
    _db.markTablesUpdated(_tables);
    await _files.deleteAll();
    for (final e in backup._files.entries) {
      final f = _files.fileFor(e.key);
      await f.parent.create(recursive: true);
      await f.writeAsBytes(e.value, flush: true);
    }
  }

  /// Writes an automatic copy of the current data before a restore.
  Future<File> writeSafetyCopy(Directory dir, {DateTime? now}) async {
    final ts = (now ?? DateTime.now()).toIso8601String().replaceAll(':', '-').split('.').first;
    final file = File('${dir.path}/backups/before-restore-$ts.datei');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(await create(now: now), flush: true);
    return file;
  }
}
