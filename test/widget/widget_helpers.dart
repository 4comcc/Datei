import 'package:datei/app/app.dart';
import 'package:datei/app/router/app_router.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers.dart';

/// [seed] runs against the real (in-memory) database before the app is pumped,
/// so no UI stream listeners exist yet (avoids fake-timer deadlocks in tests).
Future<ProviderContainer> pumpApp(
  WidgetTester tester, {
  Map<String, String> settings = const {},
  Future<void> Function(ProviderContainer c)? seed,
  FakeNotificationGateway? notifications,
}) async {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 2.75;
  addTearDown(tester.view.reset);
  final (container, db) = await tester.runAsync(() => createTestContainer(settings: settings, notifications: notifications)) ??
      (throw StateError('setup failed'));
  if (seed != null) await tester.runAsync(() => seed(container));
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox());
    container.dispose();
    await tester.runAsync(db.close);
  });
  await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const DateiApp()));
  await tester.pumpAndSettle();
  return container;
}

Future<void> settle(WidgetTester tester) async {
  // Let Drift's stream queries deliver, then settle animations.
  await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
  await tester.pumpAndSettle(const Duration(milliseconds: 100), EnginePhase.sendSemanticsUpdate, const Duration(seconds: 10));
}

GoRouter router(WidgetTester tester, ProviderContainer c) => c.read(routerProvider);
