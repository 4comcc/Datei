import 'package:datei/core/time_engine/local_date.dart';
import 'package:datei/features/commitments/domain/commitment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const rules = CommitmentRules();
  final today = LocalDate.parse('2026-11-20');
  Commitment c(String due, {String? renewBy, CommitmentLifecycle life = CommitmentLifecycle.active, int? months}) => Commitment(
        id: 'x',
        name: 'Domain',
        typeId: CommitmentType.domain.id,
        expiryDate: LocalDate.parse(due),
        renewalDate: renewBy == null ? null : LocalDate.parse(renewBy),
        renewalMonths: months,
        lifecycle: life,
        createdAt: DateTime(2026),
      );

  test('status thresholds: overdue < 0, due soon ≤ 7, upcoming ≤ 30, else active', () {
    expect(rules.statusOf(c('2026-11-19'), today), CommitmentStatus.overdue);
    expect(rules.statusOf(c('2026-11-20'), today), CommitmentStatus.dueSoon);
    expect(rules.statusOf(c('2026-11-27'), today), CommitmentStatus.dueSoon);
    expect(rules.statusOf(c('2026-11-28'), today), CommitmentStatus.upcoming);
    expect(rules.statusOf(c('2026-12-20'), today), CommitmentStatus.upcoming);
    expect(rules.statusOf(c('2026-12-21'), today), CommitmentStatus.active);
  });

  test('renew-by date drives the status; lifecycle overrides time', () {
    expect(rules.statusOf(c('2027-06-01', renewBy: '2026-11-18'), today), CommitmentStatus.overdue);
    expect(rules.statusOf(c('2026-01-01', life: CommitmentLifecycle.completed), today), CommitmentStatus.completed);
    expect(rules.statusOf(c('2026-01-01', life: CommitmentLifecycle.cancelled), today), CommitmentStatus.cancelled);
  });

  test('suggested renewal uses the period (default one year), clamping month ends', () {
    expect(rules.suggestedRenewal(c('2026-01-31', months: 1)), LocalDate.parse('2026-02-28'));
    expect(rules.suggestedRenewal(c('2024-02-29')), LocalDate.parse('2025-02-28'));
  });

  test('renewing moves the renew-by date by the same number of days and reactivates', () {
    final r = rules.renewed(c('2026-12-01', renewBy: '2026-11-15', life: CommitmentLifecycle.completed), LocalDate.parse('2027-12-01'));
    expect(r.expiryDate, LocalDate.parse('2027-12-01'));
    expect(r.renewalDate, LocalDate.parse('2027-11-15'));
    expect(r.lifecycle, CommitmentLifecycle.active);
  });

  test('amount parsing: Latin/Arabic digits, separators, max two decimals', () {
    expect(CommitmentRules.parseAmount('250'), 25000);
    expect(CommitmentRules.parseAmount('99.5'), 9950);
    expect(CommitmentRules.parseAmount('1,250.75'), 125075);
    expect(CommitmentRules.parseAmount('١٢٥٠٫٥'), 125050);
    expect(CommitmentRules.parseAmount('12.345'), isNull);
    expect(CommitmentRules.parseAmount('abc'), isNull);
    expect(CommitmentRules.parseAmount('-5'), isNull);
    expect(CommitmentRules.formatAmountInput(125050), '1250.50');
    expect(CommitmentRules.formatAmountInput(25000), '250');
  });
}
