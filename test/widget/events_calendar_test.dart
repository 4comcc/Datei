import 'package:datei/app/localization/gen/app_localizations_en.dart';
import 'package:datei/core/recurrence_engine/recurrence.dart';
import 'package:datei/core/time_engine/hijri.dart';
import 'package:datei/core/time_engine/local_date.dart';
import 'package:datei/features/events/domain/event.dart';
import 'package:datei/features/events/presentation/events_providers.dart';
import 'package:datei/features/settings/settings_controller.dart';
import 'package:datei/shared/l10n_labels.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers.dart';
import 'widget_helpers.dart';

final l10nEn = AppLocalizationsEn();

DateiEvent _weekly() => DateiEvent(
      id: 'w',
      title: 'Arabic class',
      typeId: EventType.personal.id,
      date: LocalDate.parse('2026-11-05'),
      time: '18:00',
      recurrence: const RecurrenceRule(frequency: RecurrenceFrequency.weekly),
      createdAt: DateTime(2026),
    );

void main() {
  testWidgets('edit "this event only" overrides one occurrence of a weekly series', (tester) async {
    final c = await pumpApp(tester, settings: englishOnboarded, seed: (c) => c.read(eventsRepositoryProvider).save(_weekly()));
    router(tester, c).go('/events/w/edit?occurrence=2026-11-19');
    await settle(tester);
    expect(find.textContaining('Occurrence on'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('event-title')), 'Arabic exam');
    await tester.tap(find.byKey(const Key('event-save-top')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('scope-thisOccurrence')));
    await settle(tester);

    final e = c.read(eventsProvider).single;
    expect(e.title, 'Arabic class'); // series unchanged
    expect(e.exceptions.single.originalDate, LocalDate.parse('2026-11-19'));
    expect(e.exceptions.single.override!.title, 'Arabic exam');
  });

  testWidgets('delete "this event only" cancels one occurrence', (tester) async {
    final c = await pumpApp(tester, settings: englishOnboarded, seed: (c) => c.read(eventsRepositoryProvider).save(_weekly()));
    router(tester, c).go('/events/w/edit?occurrence=2026-11-26');
    await settle(tester);
    await tester.tap(find.byKey(const Key('event-delete')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('scope-thisOccurrence')));
    await settle(tester);
    final e = c.read(eventsProvider).single;
    expect(e.exceptions.single.isCancelled, isTrue);
  });

  testWidgets('calendar: week and day views list the recurring event; Hijri shown when enabled', (tester) async {
    final c = await pumpApp(
      tester,
      settings: {...englishOnboarded, SettingKeys.showHijri: 'true'},
      seed: (c) => c.read(eventsRepositoryProvider).save(_weekly()),
    );
    router(tester, c).go('/calendar');
    await settle(tester);
    // Month header shows the Hijri months spanning November 2026.
    expect(find.textContaining('Jumada'), findsWidgets);

    await tester.tap(find.text('Week'));
    await settle(tester);
    expect(find.text('Arabic class'), findsOneWidget); // Thursday 2026-11-19

    await tester.tap(find.text('Day'));
    await settle(tester);
    expect(find.textContaining('Arabic class'), findsOneWidget);
    expect(find.textContaining('AH'), findsWidgets);
  });

  testWidgets('Hijri input converts to the Gregorian date in the event form', (tester) async {
    final c = await pumpApp(tester, settings: englishOnboarded);
    router(tester, c).go('/events/new?date=2026-11-19');
    await settle(tester);
    const converter = HijriConverter();
    final start = converter.fromGregorian(LocalDate.parse('2026-11-19'))!;
    final expected = converter.toGregorian(HijriDate(1447, 9, start.day))!;
    final expectedText = DateFormat.yMMMMEEEEd('en').format(expected.toDateTime());

    await tester.tap(find.byKey(const Key('hijri-input')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('hijri-year')), '1447');
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10nEn.hijriMonthName(start.month)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ramadan').last);
    await tester.pumpAndSettle();
    expect(find.textContaining(expectedText), findsOneWidget);
    await tester.tap(find.byKey(const Key('hijri-ok')));
    await tester.pumpAndSettle();
    expect(find.textContaining(expectedText), findsOneWidget);
  });
}
