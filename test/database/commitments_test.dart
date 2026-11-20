import 'package:datei/app/bootstrap.dart';
import 'package:datei/core/database/app_database.dart';
import 'package:datei/core/time_engine/local_date.dart';
import 'package:datei/features/commitments/data/drift_commitments_repository.dart';
import 'package:datei/features/commitments/domain/commitment.dart';
import 'package:datei/features/events/data/drift_events_repository.dart';
import 'package:datei/features/events/domain/event.dart';
import 'package:datei/features/settings/data/drift_settings_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  late AppDatabase db;
  late DriftCommitmentsRepository repo;
  late String profile;
  LocalDate d(String s) => LocalDate.parse(s);

  Commitment c({String id = 'c', String typeId = 'sys:commitment_type:domain', List<int> days = const [30, 7, 0]}) => Commitment(
        id: id,
        name: ' example.com ',
        typeId: typeId,
        providerName: 'Registrar',
        expiryDate: d('2027-01-10'),
        renewalDate: d('2026-12-31'),
        amountMinor: 125050,
        currency: 'egp',
        renewalMonths: 12,
        referenceNumber: 'INV-42',
        reminderDays: days,
        createdAt: DateTime(2026),
      );

  setUp(() async {
    db = openTestDatabase();
    profile = await ensureLocalProfile(db);
    repo = DriftCommitmentsRepository(db, profile);
  });
  tearDown(() => db.close());

  test('system commitment types are seeded', () async {
    expect(await db.select(db.commitmentTypes).get(), hasLength(15));
  });

  test('save → watch roundtrip with reminders, trimmed name, upper-case currency', () async {
    await repo.save(c());
    final x = (await repo.watchAll().first).single;
    expect(x.name, 'example.com');
    expect(x.currency, 'EGP');
    expect(x.amountMinor, 125050);
    expect(x.reminderDays, [30, 7, 0]);
    expect(x.dueDate, d('2026-12-31'));
  });

  test('unknown type falls back to Other; expiry before start is rejected', () async {
    await repo.save(c(typeId: 'nope'));
    expect((await repo.watchAll().first).single.typeId, CommitmentType.other.id);
    expect(
      () => repo.save(Commitment(
        id: 'bad', name: 'x', typeId: CommitmentType.bill.id,
        startDate: d('2026-12-01'), expiryDate: d('2026-11-01'), createdAt: DateTime(2026),
      )),
      throwsArgumentError,
    );
  });

  test('renew records history, moves dates, and rejects non-later dates', () async {
    await repo.save(c());
    await repo.renew('c', newExpiry: d('2028-01-10'), amountMinor: 130000, notes: 'Paid online');
    final x = (await repo.watchAll().first).single;
    expect(x.expiryDate, d('2028-01-10'));
    expect(x.renewalDate, d('2027-12-31'));
    final history = await repo.watchRenewals('c').first;
    expect(history.single.previousExpiry, d('2027-01-10'));
    expect(history.single.amountMinor, 130000);
    expect(history.single.currency, 'EGP');
    expect(() => repo.renew('c', newExpiry: d('2028-01-10')), throwsArgumentError);
  });

  test('delete hides the commitment and removes its reminders', () async {
    await repo.save(c());
    await repo.delete('c');
    expect(await repo.watchAll().first, isEmpty);
    expect(await db.select(db.reminders).get(), isEmpty);
  });

  test('event reminders roundtrip and are replaced on save', () async {
    final events = DriftEventsRepository(db, profile);
    final e = DateiEvent(
      id: 'e', title: 'Call', typeId: EventType.appointment.id, date: d('2026-12-01'), time: '10:00',
      reminderMinutes: const [60, 0, 1440], createdAt: DateTime(2026),
    );
    await events.save(e);
    expect((await events.watchAll().first).single.reminderMinutes, [0, 60, 1440]);
    await events.save(DateiEvent(
      id: 'e', title: 'Call', typeId: EventType.appointment.id, date: d('2026-12-01'), createdAt: DateTime(2026),
    ));
    expect((await events.watchAll().first).single.reminderMinutes, isEmpty);
  });

  test('erase all removes commitments, renewals and reminders', () async {
    await repo.save(c());
    await repo.renew('c', newExpiry: d('2028-01-10'));
    await DriftDataMaintenanceRepository(db).eraseAllUserData();
    expect(await db.select(db.commitments).get(), isEmpty);
    expect(await db.select(db.commitmentRenewals).get(), isEmpty);
    expect(await db.select(db.reminders).get(), isEmpty);
    expect(await db.select(db.commitmentTypes).get(), hasLength(15));
  });
}
