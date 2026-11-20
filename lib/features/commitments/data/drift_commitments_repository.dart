import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_providers.dart';
import '../../../core/time_engine/local_date.dart';
import '../domain/commitment.dart';
import '../domain/commitments_repository.dart';

class DriftCommitmentsRepository implements CommitmentsRepository {
  DriftCommitmentsRepository(this._db, this._profileId);
  final AppDatabase _db;
  final String _profileId;
  static const _rules = CommitmentRules();

  static const _sql = '''
SELECT c.*,
  (SELECT group_concat(r.offset_minutes) FROM reminders r
    WHERE r.owner_type = 'commitment' AND r.owner_id = c.id) AS reminder_minutes
FROM commitments c
WHERE c.deleted_at IS NULL
ORDER BY COALESCE(c.renewal_date, c.expiry_date)
''';

  @override
  Stream<List<Commitment>> watchAll() => _db
      .customSelect(_sql, readsFrom: {_db.commitments, _db.reminders})
      .watch()
      .asyncMap((rows) async => [
            for (final row in rows) _toDomain(await _db.commitments.mapFromRow(row), row.readNullable<String>('reminder_minutes')),
          ]);

  Commitment _toDomain(CommitmentRow r, String? minutes) => Commitment(
        id: r.id,
        name: r.name,
        typeId: r.commitmentTypeId,
        providerName: r.providerName,
        startDate: r.startDate == null ? null : LocalDate.parse(r.startDate!),
        expiryDate: LocalDate.parse(r.expiryDate),
        renewalDate: r.renewalDate == null ? null : LocalDate.parse(r.renewalDate!),
        amountMinor: r.amountMinor,
        currency: r.currency,
        renewalMonths: r.renewalMonths,
        referenceNumber: r.referenceNumber,
        serviceUrl: r.serviceUrl,
        notes: r.notes,
        lifecycle: CommitmentLifecycle.values.asNameMap()[r.lifecycleStatus] ?? CommitmentLifecycle.active,
        reminderDays: [
          for (final m in (minutes ?? '').split(','))
            if (int.tryParse(m) case final n?) n ~/ 1440,
        ]..sort((a, b) => b.compareTo(a)),
        createdAt: DateTime.fromMillisecondsSinceEpoch(r.createdAt, isUtc: true).toLocal(),
      );

  @override
  Stream<List<CommitmentRenewal>> watchRenewals(String commitmentId) => (_db.select(_db.commitmentRenewals)
        ..where((t) => t.commitmentId.equals(commitmentId))
        ..orderBy([(t) => OrderingTerm.desc(t.renewedAt)]))
      .watch()
      .map((rows) => [
            for (final r in rows)
              CommitmentRenewal(
                id: r.id,
                renewedAt: DateTime.fromMillisecondsSinceEpoch(r.renewedAt, isUtc: true).toLocal(),
                previousExpiry: LocalDate.parse(r.previousExpiryDate),
                newExpiry: LocalDate.parse(r.newExpiryDate),
                amountMinor: r.amountMinor,
                currency: r.currency,
                notes: r.notes,
              ),
          ]);

  @override
  Future<void> save(Commitment c) => _db.transaction(() => _save(c));

  Future<void> _save(Commitment c) async {
    if (c.name.trim().isEmpty) throw ArgumentError('Name is required');
    if (c.startDate != null && c.expiryDate.isBefore(c.startDate!)) {
      throw ArgumentError('Expiry must not be before the start date');
    }
    final now = nowUtcMs();
    final existing = await (_db.select(_db.commitments)..where((t) => t.id.equals(c.id))).getSingleOrNull();
    final typeExists =
        await (_db.select(_db.commitmentTypes)..where((t) => t.id.equals(c.typeId))).getSingleOrNull() != null;
    await _db.into(_db.commitments).insertOnConflictUpdate(CommitmentsCompanion.insert(
          id: c.id,
          ownerProfileId: existing?.ownerProfileId ?? _profileId,
          name: c.name.trim(),
          commitmentTypeId: typeExists ? c.typeId : CommitmentType.other.id,
          providerName: Value(c.providerName),
          startDate: Value(c.startDate?.toIso()),
          expiryDate: c.expiryDate.toIso(),
          renewalDate: Value(c.renewalDate?.toIso()),
          amountMinor: Value(c.amountMinor),
          currency: Value(c.amountMinor == null ? null : c.currency?.toUpperCase()),
          renewalMonths: Value(c.renewalMonths),
          referenceNumber: Value(c.referenceNumber),
          serviceUrl: Value(c.serviceUrl),
          notes: Value(c.notes),
          lifecycleStatus: Value(c.lifecycle.name),
          createdAt: existing?.createdAt ?? c.createdAt.toUtc().millisecondsSinceEpoch,
          updatedAt: now,
          rowVersion: Value((existing?.rowVersion ?? 0) + 1),
        ));
    await (_db.delete(_db.reminders)..where((t) => t.ownerType.equals('commitment') & t.ownerId.equals(c.id))).go();
    for (final d in c.reminderDays.toSet()) {
      if (d < 0) continue;
      await _db.into(_db.reminders).insert(RemindersCompanion.insert(
            id: const Uuid().v4(),
            ownerType: 'commitment',
            ownerId: c.id,
            offsetMinutes: d * 1440,
            createdAt: now,
            updatedAt: now,
          ));
    }
  }

  @override
  Future<void> delete(String id) => _db.transaction(() async {
        final now = nowUtcMs();
        await (_db.update(_db.commitments)..where((t) => t.id.equals(id))).write(CommitmentsCompanion.custom(
              deletedAt: Constant(now),
              updatedAt: Constant(now),
              rowVersion: _db.commitments.rowVersion + const Constant(1),
            ));
        await (_db.delete(_db.reminders)..where((t) => t.ownerType.equals('commitment') & t.ownerId.equals(id))).go();
      });

  @override
  Future<void> renew(String id, {required LocalDate newExpiry, int? amountMinor, String? currency, String? notes}) =>
      _db.transaction(() async {
        final rows = await _db.customSelect(_sql.replaceFirst('WHERE c.deleted_at IS NULL', 'WHERE c.deleted_at IS NULL AND c.id = ?'),
            variables: [Variable.withString(id)]).get();
        if (rows.isEmpty) throw StateError('Commitment $id not found');
        final current = _toDomain(await _db.commitments.mapFromRow(rows.first), rows.first.readNullable<String>('reminder_minutes'));
        if (!newExpiry.isAfter(current.expiryDate)) {
          throw ArgumentError('The new expiry must be after the current one');
        }
        await _db.into(_db.commitmentRenewals).insert(CommitmentRenewalsCompanion.insert(
              id: const Uuid().v4(),
              commitmentId: id,
              renewedAt: nowUtcMs(),
              previousExpiryDate: current.expiryDate.toIso(),
              newExpiryDate: newExpiry.toIso(),
              amountMinor: Value(amountMinor),
              currency: Value(amountMinor == null ? null : (currency ?? current.currency)?.toUpperCase()),
              notes: Value(notes),
            ));
        await _save(_rules.renewed(current, newExpiry));
      });
}
