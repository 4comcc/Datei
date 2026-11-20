import 'dart:io';

import 'package:datei/app/bootstrap.dart';
import 'package:datei/core/database/app_database.dart';
import 'package:datei/core/services/attachment_store.dart';
import 'package:datei/core/time_engine/local_date.dart';
import 'package:datei/features/events/data/drift_events_repository.dart';
import 'package:datei/features/events/domain/event.dart';
import 'package:datei/features/memories/data/drift_memories_repository.dart';
import 'package:datei/features/memories/domain/memory.dart';
import 'package:datei/features/milestones/data/drift_milestones_repository.dart';
import 'package:datei/features/milestones/domain/milestone.dart';
import 'package:datei/features/people/data/drift_people_repository.dart';
import 'package:datei/features/people/domain/person.dart';
import 'package:datei/features/projects/data/drift_projects_repository.dart';
import 'package:datei/features/projects/domain/project.dart';
import 'package:datei/features/settings/data/drift_settings_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  late AppDatabase db;
  late Directory root;
  late LocalAttachmentStore store;
  late DriftMemoriesRepository memories;
  late DriftMilestonesRepository milestones;
  late DriftProjectsRepository projects;
  late DriftPeopleRepository people;
  late DriftEventsRepository events;
  final created = DateTime(2026);
  LocalDate d(String s) => LocalDate.parse(s);

  Future<MemoryPhoto> photo(String name) async {
    final src = File('${root.path}/$name.jpg')..writeAsBytesSync(List.filled(64, 7));
    final stored = await store.importFile(src.path);
    return MemoryPhoto(id: name, relativePath: stored.relativePath, mimeType: stored.mimeType, sizeBytes: stored.sizeBytes);
  }

  setUp(() async {
    db = openTestDatabase();
    root = Directory.systemTemp.createTempSync('datei_att_');
    store = LocalAttachmentStore(root.path);
    final profile = await ensureLocalProfile(db);
    memories = DriftMemoriesRepository(db, profile, store);
    milestones = DriftMilestonesRepository(db, profile);
    projects = DriftProjectsRepository(db, profile);
    people = DriftPeopleRepository(db, profile);
    events = DriftEventsRepository(db, profile);
    await people.save(Person(id: 'a', fullName: 'A', createdAt: created));
    await events.save(DateiEvent(id: 'e', title: 'E', typeId: EventType.family.id, date: d('2020-01-01'), createdAt: created));
  });
  tearDown(() async {
    await db.close();
    if (root.existsSync()) root.deleteSync(recursive: true);
  });

  test('attachment store: import copies into attachments/, rejects path traversal', () async {
    final p = await photo('x');
    expect(p.relativePath, startsWith('attachments/'));
    expect(p.mimeType, 'image/jpeg');
    expect(store.fileFor(p.relativePath).existsSync(), isTrue);
    expect(() => store.fileFor('../etc/passwd'), throwsArgumentError);
  });

  test('memory roundtrip with people, event, case-insensitive tags and ordered photos', () async {
    final p1 = await photo('p1');
    final p2 = await photo('p2');
    await memories.save(Memory(
      id: 'm', title: ' Trip ', date: d('2019-07-01'), eventId: 'e', personIds: const ['a', 'ghost'],
      tags: const ['Family', 'family', ' summer '], photos: [p1, p2], createdAt: created,
    ));
    final m = (await memories.watchAll().first).single;
    expect(m.title, 'Trip');
    expect(m.personIds, ['a']);
    expect(m.eventId, 'e');
    expect(m.tags, ['Family', 'summer']);
    expect(m.photos.map((x) => x.id), ['p1', 'p2']);
    expect(await memories.watchTagNames().first, ['Family', 'summer']);
  });

  test('removing a photo deletes its file; deleting the memory deletes all files and unused tags', () async {
    final p1 = await photo('p1');
    final p2 = await photo('p2');
    await memories.save(Memory(id: 'm', title: 'T', date: d('2019-07-01'), tags: const ['x'], photos: [p1, p2], createdAt: created));
    await memories.save(Memory(id: 'm', title: 'T', date: d('2019-07-01'), tags: const ['x'], photos: [p2], createdAt: created));
    expect(store.fileFor(p1.relativePath).existsSync(), isFalse);
    expect(store.fileFor(p2.relativePath).existsSync(), isTrue);

    await memories.delete('m');
    expect(await memories.watchAll().first, isEmpty);
    expect(store.fileFor(p2.relativePath).existsSync(), isFalse);
    expect(await memories.watchTagNames().first, isEmpty);
  });

  test('deleting a person or event unlinks memories, milestones and projects', () async {
    await memories.save(Memory(id: 'm', title: 'T', date: d('2019-07-01'), eventId: 'e', personIds: const ['a'], createdAt: created));
    await milestones.save(Milestone(id: 'g', title: 'G', date: d('2019-01-01'), personId: 'a', eventId: 'e', createdAt: created));
    await projects.save(Project(id: 'p', name: 'P', personIds: const ['a'], eventIds: const ['e'], createdAt: created));
    await people.delete('a');
    await events.delete('e');
    final m = (await memories.watchAll().first).single;
    expect(m.personIds, isEmpty);
    expect(m.eventId, isNull);
    final g = (await milestones.watchAll().first).single;
    expect(g.personId, isNull);
    expect(g.eventId, isNull);
    final p = (await projects.watchAll().first).single;
    expect(p.personIds, isEmpty);
    expect(p.eventIds, isEmpty);
  });

  test('milestone references to missing items are dropped; deleting a project unlinks milestones', () async {
    await projects.save(Project(id: 'p', name: 'P', createdAt: created));
    await milestones.save(Milestone(id: 'g', title: 'G', date: d('2019-01-01'), personId: 'nope', projectId: 'p', createdAt: created));
    expect((await milestones.watchAll().first).single.personId, isNull);
    expect((await milestones.watchAll().first).single.projectId, 'p');
    await projects.delete('p');
    expect((await milestones.watchAll().first).single.projectId, isNull);
  });

  test('projects: due before start rejected; open projects sorted before finished ones', () async {
    expect(
      () => projects.save(Project(id: 'bad', name: 'B', startDate: d('2026-02-01'), dueDate: d('2026-01-01'), createdAt: created)),
      throwsArgumentError,
    );
    await projects.save(Project(id: 'done', name: 'Done', status: ProjectStatus.done, dueDate: d('2026-01-01'), createdAt: created));
    await projects.save(Project(id: 'open', name: 'Open', dueDate: d('2027-01-01'), createdAt: created));
    expect((await projects.watchAll().first).map((p) => p.id), ['open', 'done']);
    expect(Project(id: 'z', name: 'Z', dueDate: d('2026-01-01'), createdAt: created).isOverdue(d('2026-11-20')), isTrue);
  });

  test('erase all removes memories, milestones, projects, tags and photo files', () async {
    final p1 = await photo('p1');
    await memories.save(Memory(id: 'm', title: 'T', date: d('2019-07-01'), tags: const ['x'], photos: [p1], createdAt: created));
    await milestones.save(Milestone(id: 'g', title: 'G', date: d('2019-01-01'), createdAt: created));
    await projects.save(Project(id: 'p', name: 'P', createdAt: created));
    await DriftDataMaintenanceRepository(db, store).eraseAllUserData();
    expect(await db.select(db.memories).get(), isEmpty);
    expect(await db.select(db.milestones).get(), isEmpty);
    expect(await db.select(db.projects).get(), isEmpty);
    expect(await db.select(db.tags).get(), isEmpty);
    expect(await db.select(db.attachments).get(), isEmpty);
    expect(Directory('${root.path}/attachments').existsSync(), isFalse);
  });
}
