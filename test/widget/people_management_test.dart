import 'package:datei/core/time_engine/local_date.dart';
import 'package:datei/features/people/domain/person.dart';
import 'package:datei/features/people/presentation/people_providers.dart';
import 'package:datei/features/settings/settings_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers.dart';
import 'widget_helpers.dart';

Person _p(String id, String name, {String? birth, bool yearKnown = true, List<String> cats = const []}) => Person(
      id: id,
      fullName: name,
      birthDate: birth == null ? null : LocalDate.parse(birth),
      birthYearKnown: yearKnown,
      categoryIds: cats,
      createdAt: DateTime(2026),
    );

void main() {
  testWidgets('relationship added in Arabic shows on both profiles (RTL)', (tester) async {
    final c = await pumpApp(
      tester,
      settings: {SettingKeys.language: 'ar', SettingKeys.onboardingDone: 'true'},
      seed: (c) async {
        await c.read(peopleRepositoryProvider).save(_p('a', 'أحمد'));
        await c.read(peopleRepositoryProvider).save(_p('b', 'سارة'));
      },
    );
    router(tester, c).go('/people/a');
    await settle(tester);

    await tester.ensureVisible(find.byKey(const Key('add-relationship')));
    await tester.tap(find.byKey(const Key('add-relationship')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('أب'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('relationship-target')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('سارة').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('relationship-save')));
    await settle(tester);

    expect(find.text('أب سارة'), findsOneWidget);
    expect(Directionality.of(tester.element(find.text('أب سارة'))), TextDirection.rtl);

    router(tester, c).go('/people/b');
    await settle(tester);
    await tester.scrollUntilVisible(find.text('أحمد'), 200, scrollable: find.byType(Scrollable).first);
    expect(find.text('أحمد'), findsOneWidget); // incoming: "Ahmad — Father"
  });

  testWidgets('filter by category and save the filter', (tester) async {
    final c = await pumpApp(tester, settings: englishOnboarded, seed: (c) async {
      await c.read(peopleRepositoryProvider).save(_p('a', 'Amal', cats: ['sys:category:family']));
      await c.read(peopleRepositoryProvider).save(_p('b', 'Bilal', cats: ['sys:category:friends']));
    });
    router(tester, c).go('/people');
    await settle(tester);
    expect(find.text('Amal'), findsOneWidget);
    expect(find.text('Bilal'), findsOneWidget);

    await tester.tap(find.byKey(const Key('open-filters')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilterChip, 'Family'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('filter-save')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('filter-name')), 'My family');
    await tester.tap(find.byKey(const Key('text-input-save')));
    await settle(tester);

    expect(find.text('Amal'), findsOneWidget);
    expect(find.text('Bilal'), findsNothing);
    expect(find.text('My family'), findsOneWidget);
    expect(find.text('1 person'), findsOneWidget);
  });

  testWidgets('birth date without year: no age, birthday still shown', (tester) async {
    final c = await pumpApp(
      tester,
      settings: englishOnboarded,
      seed: (c) => c.read(peopleRepositoryProvider).save(_p('a', 'Noor', birth: '1990-11-24', yearKnown: false)),
    );
    router(tester, c).go('/people/a');
    await settle(tester);
    expect(find.textContaining('years old'), findsNothing);
    expect(find.textContaining('November 24'), findsOneWidget); // value is wrapped in a bidi isolate
    expect(find.textContaining('In 5 days'), findsOneWidget);
    expect(find.textContaining('Turns'), findsNothing);
  });
}
