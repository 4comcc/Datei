import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../app/localization/gen/app_localizations.dart';
import '../core/time_engine/local_date.dart';
import '../features/events/domain/event.dart';
import '../features/people/domain/person.dart';

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
  String get localeName => Localizations.localeOf(this).toLanguageTag();

  String formatLongDate(LocalDate d) => DateFormat.yMMMMEEEEd(localeName).format(d.toDateTime());
  String formatDate(LocalDate d) => DateFormat.yMMMd(localeName).format(d.toDateTime());
  String formatDayMonth(LocalDate d) => DateFormat.MMMd(localeName).format(d.toDateTime());
  String formatMonthYear(LocalDate d) => DateFormat.yMMMM(localeName).format(d.toDateTime());
  String formatTime(String hhmm) {
    final parts = hhmm.split(':');
    return MaterialLocalizations.of(this)
        .formatTimeOfDay(TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1])));
  }
}

extension PersonCategoryLabel on PersonCategory {
  String label(AppLocalizations l) => switch (this) {
        PersonCategory.family => l.categoryFamily,
        PersonCategory.relatives => l.categoryRelatives,
        PersonCategory.friends => l.categoryFriends,
        PersonCategory.colleagues => l.categoryColleagues,
        PersonCategory.clients => l.categoryClients,
        PersonCategory.other => l.categoryOther,
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
