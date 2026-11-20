import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:cupertino_ui/cupertino_ui.dart' show GlobalCupertinoLocalizations;
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart' show GlobalWidgetsLocalizations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/database/app_database.dart';
import '../core/database/database_providers.dart';
import '../core/services/attachment_store.dart';
import '../features/settings/settings_controller.dart';
import '../shared/widgets/datei_logo.dart';
import 'app.dart';
import 'bootstrap.dart';
import 'localization/gen/app_localizations.dart';
import 'theme/app_theme.dart';

/// Opens local data, then shows the app. A failure or a hang never leaves the
/// user on a frozen splash screen: it shows a localized error with details.
typedef StartupLoader = Future<(AppDatabase, BootstrapResult)> Function();

Future<(AppDatabase, BootstrapResult)> _defaultLoader() async {
  final db = AppDatabase.open();
  try {
    final prefs = await SharedPreferences.getInstance();
    final docs = await getApplicationDocumentsDirectory();
    return (db, await bootstrap(db, prefs, attachmentsRoot: docs.path));
  } catch (_) {
    await db.close();
    rethrow;
  }
}

class StartupApp extends StatefulWidget {
  const StartupApp({super.key, this.timeout = const Duration(seconds: 20), this.loader = _defaultLoader});
  final Duration timeout;
  final StartupLoader loader;

  @override
  State<StartupApp> createState() => _StartupAppState();
}

class _StartupAppState extends State<StartupApp> {
  AppDatabase? _db;
  BootstrapResult? _boot;
  Object? _error;
  StackTrace? _stack;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    setState(() {
      _error = null;
      _stack = null;
    });
    try {
      final (db, result) = await widget.loader().timeout(widget.timeout);
      if (mounted) {
        setState(() {
          _db = db;
          _boot = result;
        });
      }
    } catch (e, st) {
      debugPrint('Startup failed: $e\n$st');
      if (mounted) {
        setState(() {
          _error = e;
          _stack = st;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final boot = _boot;
    if (boot != null) {
      return ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(_db!),
          currentProfileIdProvider.overrideWithValue(boot.profileId),
          initialSettingsProvider.overrideWithValue(boot.settings),
          attachmentStoreProvider.overrideWithValue(LocalAttachmentStore(boot.attachmentsRoot ?? Directory.systemTemp.path)),
        ],
        child: const DateiApp(),
      );
    }
    final deviceArabic = ui.PlatformDispatcher.instance.locale.languageCode == 'ar';
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      locale: Locale(deviceArabic ? 'ar' : 'en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: _error == null
          ? const _Loading()
          : _StartupError(error: _error!, stack: _stack, onRetry: _start),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DateiLogo(size: 88),
              SizedBox(height: 28),
              SizedBox.square(dimension: 24, child: CircularProgressIndicator(strokeWidth: 2.5)),
            ],
          ),
        ),
      );
}

class _StartupError extends StatelessWidget {
  const _StartupError({required this.error, required this.stack, required this.onRetry});
  final Object error;
  final StackTrace? stack;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final summary = error is TimeoutException ? l.startupTimeout : '$error';
    final details = 'Datei startup error\n$error\n\n${stack ?? ''}';
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Align(alignment: AlignmentDirectional.centerStart, child: DateiLogo(size: 56)),
            const SizedBox(height: 20),
            Text(l.startupErrorTitle, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(l.startupErrorBody, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 16),
            Text(summary, style: TextStyle(color: theme.colorScheme.error, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            FilledButton(key: const Key('startup-retry'), onPressed: onRetry, child: Text(l.retry)),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: details));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.copied)));
                }
              },
              icon: const Icon(Icons.copy),
              label: Text(l.copyDetails),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SelectableText(
                details,
                textDirection: TextDirection.ltr,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                maxLines: 40,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
