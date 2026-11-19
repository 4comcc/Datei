abstract interface class SettingsRepository {
  Future<Map<String, String>> loadAll();
  Future<void> set(String key, String value);
}

abstract interface class DataMaintenanceRepository {
  /// Permanently deletes all people, events and their links on this device.
  /// Settings and the local profile are kept.
  Future<void> eraseAllUserData();
}
