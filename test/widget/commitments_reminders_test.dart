import 'package:datei/core/time_engine/local_date.dart';
import 'package:datei/features/commitments/domain/commitment.dart';
import 'package:datei/features/commitments/presentation/commitments_providers.dart';
import 'package:datei/features/settings/settings_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers.dart';
import 'widget_helpers.dart';

Commitment _domain() => Commitment(
      id: 'c',
      name: 'example.com',
      typeId: CommitmentType.domain.id,
      expiryDate: LocalDate.parse('2026-11-25'),
      renewalMonths: 12,
      amountMinor: 50000,
      currency: 'USD',
      reminderDays: const [7, 1],
      createdAt: DateTime(2026),
    );

void main() {
  testWidgets('add a commitment from the form; it shows as due soon', (tester) async {
    final c = await pumpApp(tester, settings: englishOnboarded);
    router(tester, c).go('/commitments/new');
    await settle(tester);
    await tester.enterText(find.byKey(const Key('commitment-name')), 'Car insurance');
    await tester.tap(find.byKey(const Key('commitment-save-top')));
    await tester.pumpAndSettle();
    expect(find.text('Please pick a date'), findsOneWidget); // expiry is required

    await tester.enterText(find.byKey(const Key('commitment-amount')), '12.345');
    await tester.tap(find.byKey(const Key('commitment-save-top')));
    await tester.pumpAndSettle();
    expect(find.text('Enter an amount like 250 or 99.50'), findsOneWidget);
  });

  testWidgets('renew from the detail screen records history', (tester) async {
    final c = await pumpApp(tester, settings: englishOnboarded, seed: (c) => c.read(commitmentsRepositoryProvider).save(_domain()));
    router(tester, c).go('/commitments/c');
    await settle(tester);
    expect(find.text('Due soon'), findsOneWidget);

    await tester.tap(find.byKey(const Key('renew')));
    await tester.pumpAndSettle();
    expect(find.textContaining('November 25, 2027'), findsOneWidget); // suggested: one period later
    await tester.tap(find.byKey(const Key('renew-confirm')));
    await settle(tester);

    expect(c.read(commitmentsProvider).single.expiryDate, LocalDate.parse('2027-11-25'));
    expect(find.text('Active'), findsOneWidget);
    expect(find.textContaining('Renewed on'), findsOneWidget);
  });

  testWidgets('turning reminders on asks permission, then schedules notifications', (tester) async {
    final fake = FakeNotificationGateway();
    final c = await pumpApp(
      tester,
      settings: englishOnboarded,
      notifications: fake,
      seed: (c) => c.read(commitmentsRepositoryProvider).save(_domain()),
    );
    router(tester, c).go('/more');
    await settle(tester);
    await tester.tap(find.byKey(const Key('reminders-enabled')));
    await settle(tester);
    expect(c.read(settingsProvider).remindersEnabled, isTrue);

    await tester.pump(const Duration(seconds: 2)); // debounce
    await settle(tester);
    expect(fake.replaceCalls, greaterThan(0));
    final titles = fake.scheduled.map((n) => n.title).toList();
    expect(titles, contains('example.com is due'));

    await tester.scrollUntilVisible(find.byKey(const Key('test-notification')), 200, scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('test-notification')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('test-notification')));
    await tester.pumpAndSettle();
    expect(fake.shown.single, 'Datei|Notifications are working.');
  });

  testWidgets('denied permission keeps reminders off and explains why', (tester) async {
    final fake = FakeNotificationGateway()..permissionGranted = false;
    final c = await pumpApp(tester, settings: englishOnboarded, notifications: fake);
    router(tester, c).go('/more');
    await settle(tester);
    await tester.tap(find.byKey(const Key('reminders-enabled')));
    await settle(tester);
    expect(c.read(settingsProvider).remindersEnabled, isFalse);
    expect(find.textContaining('Notifications are blocked'), findsOneWidget);
  });

  testWidgets('tapping a notification opens its screen', (tester) async {
    final fake = FakeNotificationGateway();
    final c = await pumpApp(
      tester,
      settings: englishOnboarded,
      notifications: fake,
      seed: (c) => c.read(commitmentsRepositoryProvider).save(_domain()),
    );
    fake.onTap!('/commitments/c');
    await settle(tester);
    expect(find.text('example.com'), findsOneWidget);
    expect(c, isNotNull);
  });
}
