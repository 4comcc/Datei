import 'package:cupertino_ui/cupertino_ui.dart' show GlobalCupertinoLocalizations;
import 'package:flutter_localizations/flutter_localizations.dart' show GlobalWidgetsLocalizations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../features/settings/settings_controller.dart';
import 'localization/gen/app_localizations.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class DateiApp extends ConsumerWidget {
  const DateiApp({super.key});

  /// One digit system across the UI: intl formats Arabic dates with Arabic-Indic
  /// digits but numbers with Latin ones. Use Latin everywhere for now; a user
  /// preference for Arabic-Indic digits is planned (see DECISIONS ADR-028).
  static void configureIntl() => DateFormat.useNativeDigitsByDefaultFor('ar', false);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    configureIntl();
    final settings = ref.watch(settingsProvider);
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: settings.themeMode,
      locale: settings.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
    );
  }
}
