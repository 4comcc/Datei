import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provided in `main()` via override after SharedPreferences is loaded.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider must be overridden'),
);

/// Prototype persistence: JSON collections in SharedPreferences.
///
/// The full app replaces this with Drift/SQLite (see docs/DATABASE_SCHEMA.md);
/// repositories depend only on this small interface so the swap is local.
class LocalStore {
  LocalStore(this._prefs);
  final SharedPreferences _prefs;

  List<Map<String, dynamic>> readCollection(String key) {
    final raw = _prefs.getString(key);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.cast<Map<String, dynamic>>();
    } on FormatException {
      return const [];
    }
  }

  Future<void> writeCollection(String key, List<Map<String, dynamic>> items) =>
      _prefs.setString(key, jsonEncode(items));

  Future<void> remove(String key) => _prefs.remove(key);
}

final localStoreProvider = Provider<LocalStore>(
  (ref) => LocalStore(ref.watch(sharedPreferencesProvider)),
);
