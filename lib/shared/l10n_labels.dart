import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../app/localization/gen/app_localizations.dart';
import '../core/recurrence_engine/recurrence.dart';
import '../core/time_engine/hijri.dart';
import '../core/time_engine/local_date.dart';
import '../features/commitments/domain/commitment.dart';
import '../features/events/domain/event.dart';
import '../features/people/domain/category.dart';
import '../features/people/domain/custom_field.dart';
import '../features/people/domain/person.dart';
import '../features/people/domain/relationship.dart';

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
  String get localeName => Localizations.localeOf(this).toLanguageTag();

  String formatLongDate(LocalDate d) => DateFormat.yMMMMEEEEd(localeName).format(d.toDateTime());
  String formatDate(LocalDate d) => DateFormat.yMMMd(localeName).format(d.toDateTime());
  String formatDayMonth(LocalDate d) => DateFormat.MMMd(localeName).format(d.toDateTime());
  String formatLongDayMonth(LocalDate d) => DateFormat.MMMMd(localeName).format(d.toDateTime());
  String formatMonthName(int month) => DateFormat.MMMM(localeName).format(DateTime(2000, month));

  /// Birth date as text, without the year when it is unknown.
  String formatBirthDate(LocalDate d, {required bool yearKnown}) =>
      yearKnown ? formatLongDate(d) : formatLongDayMonth(d);
  String formatMonthYear(LocalDate d) => DateFormat.yMMMM(localeName).format(d.toDateTime());
  String formatTime(String hhmm) {
    final parts = hhmm.split(':');
    return MaterialLocalizations.of(this)
        .formatTimeOfDay(TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1])));
  }
}

extension PersonCategoryLabel on PersonCategoryInfo {
  String label(AppLocalizations l) => switch (systemKey) {
        'family' => l.categoryFamily,
        'relatives' => l.categoryRelatives,
        'friends' => l.categoryFriends,
        'colleagues' => l.categoryColleagues,
        'clients' => l.categoryClients,
        'other' => l.categoryOther,
        _ => name ?? '',
      };
}

extension RelationshipTypeLabel on RelationshipType {
  String label(AppLocalizations l) => switch (this) {
        RelationshipType.father => l.relationFather,
        RelationshipType.mother => l.relationMother,
        RelationshipType.son => l.relationSon,
        RelationshipType.daughter => l.relationDaughter,
        RelationshipType.brother => l.relationBrother,
        RelationshipType.sister => l.relationSister,
        RelationshipType.spouse => l.relationSpouse,
        RelationshipType.relative => l.relationRelative,
        RelationshipType.friend => l.relationFriend,
        RelationshipType.colleague => l.relationColleague,
        RelationshipType.custom => l.relationCustom,
      };
}

extension RelationshipLabel on Relationship {
  String typeLabel(AppLocalizations l) =>
      type == RelationshipType.custom ? (customLabel ?? l.relationCustom) : type.label(l);
}

extension GenderLabel on Gender? {
  String label(AppLocalizations l) => switch (this) {
        Gender.male => l.genderMale,
        Gender.female => l.genderFemale,
        null => l.genderUnspecified,
      };
}

extension CustomFieldTypeLabel on CustomFieldType {
  String label(AppLocalizations l) => switch (this) {
        CustomFieldType.text => l.fieldTypeText,
        CustomFieldType.number => l.fieldTypeNumber,
        CustomFieldType.date => l.fieldTypeDate,
        CustomFieldType.url => l.fieldTypeUrl,
      };
}

extension EventTypeInfoLabel on EventTypeInfo {
  String label(AppLocalizations l) => builtIn?.label(l) ?? name ?? '';
  IconData get icon => builtIn?.icon ?? Icons.event_note_outlined;
}

extension EventPriorityLabel on EventPriority {
  String label(AppLocalizations l) => switch (this) {
        EventPriority.low => l.priorityLow,
        EventPriority.normal => l.priorityNormal,
        EventPriority.high => l.priorityHigh,
        EventPriority.critical => l.priorityCritical,
      };
}

