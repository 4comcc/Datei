import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../app/app_info.dart';
import '../../core/backup/backup_crypto.dart';
import '../../core/backup/backup_service.dart';
import '../../core/database/database_providers.dart';
import '../security/app_lock.dart';
import '../settings/settings_controller.dart';

/// System "save as" / "open" dialogs for backup files.
abstract interface class BackupFiles {
  /// Returns false when the user cancels.
  Future<bool> save(String fileName, Uint8List bytes);

  /// Returns null when the user cancels.
  Future<Uint8List?> pick();
}

class DeviceBackupFiles implements BackupFiles {
  const DeviceBackupFiles();

  @override
  Future<bool> save(String fileName, Uint8List bytes) async =>
      await FilePicker.saveFile(fileName: fileName, bytes: bytes) != null;

  @override
  Future<Uint8List?> pick() async => (await FilePicker.pickFile())?.readAsBytes();
}

final backupFilesProvider = Provider<BackupFiles>((ref) => const DeviceBackupFiles());

/// Private app folder that holds the automatic safety copies.
final backupSafetyDirProvider = Provider<Future<Directory> Function()>((ref) => getApplicationDocumentsDirectory);

final backupServiceProvider = Provider<BackupService>(
  (ref) => BackupService(ref.watch(appDatabaseProvider), ref.watch(attachmentStoreProvider), appVersion: appVersion),
);

final backupControllerProvider = Provider<BackupController>(BackupController.new);

/// Use cases behind the backup screen (ADR-064).
class BackupController {
  BackupController(this._ref);
  final Ref _ref;

  static const minPasswordLength = 6;
  static const keepSafetyCopies = 2;

  BackupService get _service => _ref.read(backupServiceProvider);
  AppLockController get _lock => _ref.read(appLockProvider.notifier);

  static String fileNameFor(DateTime t) {
    String two(int n) => n.toString().padLeft(2, '0');
    return 'datei-backup-${t.year}-${two(t.month)}-${two(t.day)}-${two(t.hour)}${two(t.minute)}.datei';
  }

  /// Creates a backup and lets the user choose where to save it. False = cancelled.
  Future<bool> createAndSave({String? password, DateTime? now}) async {
    final t = now ?? DateTime.now();
    final bytes = await _service.create(password: password, now: t);
    return _lock.whileExternal(() => _ref.read(backupFilesProvider).save(fileNameFor(t), bytes));
  }

  Future<Uint8List?> pickFile() => _lock.whileExternal(() => _ref.read(backupFilesProvider).pick());

  bool isEncrypted(Uint8List bytes) => BackupCrypto.isEncrypted(bytes);

  /// Verifies a backup; see [BackupService.load] for the exceptions.
  Future<LoadedBackup> load(Uint8List bytes, {String? password}) => _service.load(bytes, password: password);

  Future<Directory> _safetyDir() async => Directory('${(await _ref.read(backupSafetyDirProvider)()).path}/backups');

  /// The newest automatic copy made before a restore, if any.
  Future<File?> latestSafetyCopy() async {
    final copies = await _safetyCopies();
    return copies.isEmpty ? null : copies.first;
  }

  Future<List<File>> _safetyCopies() async {
    final dir = await _safetyDir();
    if (!await dir.exists()) return [];
    final files = [
      await for (final f in dir.list())
        if (f is File && f.path.endsWith('.datei') && f.uri.pathSegments.last.startsWith('before-restore-')) f,
    ]..sort((a, b) => b.path.compareTo(a.path)); // names carry a sortable timestamp
    return files;
  }

  /// Saves a safety copy of the current data, replaces it with [backup] and
  /// reloads settings. Older safety copies beyond [keepSafetyCopies] are removed.
  Future<void> restore(LoadedBackup backup, {DateTime? now}) async {
    final root = await _ref.read(backupSafetyDirProvider)();
    await _service.writeSafetyCopy(root, now: now);
    await _service.restore(backup, profileId: _ref.read(currentProfileIdProvider));
    await _ref.read(settingsProvider.notifier).reload();
    final copies = await _safetyCopies();
    for (final old in copies.skip(keepSafetyCopies)) {
      await old.delete();
    }
  }
}
