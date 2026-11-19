import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../app/localization/gen/app_localizations.dart';
import '../core/time_engine/local_date.dart';
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
