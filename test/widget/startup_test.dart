import 'dart:async';

import 'package:datei/app/bootstrap.dart';
import 'package:datei/app/startup.dart';
import 'package:datei/core/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers.dart';

void main() {
  testWidgets('a startup failure shows an error screen with details and retry', (tester) async {
    var calls = 0;
    await tester.pumpWidget(StartupApp(loader: () async {
      calls++;
      throw StateError('disk full');
    }));
    await tester.pumpAndSettle();
    expect(find.text("Datei couldn't start"), findsOneWidget);
    expect(find.textContaining('disk full'), findsWidgets);

    await tester.tap(find.byKey(const Key('startup-retry')));
    await tester.pumpAndSettle();
    expect(calls, 2);
  });

  testWidgets('a hanging startup times out instead of freezing', (tester) async {
    await tester.pumpWidget(StartupApp(
      timeout: const Duration(seconds: 2),
      loader: () => Completer<(AppDatabase, BootstrapResult)>().future,
    ));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('Opening the database took too long.'), findsOneWidget);
  });

  testWidgets('successful startup shows the app', (tester) async {
    final db = openTestDatabase();
    final boot = await tester.runAsync(() async {
      final id = await ensureLocalProfile(db);
      return BootstrapResult(profileId: id, settings: englishOnboarded);
    });
    await tester.pumpWidget(StartupApp(loader: () async => (db, boot!)));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Nothing scheduled for today.'), findsOneWidget);
    // Unmount, let Drift's stream-close timer fire, then close the database.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(Duration.zero);
    await tester.runAsync(db.close);
  });
}
