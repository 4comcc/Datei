import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'package:datei/app/bootstrap.dart';
import 'package:datei/core/backup/backup_crypto.dart';
import 'package:datei/core/backup/backup_service.dart';
import 'package:datei/core/database/app_database.dart';
import 'package:datei/core/recurrence_engine/recurrence.dart';
import 'package:datei/core/services/attachment_store.dart';
import 'package:datei/core/time_engine/local_date.dart';
import 'package:datei/features/events/data/drift_events_repository.dart';
import 'package:datei/features/events/domain/event.dart';
import 'package:datei/features/memories/data/drift_memories_repository.dart';
import 'package:datei/features/memories/domain/memory.dart';
import 'package:datei/features/people/data/drift_people_repository.dart';
import 'package:datei/features/people/domain/person.dart';
import 'package:datei/features/settings/data/drift_settings_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  late AppDatabase db;
  late Directory root;
  late LocalAttachmentStore store;
  late BackupService backups;
  late String profile;
  final created = DateTime(2026);

  Future<void> seed() async {
    await DriftPeopleRepository(db, profile)
        .save(Person(id: 'p', fullName: 'سارة', birthDate: LocalDate.parse('1996-11-24'), categoryIds: const ['sys:category:family'], createdAt: created));
    await DriftEventsRepository(db, profile).save(DateiEvent(
      id: 'e', title: 'Weekly', typeId: EventType.personal.id, date: LocalDate.parse('2026-01-05'),
      recurrence: const RecurrenceRule(frequency: RecurrenceFrequency.weekly), personIds: const ['p'],
      reminderMinutes: const [60], createdAt: created,
    ));
    await DriftEventsRepository(db, profile).cancelOccurrence('e', LocalDate.parse('2026-01-12'));
    final src = File('${root.path}/src.jpg')..writeAsBytesSync(List.generate(500, (i) => i % 256));
    final stored = await store.importFile(src.path);
    await DriftMemoriesRepository(db, profile, store).save(Memory(
      id: 'm', title: 'Photo memory', date: LocalDate.parse('2020-01-01'), tags: const ['x'],
      photos: [MemoryPhoto(id: 'ph', relativePath: stored.relativePath, mimeType: stored.mimeType, sizeBytes: stored.sizeBytes)],
      createdAt: created,
    ));
    final settings = DriftSettingsRepository(db);
    await settings.set('general.language', 'ar');
    await settings.set('notifications.enabled', 'true');
  }

  setUp(() async {
    db = openTestDatabase();
    root = Directory.systemTemp.createTempSync('datei_backup_');
    store = LocalAttachmentStore(root.path);
    profile = await ensureLocalProfile(db);
    backups = BackupService(db, store, appVersion: '0.9.0');
  });
  tearDown(() async {
    await db.close();
    if (root.existsSync()) root.deleteSync(recursive: true);
  });

  Future<Map<String, int>> counts() async => {
        for (final t in ['persons', 'events', 'recurrence_rules', 'event_exceptions', 'event_person_relations', 'reminders', 'memories', 'tags', 'attachments', 'person_category_relations'])
          t: (await db.customSelect('SELECT COUNT(*) AS c FROM $t').getSingle()).read<int>('c'),
      };

  test('backup → erase → restore brings back every row and photo; device settings are not carried', () async {
    await seed();
    final before = await counts();
    final bytes = await backups.create();

    await DriftDataMaintenanceRepository(db, store).eraseAllUserData();
    await DriftSettingsRepository(db).set('notifications.enabled', 'false');
    expect((await counts())['persons'], 0);

    final loaded = await backups.load(bytes);
    expect(loaded.summary.count('persons'), 1);
    expect(loaded.summary.fileCount, 1);
    await backups.restore(loaded, profileId: profile);

    expect(await counts(), before);
    final photo = (await db.select(db.attachments).getSingle()).relativePath;
    expect(store.fileFor(photo).readAsBytesSync(), List.generate(500, (i) => i % 256));
    final settings = await DriftSettingsRepository(db).loadAll();
    expect(settings['general.language'], 'ar');
    expect(settings['notifications.enabled'], 'false'); // device-specific: kept from this device
  });

  test('rows are re-owned by the restoring device profile', () async {
    await seed();
    final bytes = await backups.create();
    final other = openTestDatabase();
    addTearDown(other.close);
    final otherProfile = await ensureLocalProfile(other);
    final otherBackups = BackupService(other, LocalAttachmentStore(Directory.systemTemp.createTempSync('datei_b2_').path), appVersion: '0.9.0');
    await otherBackups.restore(await otherBackups.load(bytes), profileId: otherProfile);
    expect((await other.select(other.persons).getSingle()).ownerProfileId, otherProfile);
  });

  test('password-protected backups: right password restores, wrong or missing password fails', () async {
    await seed();
    final bytes = await backups.create(password: 'correct horse');
    expect(BackupCrypto.isEncrypted(bytes), isTrue);
    expect(() => backups.load(bytes), throwsA(isA<BackupPasswordException>()));
    expect(() => backups.load(bytes, password: 'wrong'), throwsA(isA<BackupPasswordException>()));
    final loaded = await backups.load(bytes, password: 'correct horse');
    expect(loaded.summary.count('memories'), 1);
  });

  test('damaged, foreign and newer backups are rejected', () async {
    await seed();
    final bytes = await backups.create();
    // Flip a byte inside data.json content → checksum mismatch or zip error.
    final damaged = Uint8List.fromList(bytes)..[bytes.length ~/ 3] ^= 0xFF;
    expect(() => backups.load(damaged), throwsA(isA<BackupFormatException>()));
    expect(() => backups.load(Uint8List.fromList(utf8.encode('hello'))), throwsA(isA<BackupFormatException>()));

    final archive = ZipDecoder().decodeBytes(bytes);
    final manifest = jsonDecode(utf8.decode(archive.findFile('manifest.json')!.content)) as Map<String, dynamic>;
    manifest['schemaVersion'] = db.schemaVersion + 1;
    final newer = Archive();
    for (final f in archive.files) {
      newer.addFile(f.name == 'manifest.json' ? ArchiveFile.bytes('manifest.json', utf8.encode(jsonEncode(manifest))) : f);
    }
    expect(() => backups.load(Uint8List.fromList(ZipEncoder().encode(newer))), throwsA(isA<BackupNewerVersionException>()));
  });

  test('a restore that fails midway leaves existing data and photos untouched', () async {
    await seed();
    final good = await backups.create();
    // Craft a backup whose data violates a foreign key (link to a missing person).
    final archive = ZipDecoder().decodeBytes(good);
    final data = jsonDecode(utf8.decode(archive.findFile('data.json')!.content)) as Map<String, dynamic>;
    ((data['tables'] as Map<String, dynamic>)['event_person_relations'] as List<dynamic>)
        .add({'event_id': 'e', 'person_id': 'ghost', 'role': null});
    final dataBytes = utf8.encode(jsonEncode(data));
    final manifest = jsonDecode(utf8.decode(archive.findFile('manifest.json')!.content)) as Map<String, dynamic>;
    (manifest['sha256'] as Map<String, dynamic>)['data.json'] = sha256OfForTest(dataBytes);
    final broken = Archive();
    for (final f in archive.files) {
      broken.addFile(switch (f.name) {
        'data.json' => ArchiveFile.bytes('data.json', dataBytes),
        'manifest.json' => ArchiveFile.bytes('manifest.json', utf8.encode(jsonEncode(manifest))),
        _ => f,
      });
    }
    final loaded = await backups.load(Uint8List.fromList(ZipEncoder().encode(broken)));

    final before = await counts();
    final photo = (await db.select(db.attachments).getSingle()).relativePath;
    await expectLater(backups.restore(loaded, profileId: profile), throwsA(anything));
    expect(await counts(), before);
    expect(store.fileFor(photo).existsSync(), isTrue);
  });

  test('entries outside attachments/ are rejected before anything is written', () async {
    await seed();
    final archive = ZipDecoder().decodeBytes(await backups.create());
    final manifest = jsonDecode(utf8.decode(archive.findFile('manifest.json')!.content)) as Map<String, dynamic>;
    final evil = utf8.encode('x');
    for (final name in ['attachments/../../evil.txt', 'other/evil.txt', r'attachments\..\evil.txt']) {
      final m = jsonDecode(jsonEncode(manifest)) as Map<String, dynamic>;
      (m['sha256'] as Map<String, dynamic>)[name] = sha256OfForTest(evil);
      final crafted = Archive();
      for (final f in archive.files) {
        crafted.addFile(f.name == 'manifest.json' ? ArchiveFile.bytes('manifest.json', utf8.encode(jsonEncode(m))) : f);
      }
      crafted.addFile(ArchiveFile.bytes(name, evil));
      await expectLater(backups.load(Uint8List.fromList(ZipEncoder().encode(crafted))), throwsA(isA<BackupFormatException>()),
          reason: name);
    }
  });

  test('open screens see restored data (stream queries are notified)', () async {
    await seed();
    final bytes = await backups.create();
    final seen = <int>[];
    final sub = db.select(db.persons).watch().listen((rows) => seen.add(rows.length));
    addTearDown(sub.cancel);
    await pumpEventQueue();
    await db.delete(db.persons).go();
    await pumpEventQueue();
    await backups.restore(await backups.load(bytes), profileId: profile);
    await pumpEventQueue();
    expect(seen.last, 1);
  });

  test('safety copy is written before restoring', () async {
    await seed();
    final f = await backups.writeSafetyCopy(root, now: DateTime(2026, 11, 20, 10, 30));
    expect(f.path, endsWith('backups/before-restore-2026-11-20T10-30-00.datei'));
    expect((await backups.load(await f.readAsBytes())).summary.count('persons'), 1);
  });
}

String sha256OfForTest(List<int> bytes) => crypto.sha256.convert(bytes).toString();
