import 'package:datei/core/notifications/notification_gateway.dart';
import 'package:datei/core/notifications/reminder_planner.dart';

/// Records what the app asks the platform to do.
class FakeNotificationGateway implements NotificationGateway {
  bool permissionGranted = true;
  bool exactGranted = false;
  List<PlannedNotification> scheduled = [];
  int replaceCalls = 0;
  int cancelCalls = 0;
  final shown = <String>[];
  void Function(String route)? onTap;

  @override
  Future<void> init({required void Function(String route) onTap}) async => this.onTap = onTap;
  @override
  Future<String?> launchRoute() async => null;
  @override
  Future<bool> requestPermission() async => permissionGranted;
  @override
  Future<bool> requestExactPermission() async => exactGranted;
  @override
  Future<bool> canScheduleExact() async => exactGranted;
  @override
  Future<void> replaceAll(List<PlannedNotification> items, {required bool exact}) async {
    replaceCalls++;
    scheduled = List.of(items);
  }

  @override
  Future<void> cancelAll() async {
    cancelCalls++;
    scheduled = [];
  }

  @override
  Future<void> showNow({required String title, required String body}) async => shown.add('$title|$body');
}
