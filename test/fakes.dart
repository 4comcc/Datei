import 'dart:typed_data';

import 'package:datei/core/security/secure_store.dart';
import 'package:datei/features/backup/backup_controller.dart';
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

/// In-memory stand-in for the Keystore-backed secure storage.
class FakeSecureStore implements SecureStore {
  final values = <String, String>{};
  @override
  Future<String?> read(String key) async => values[key];
  @override
  Future<void> write(String key, String value) async => values[key] = value;
  @override
  Future<void> delete(String key) async => values.remove(key);
}

class FakeBiometrics implements Biometrics {
  bool available = false;
  bool succeed = true;
  int prompts = 0;
  @override
  Future<bool> isAvailable() async => available;
  @override
  Future<bool> authenticate(String reason) async {
    prompts++;
    return succeed;
  }
}

/// Saves into memory and returns a preset file when asked to pick one.
class FakeBackupFiles implements BackupFiles {
  final saved = <String, Uint8List>{};
  Uint8List? toPick;
  @override
  Future<bool> save(String fileName, Uint8List bytes) async {
    saved[fileName] = bytes;
    return true;
  }

  @override
  Future<Uint8List?> pick() async => toPick;
}