extension EventStatusLabel on EventStatus {
  String label(AppLocalizations l) => switch (this) {
        EventStatus.planned => l.statusPlanned,
        EventStatus.done => l.statusDone,
        EventStatus.cancelled => l.statusCancelled,
      };
}

extension HijriFormatting on AppLocalizations {
  String hijriMonthName(int m) => [
        hijriMonth1, hijriMonth2, hijriMonth3, hijriMonth4, hijriMonth5, hijriMonth6,
        hijriMonth7, hijriMonth8, hijriMonth9, hijriMonth10, hijriMonth11, hijriMonth12,
      ][m - 1];

  String formatHijri(HijriDate h) => hijriFormat(h.day, hijriMonthName(h.month), h.year);
}

extension RecurrenceText on BuildContext {
  String weekdayName(int isoWeekday) =>
      DateFormat.EEEE(localeName).format(DateTime(2024, 1, isoWeekday)); // 2024-01-01 is a Monday

  /// Human description of a rule, e.g. "Every 2 weeks · Monday, Thursday · until Mar 1, 2027".
  String describeRecurrence(RecurrenceRule? rule, LocalDate start) {
    final l = l10n;
    if (rule == null) return l.repeatNone;
    final n = rule.interval;
    final base = switch (rule.frequency) {
      RecurrenceFrequency.daily => n == 1 ? l.repeatDaily : l.everyN(n, l.unitDays(n)),
      RecurrenceFrequency.weekly => n == 1 ? l.repeatWeekly : l.everyN(n, l.unitWeeks(n)),
      RecurrenceFrequency.monthly => n == 1 ? l.repeatMonthly : l.everyN(n, l.unitMonths(n)),
      RecurrenceFrequency.yearly => n == 1 ? l.repeatYearly : l.everyN(n, l.unitYears(n)),
    };
    final parts = <String>[base];
    if (rule.frequency == RecurrenceFrequency.weekly) {
      final days = (rule.weekdays.isEmpty ? {RecurrenceEngine.weekdayOf(start)} : rule.weekdays).toList()..sort();
      parts.add(days.map(weekdayName).join(localeName.startsWith('ar') ? '، ' : ', '));
    } else if (rule.frequency == RecurrenceFrequency.monthly) {
      if (rule.isNthWeekday && rule.weekdays.isNotEmpty) {
        parts.add(l.monthlyOnNth(positionName(rule.setPos!), weekdayName(rule.weekdays.first)));
      } else {
        parts.add(l.monthlyOnDay(rule.monthDay ?? start.day));
      }
    }
    if (rule.until != null) parts.add(l.untilDate(formatDate(rule.until!)));
    if (rule.count != null) parts.add(l.occurrencesCount(rule.count!));
    return parts.join(' · ');
  }

  String positionName(int setPos) => switch (setPos) {
        1 => l10n.posFirst,
        2 => l10n.posSecond,
        3 => l10n.posThird,
        4 => l10n.posFourth,
        _ => l10n.posLast,
      };
}

extension CommitmentTypeLabel on CommitmentType {
  String label(AppLocalizations l) => switch (this) {
        CommitmentType.domain => l.commitmentTypeDomain,
        CommitmentType.hosting => l.commitmentTypeHosting,
        CommitmentType.ssl => l.commitmentTypeSsl,
        CommitmentType.contract => l.commitmentTypeContract,
        CommitmentType.license => l.commitmentTypeLicense,
        CommitmentType.insurance => l.commitmentTypeInsurance,
        CommitmentType.warranty => l.commitmentTypeWarranty,
        CommitmentType.subscription => l.commitmentTypeSubscription,
        CommitmentType.bill => l.commitmentTypeBill,
        CommitmentType.payment => l.commitmentTypePayment,
        CommitmentType.installment => l.commitmentTypeInstallment,
        CommitmentType.passport => l.commitmentTypePassport,
        CommitmentType.nationalId => l.commitmentTypeNationalId,
        CommitmentType.vehicleLicense => l.commitmentTypeVehicleLicense,
        CommitmentType.other => l.commitmentTypeOther,
      };

