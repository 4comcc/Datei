import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'app/bootstrap.dart';
import 'core/database/app_database.dart';
import 'core/database/database_providers.dart';
import 'features/settings/settings_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase.open();
  final prefs = await SharedPreferences.getInstance();
  final boot = await bootstrap(db, prefs);
  runApp(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        currentProfileIdProvider.overrideWithValue(boot.profileId),
        initialSettingsProvider.overrideWithValue(boot.settings),
      ],
      child: const DateiApp(),
    ),
  );
}
