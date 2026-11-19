import 'package:datei/app/app.dart';
import 'package:datei/core/time_engine/local_date.dart';
import 'package:datei/features/people/domain/person.dart';
import 'package:datei/features/people/presentation/people_providers.dart';
import 'package:datei/features/settings/settings_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers.dart';

Future<ProviderContainer> pumpApp(WidgetTester tester, {Map<String, String> settings = const {}}) async {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 2.75;
  addTearDown(tester.view.reset);
  final (container, db) = await tester.runAsync(() => createTestContainer(settings: settings)) ??
      (throw StateError('setup failed'));
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
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('first run: choose Arabic → RTL welcome → guest → home', (tester) async {
    final container = await pumpApp(tester);
    expect(find.byKey(const Key('lang-ar')), findsOneWidget);

    await tester.tap(find.byKey(const Key('lang-ar')));
    await tester.pumpAndSettle();
    expect(find.text('اختر لغتك'), findsOneWidget);

    await tester.tap(find.byKey(const Key('lang-continue')));
    await settle(tester);
    expect(find.text('المتابعة كضيف'), findsOneWidget);
    expect(Directionality.of(tester.element(find.text('المتابعة كضيف'))), TextDirection.rtl);

    await tester.tap(find.byKey(const Key('continue-guest')));
    await settle(tester);
    expect(find.text('الرئيسية'), findsWidgets);
    expect(find.text('لا يوجد شيء مجدول لليوم.'), findsOneWidget);

    // Persisted in the database.
    final stored = await tester.runAsync(() => container.read(settingsRepositoryProvider).loadAll());
    expect(stored![SettingKeys.language], 'ar');
    expect(stored[SettingKeys.onboardingDone], 'true');
  });

  testWidgets('saved settings skip onboarding (English, LTR)', (tester) async {
    await pumpApp(tester, settings: englishOnboarded);
    expect(find.text('Nothing scheduled for today.'), findsOneWidget);
    expect(Directionality.of(tester.element(find.text('Nothing scheduled for today.'))), TextDirection.ltr);
  });

  testWidgets('add a person → detail; birthday then appears on Home', (tester) async {
    final container = await pumpApp(tester, settings: englishOnboarded);

    await tester.tap(find.byKey(const Key('quick-add')));
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(of: find.byType(BottomSheet), matching: find.text('Add person')));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('person-save')));
    await tester.tap(find.byKey(const Key('person-save')));
    await tester.pumpAndSettle();
    expect(find.text('This field is required'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('person-fullName')), 'Sara Ahmed');
    await tester.ensureVisible(find.byKey(const Key('person-save')));
    await tester.tap(find.byKey(const Key('person-save')));
    await settle(tester);
    expect(find.text('Sara Ahmed'), findsWidgets);
    expect(find.text('No birth date'), findsOneWidget);

    final person = container.read(peopleProvider).single;
    await tester.runAsync(() => container
        .read(peopleRepositoryProvider)
        .save(Person.fromJson({...person.toJson(), 'birthDate': const LocalDate(1996, 11, 24).toIso()})));
    await settle(tester);
    expect(find.text('29 years old'), findsOneWidget);
    expect(find.textContaining('Turns 30'), findsOneWidget);

    await tester.pageBack();
    await settle(tester);
    expect(find.text("Sara Ahmed's birthday"), findsOneWidget);
    expect(find.text('In 5 days'), findsOneWidget);
  });
}
