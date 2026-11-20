import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/localization/gen/app_localizations.dart';
import '../../app/router/app_router.dart';
import '../../core/notifications/notification_gateway.dart';
import '../../core/notifications/reminder_planner.dart';
import '../../core/time_engine/local_date.dart';
import '../agenda/agenda.dart';
import '../commitments/presentation/commitments_providers.dart';
import '../events/presentation/events_providers.dart';
import '../people/presentation/people_providers.dart';
import '../settings/settings_controller.dart';

final notificationGatewayProvider = Provider<NotificationGateway>((ref) => LocalNotificationGateway());

final reminderPlannerProvider = Provider<ReminderPlanner>((ref) => ReminderPlanner(ref.watch(agendaServiceProvider)));

/// Localized notification texts.
class L10nReminderTexts implements ReminderTexts {
  L10nReminderTexts(this.l, this.localeName);
  final AppLocalizations l;
  final String localeName;

  @override
  String birthdayTitle(String name, int? turningAge) =>
      turningAge == null ? l.notifBirthdayTitle(name) : l.notifBirthdayTurning(name, turningAge);

  @override
  String eventTitle(String title) => title;

  @override
  String commitmentTitle(String name) => l.notifCommitmentTitle(name);

  @override
  String when(LocalDate date, {String? time, required LocalDate from}) {
    final days = from.daysUntil(date);
    var text = DateFormat.MMMEd(localeName).format(date.toDateTime());
    if (time != null) {
      final p = time.split(':');
      text += ' ${DateFormat.jm(localeName).format(DateTime(2000, 1, 1, int.parse(p[0]), int.parse(p[1])))}';
    }
    return l.notifWhen(l.relativeDays(days < 0 ? 0 : days), text);
  }
}

/// Builds the current plan from live data (pure; also used by tests).
final reminderPlanProvider = Provider<List<PlannedNotification>>((ref) {
  final settings = ref.watch(settingsProvider);
  final code = settings.languageCode ?? 'en';
  return ref.watch(reminderPlannerProvider).plan(
        now: DateTime.now(),
        settings: ReminderSettings(
          enabled: settings.remindersEnabled,
          defaultTime: settings.reminderTime,
          birthdayDaysBefore: settings.birthdayReminderDays,
        ),
        people: ref.watch(peopleProvider),
        events: ref.watch(eventsProvider),
        commitments: ref.watch(commitmentsProvider),
        texts: L10nReminderTexts(lookupAppLocalizations(Locale(code)), code),
      );
});

/// Keeps scheduled notifications in sync with the data and routes notification taps.
class ReminderSyncHost extends ConsumerStatefulWidget {
  const ReminderSyncHost({super.key, required this.child, this.debounce = const Duration(milliseconds: 1500)});
  final Widget child;
  final Duration debounce;

  @override
  ConsumerState<ReminderSyncHost> createState() => _ReminderSyncHostState();
}

class _ReminderSyncHostState extends ConsumerState<ReminderSyncHost> {
  Timer? _timer;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final gateway = ref.read(notificationGatewayProvider);
    try {
      await gateway.init(onTap: _openRoute);
      _initialized = true;
      final launch = await gateway.launchRoute();
      if (launch != null) WidgetsBinding.instance.addPostFrameCallback((_) => _openRoute(launch));
      _schedule();
    } catch (e) {
      debugPrint('Notifications unavailable: $e');
    }
  }

  void _openRoute(String route) {
    if (!mounted) return;
    ref.read(routerProvider).push(route);
  }

  void _schedule() {
    _timer?.cancel();
    _timer = Timer(widget.debounce, _sync);
  }

  Future<void> _sync() async {
    if (!_initialized || !mounted) return;
    final gateway = ref.read(notificationGatewayProvider);
    final settings = ref.read(settingsProvider);
    try {
      if (settings.remindersEnabled) {
        await gateway.replaceAll(ref.read(reminderPlanProvider), exact: settings.preciseReminders);
      } else {
        await gateway.cancelAll();
      }
    } catch (e) {
      debugPrint('Reminder sync failed: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(reminderPlanProvider, (_, _) => _schedule());
    ref.listen(settingsProvider.select((s) => (s.remindersEnabled, s.preciseReminders)), (_, _) => _schedule());
    return widget.child;
  }
}
