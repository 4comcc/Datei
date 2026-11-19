// Renders key screens to PNG for visual review (not part of the CI suite).
// Run: flutter test test_screens --update-goldens
import 'dart:io';

import 'package:datei/app/app.dart';
import 'package:datei/app/router/app_router.dart';
import 'package:datei/core/storage/local_store.dart';
import 'package:datei/core/time_engine/local_date.dart';
import 'package:datei/features/agenda/agenda.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

Future<void> loadFonts() async {
  final plex = FontLoader('IBMPlexSansArabic');
  for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
    plex.addFont(Future.value(ByteData.sublistView(File('assets/fonts/IBMPlexSansArabic-$w.ttf').readAsBytesSync())));
  }
  await plex.load();
  final flutterRoot = Platform.environment['FLUTTER_ROOT'] ?? '/opt/flutter';
  final icons = FontLoader('MaterialIcons')
    ..addFont(Future.value(ByteData.sublistView(
        File('$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf').readAsBytesSync())));
  await icons.load();
}

final people = [
  {'id': 'p1', 'fullName': 'سارة أحمد', 'birthDate': '1996-11-24', 'categories': ['family'], 'occupation': 'مهندسة', 'phone': '+20 100 123 4567', 'createdAt': '2026-01-01T00:00:00.000'},
  {'id': 'p2', 'fullName': 'Omar Khaled', 'birthDate': '1988-12-02', 'categories': ['friends'], 'createdAt': '2026-01-01T00:00:00.000'},
  {'id': 'p3', 'fullName': 'منى حسن', 'birthDate': '2000-02-29', 'categories': ['colleagues'], 'createdAt': '2026-01-01T00:00:00.000'},
];
final events = [
  {'id': 'e1', 'title': 'ذكرى الزواج', 'type': 'anniversary', 'date': '2018-11-19', 'repeatsYearly': true, 'personIds': ['p1'], 'createdAt': '2026-01-01T00:00:00.000'},
  {'id': 'e2', 'title': 'Dentist', 'type': 'appointment', 'date': '2026-11-27', 'time': '10:30', 'createdAt': '2026-01-01T00:00:00.000'},
  {'id': 'e3', 'title': 'رحلة الإسكندرية', 'type': 'travel', 'date': '2026-12-05', 'createdAt': '2026-01-01T00:00:00.000'},
];

Future<void> shoot(WidgetTester tester, String lang, String route, String name, {bool dark = false}) async {
  tester.view.physicalSize = const Size(1080, 2280);
  tester.view.devicePixelRatio = 2.75;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({
    'settings.language': lang,
    'settings.onboardingDone': route != '/welcome' && route != '/language',
    'settings.themeMode': dark ? 'dark' : 'light',
    'data.people': jsonEncode(people),
    'data.events': jsonEncode(events),
  });
  final sp = await SharedPreferences.getInstance();
  if (route == '/language') await sp.remove('settings.language');
  final container = ProviderContainer(overrides: [
    sharedPreferencesProvider.overrideWithValue(sp),
    todayProvider.overrideWithValue(const LocalDate(2026, 11, 19)),
  ]);
  addTearDown(container.dispose);
  await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const DateiApp()));
  await tester.pumpAndSettle();
  if (route != '/home' && route != '/welcome' && route != '/language') {
    container.read(routerProvider).go(route);
  }
  await tester.pumpAndSettle();
  await expectLater(find.byType(DateiApp), matchesGoldenFile('out/$name.png'));
}

void main() {
  setUpAll(loadFonts);
  for (final lang in ['ar', 'en']) {
    testWidgets('$lang language', (t) => shoot(t, lang, '/language', '${lang}_0_language'));
    testWidgets('$lang welcome', (t) => shoot(t, lang, '/welcome', '${lang}_1_welcome'));
    testWidgets('$lang home', (t) => shoot(t, lang, '/home', '${lang}_2_home'));
    testWidgets('$lang people', (t) => shoot(t, lang, '/people', '${lang}_3_people'));
    testWidgets('$lang person', (t) => shoot(t, lang, '/people/p1', '${lang}_4_person'));
    testWidgets('$lang calendar', (t) => shoot(t, lang, '/calendar', '${lang}_5_calendar'));
  }
  testWidgets('ar home dark', (t) => shoot(t, 'ar', '/home', 'ar_6_home_dark', dark: true));
}
