import 'package:datei/app/app.dart';
import 'package:datei/core/storage/local_store.dart';
import 'package:datei/core/time_engine/local_date.dart';
import 'package:datei/features/agenda/agenda.dart';
import 'package:datei/features/people/data/people_repository.dart';
import 'package:datei/features/people/domain/person.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> pumpApp(WidgetTester tester, {Map<String, Object> prefs = const {}}) async {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 2.75;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues(prefs);
  final sp = await SharedPreferences.getInstance();
  final container = ProviderContainer(overrides: [
    sharedPreferencesProvider.overrideWithValue(sp),
    todayProvider.overrideWithValue(const LocalDate(2026, 11, 19)),
  ]);
  addTearDown(container.dispose);
  await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const DateiApp()));
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets('first run: choose Arabic → RTL welcome → guest → home', (tester) async {
    await pumpApp(tester);
    expect(find.byKey(const Key('lang-ar')), findsOneWidget);

    await tester.tap(find.byKey(const Key('lang-ar')));
    await tester.pumpAndSettle();
    expect(find.text('اختر لغتك'), findsOneWidget);

    await tester.tap(find.byKey(const Key('lang-continue')));
    await tester.pumpAndSettle();
    expect(find.text('المتابعة كضيف'), findsOneWidget);
    expect(Directionality.of(tester.element(find.text('المتابعة كضيف'))), TextDirection.rtl);

    await tester.tap(find.byKey(const Key('continue-guest')));
    await tester.pumpAndSettle();
    expect(find.text('الرئيسية'), findsWidgets);
    expect(find.text('لا يوجد شيء مجدول لليوم.'), findsOneWidget);
  });

  testWidgets('language choice persists: onboarding is skipped on next launch (English, LTR)', (tester) async {
    await pumpApp(tester, prefs: {'settings.language': 'en', 'settings.onboardingDone': true});
    expect(find.text('Nothing scheduled for today.'), findsOneWidget);
    expect(Directionality.of(tester.element(find.text('Nothing scheduled for today.'))), TextDirection.ltr);
  });

  testWidgets('add a person with a birthday → shows on People and Home', (tester) async {
    final container = await pumpApp(tester, prefs: {'settings.language': 'en', 'settings.onboardingDone': true});

    await tester.tap(find.byKey(const Key('quick-add')));
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(of: find.byType(BottomSheet), matching: find.text('Add person')));
    await tester.pumpAndSettle();

    // Validation
    await tester.ensureVisible(find.byKey(const Key('person-save')));
    await tester.tap(find.byKey(const Key('person-save')));
    await tester.pumpAndSettle();
    expect(find.text('This field is required'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('person-fullName')), 'Sara Ahmed');
    // Save without a birth date first, then set one through the controller
    // to verify that every derived view updates reactively.
    await tester.ensureVisible(find.byKey(const Key('person-save')));
    await tester.tap(find.byKey(const Key('person-save')));
    await tester.pumpAndSettle();
    expect(find.text('Sara Ahmed'), findsWidgets); // detail screen
    expect(find.text('No birth date'), findsOneWidget);

    final person = container.read(peopleProvider).single;
    await container.read(peopleProvider.notifier).upsert(
          // Birthday in 5 days, turning 30.
          _withBirth(person, const LocalDate(1996, 11, 24)),
        );
    await tester.pumpAndSettle();
    expect(find.text('29 years old'), findsOneWidget);
    expect(find.textContaining('Turns 30'), findsOneWidget);

    // Back to home: birthday listed with relative days.
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text("Sara Ahmed's birthday"), findsOneWidget);
    expect(find.text('In 5 days'), findsOneWidget);
  });
}

Person _withBirth(Person p, LocalDate birth) => Person.fromJson({...p.toJson(), 'birthDate': birth.toIso()});
