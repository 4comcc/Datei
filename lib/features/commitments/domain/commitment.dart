import '../../../core/time_engine/local_date.dart';

/// Built-in commitment types; ids are `sys:commitment_type:<key>`.
enum CommitmentType {
  domain,
  hosting,
  ssl,
  contract,
  license,
  insurance,
  warranty,
  subscription,
  bill,
  payment,
  installment,
  passport,
  nationalId,
  vehicleLicense,
  other;

  String get key => switch (this) {
        nationalId => 'national_id',
        vehicleLicense => 'vehicle_license',
        _ => name,
      };
  String get id => 'sys:commitment_type:$key';
  static CommitmentType fromId(String id) =>
      CommitmentType.values.firstWhere((t) => t.id == id, orElse: () => CommitmentType.other);
}

/// Stored lifecycle. Time-based states (upcoming, due soon, overdue) are computed.
enum CommitmentLifecycle { active, completed, cancelled }

/// What the user sees.
enum CommitmentStatus { active, upcoming, dueSoon, overdue, completed, cancelled }

/// Default reminder offsets in days before the due date (PRD §11).
const defaultCommitmentReminderDays = [30, 14, 7, 3, 1, 0];

class Commitment {
  const Commitment({
    required this.id,
    required this.name,
    required this.typeId,
    required this.expiryDate,
    required this.createdAt,
    this.providerName,
    this.startDate,
    this.renewalDate,
    this.amountMinor,
    this.currency,
    this.renewalMonths,
    this.referenceNumber,
    this.serviceUrl,
    this.notes,
    this.lifecycle = CommitmentLifecycle.active,
    this.reminderDays = const [],
  });

  final String id;
  final String name;
  final String typeId;
  final String? providerName;
  final LocalDate? startDate;
  final LocalDate expiryDate;
  final LocalDate? renewalDate;
  final int? amountMinor;
  final String? currency;
  final int? renewalMonths;
  final String? referenceNumber;
  final String? serviceUrl;
  final String? notes;
  final CommitmentLifecycle lifecycle;

  /// Days before [dueDate] to remind (0 = on the day).
  final List<int> reminderDays;
  final DateTime createdAt;

  /// The date that matters for status and reminders.
  LocalDate get dueDate => renewalDate ?? expiryDate;

  Commitment copyWith({
    String? id,
    LocalDate? expiryDate,
    LocalDate? Function()? renewalDate,
    CommitmentLifecycle? lifecycle,
    List<int>? reminderDays,
  }) =>
      Commitment(
        id: id ?? this.id,
        name: name,
        typeId: typeId,
        providerName: providerName,
        startDate: startDate,
        expiryDate: expiryDate ?? this.expiryDate,
        renewalDate: renewalDate != null ? renewalDate() : this.renewalDate,
        amountMinor: amountMinor,
        currency: currency,
        renewalMonths: renewalMonths,
        referenceNumber: referenceNumber,
        serviceUrl: serviceUrl,
        notes: notes,
        lifecycle: lifecycle ?? this.lifecycle,
        reminderDays: reminderDays ?? this.reminderDays,
        createdAt: createdAt,
      );
}

class CommitmentRenewal {
  const CommitmentRenewal({
    required this.id,
    required this.renewedAt,
    required this.previousExpiry,
    required this.newExpiry,
    this.amountMinor,
    this.currency,
    this.notes,
  });
  final String id;
  final DateTime renewedAt;
  final LocalDate previousExpiry;
  final LocalDate newExpiry;
  final int? amountMinor;
  final String? currency;
  final String? notes;
}

/// Pure rules for commitments (status thresholds, renewal dates, money parsing).
class CommitmentRules {
  const CommitmentRules({this.dueSoonDays = 7, this.upcomingDays = 30});
  final int dueSoonDays;
  final int upcomingDays;

  CommitmentStatus statusOf(Commitment c, LocalDate today) {
    switch (c.lifecycle) {
      case CommitmentLifecycle.completed:
        return CommitmentStatus.completed;
      case CommitmentLifecycle.cancelled:
        return CommitmentStatus.cancelled;
      case CommitmentLifecycle.active:
        final days = today.daysUntil(c.dueDate);
        if (days < 0) return CommitmentStatus.overdue;
        if (days <= dueSoonDays) return CommitmentStatus.dueSoon;
        if (days <= upcomingDays) return CommitmentStatus.upcoming;
        return CommitmentStatus.active;
    }
  }

  /// Suggested new expiry when renewing: one period after the current expiry
  /// (one year when no period is set).
  LocalDate suggestedRenewal(Commitment c) => c.expiryDate.addMonths(c.renewalMonths ?? 12);

  /// Applies a renewal: new expiry; a renewal date (if any) moves by the same number of days.
  Commitment renewed(Commitment c, LocalDate newExpiry) {
    final shift = c.expiryDate.daysUntil(newExpiry);
    return c.copyWith(
      expiryDate: newExpiry,
      renewalDate: () => c.renewalDate?.addDays(shift),
      lifecycle: CommitmentLifecycle.active,
    );
  }

  /// Parses "1,250.50" / "1250٫5" / "١٢٥٠" into minor units (2 decimals). Null if invalid.
  static int? parseAmount(String input) {
    var s = input.trim();
    if (s.isEmpty) return null;
    const arabicDigits = '٠١٢٣٤٥٦٧٨٩';
    for (var i = 0; i < 10; i++) {
      s = s.replaceAll(arabicDigits[i], '$i');
    }
    s = s.replaceAll('٫', '.').replaceAll('٬', '').replaceAll(',', '').replaceAll(' ', '');
    if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(s)) return null;
    final parts = s.split('.');
    final whole = int.parse(parts[0]);
    final frac = parts.length == 2 ? int.parse(parts[1].padRight(2, '0')) : 0;
    return whole * 100 + frac;
  }

  static String formatAmountInput(int minor) {
    final whole = minor ~/ 100;
    final frac = minor % 100;
    return frac == 0 ? '$whole' : '$whole.${frac.toString().padLeft(2, '0')}';
  }
}
