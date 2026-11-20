import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart' show Color;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'reminder_planner.dart';

/// Platform notifications behind an interface (tests use a fake).
abstract interface class NotificationGateway {
  /// Sets up channels and time zone. [onTap] receives the route of a tapped notification.
  Future<void> init({required void Function(String route) onTap});

  /// Route of the notification that launched the app, if any.
  Future<String?> launchRoute();

  /// Asks for permission to show notifications (Android 13+). Returns whether granted.
  Future<bool> requestPermission();

  /// Asks for exact-alarm access (Android 12+). Returns whether granted.
  Future<bool> requestExactPermission();
  Future<bool> canScheduleExact();

  /// Replaces every pending notification with [items].
  Future<void> replaceAll(List<PlannedNotification> items, {required bool exact});

  Future<void> cancelAll();
  Future<void> showNow({required String title, required String body});
}

class LocalNotificationGateway implements NotificationGateway {
  LocalNotificationGateway([FlutterLocalNotificationsPlugin? plugin]) : _plugin = plugin ?? FlutterLocalNotificationsPlugin();
  final FlutterLocalNotificationsPlugin _plugin;
  bool _ready = false;

  static const _channel = AndroidNotificationDetails(
    'datei_reminders',
    'Reminders',
    channelDescription: 'Birthdays, events and renewals',
    importance: Importance.high,
    priority: Priority.high,
    icon: 'ic_stat_datei',
    color: Color(0xFF596B35),
  );
  static const _details = NotificationDetails(android: _channel);

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

  @override
  Future<void> init({required void Function(String route) onTap}) async {
    if (_ready) return;
    tzdata.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (e) {
      debugPrint('Time zone lookup failed, using UTC: $e');
      tz.setLocalLocation(tz.UTC);
    }
    await _plugin.initialize(
      settings: const InitializationSettings(android: AndroidInitializationSettings('ic_stat_datei')),
      onDidReceiveNotificationResponse: (r) {
        final route = r.payload;
        if (route != null && route.startsWith('/')) onTap(route);
      },
    );
    _ready = true;
  }

  @override
  Future<String?> launchRoute() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp != true) return null;
    final route = details!.notificationResponse?.payload;
    return route != null && route.startsWith('/') ? route : null;
  }

  @override
  Future<bool> requestPermission() async => await _android?.requestNotificationsPermission() ?? false;

  @override
  Future<bool> requestExactPermission() async => await _android?.requestExactAlarmsPermission() ?? false;

  @override
  Future<bool> canScheduleExact() async => await _android?.canScheduleExactNotifications() ?? false;

  @override
  Future<void> replaceAll(List<PlannedNotification> items, {required bool exact}) async {
    await _plugin.cancelAll();
    final mode = exact && await canScheduleExact()
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;
    for (final n in items) {
      final when = tz.TZDateTime.local(n.fireAt.year, n.fireAt.month, n.fireAt.day, n.fireAt.hour, n.fireAt.minute);
      await _plugin.zonedSchedule(
        id: n.id,
        title: n.title,
        body: n.body,
        scheduledDate: when,
        notificationDetails: _details,
        androidScheduleMode: mode,
        payload: n.route,
      );
    }
  }

  @override
  Future<void> cancelAll() => _plugin.cancelAll();

  @override
  Future<void> showNow({required String title, required String body}) =>
      _plugin.show(id: 1, title: title, body: body, notificationDetails: _details);
}