  IconData get icon => switch (this) {
        CommitmentType.domain => Icons.language,
        CommitmentType.hosting => Icons.dns_outlined,
        CommitmentType.ssl => Icons.lock_outline,
        CommitmentType.contract => Icons.description_outlined,
        CommitmentType.license => Icons.verified_outlined,
        CommitmentType.insurance => Icons.health_and_safety_outlined,
        CommitmentType.warranty => Icons.build_circle_outlined,
        CommitmentType.subscription => Icons.autorenew,
        CommitmentType.bill => Icons.receipt_long_outlined,
        CommitmentType.payment => Icons.payments_outlined,
        CommitmentType.installment => Icons.calendar_view_month_outlined,
        CommitmentType.passport => Icons.travel_explore,
        CommitmentType.nationalId => Icons.badge_outlined,
        CommitmentType.vehicleLicense => Icons.directions_car_outlined,
        CommitmentType.other => Icons.push_pin_outlined,
      };
}

extension CommitmentStatusLabel on CommitmentStatus {
  String label(AppLocalizations l) => switch (this) {
        CommitmentStatus.active => l.cstatusActive,
        CommitmentStatus.upcoming => l.cstatusUpcoming,
        CommitmentStatus.dueSoon => l.cstatusDueSoon,
        CommitmentStatus.overdue => l.cstatusOverdue,
        CommitmentStatus.completed => l.cstatusCompleted,
        CommitmentStatus.cancelled => l.cstatusCancelled,
      };

  /// Semantic colours (separate from the brand accent).
  (Color bg, Color fg) colors(ColorScheme s) => switch (this) {
        CommitmentStatus.overdue => (s.errorContainer, s.onErrorContainer),
        CommitmentStatus.dueSoon => (s.tertiaryContainer, s.onTertiaryContainer),
        CommitmentStatus.upcoming => (s.secondaryContainer, s.onSecondaryContainer),
        CommitmentStatus.active => (s.primaryContainer, s.onPrimaryContainer),
        _ => (s.surfaceContainerHighest, s.onSurfaceVariant),
      };
}

extension MoneyFormatting on BuildContext {
  /// "EGP 1,250.50": the ISO code reads clearly in Arabic and English, unlike
  /// short symbols (E£, ج.م) that render inconsistently across fonts.
  String formatMoney(int minor, String? currency) {
    final number = NumberFormat.decimalPatternDigits(locale: localeName, decimalDigits: minor % 100 == 0 ? 0 : 2)
        .format(minor / 100);
    return currency == null ? number : '\u2066$currency $number\u2069';
  }
}

extension EventTypeLabel on EventType {
  String label(AppLocalizations l) => switch (this) {
        EventType.anniversary => l.eventTypeAnniversary,
        EventType.appointment => l.eventTypeAppointment,
        EventType.travel => l.eventTypeTravel,
        EventType.graduation => l.eventTypeGraduation,
        EventType.achievement => l.eventTypeAchievement,
        EventType.family => l.eventTypeFamily,
        EventType.religious => l.eventTypeReligious,
        EventType.personal => l.eventTypePersonal,
        EventType.other => l.eventTypeOther,
      };

  IconData get icon => switch (this) {
        EventType.anniversary => Icons.celebration_outlined,
        EventType.appointment => Icons.schedule_outlined,
        EventType.travel => Icons.flight_takeoff_outlined,
        EventType.graduation => Icons.school_outlined,
        EventType.achievement => Icons.emoji_events_outlined,
        EventType.family => Icons.family_restroom_outlined,
        EventType.religious => Icons.mosque_outlined,
        EventType.personal => Icons.person_outline,
        EventType.other => Icons.event_note_outlined,
      };
}
