// Renders key screens to PNG for visual review (not part of the CI suite).
// Run: flutter test test_screens --update-goldens
import 'dart:io';

import 'package:datei/app/app.dart';
import 'package:datei/app/router/app_router.dart';
import 'package:datei/core/recurrence_engine/recurrence.dart';
import 'package:datei/core/time_engine/local_date.dart';
import 'package:datei/features/commitments/domain/commitment.dart';
import 'package:datei/features/commitments/presentation/commitments_providers.dart';
import 'package:datei/features/events/domain/event.dart';
import 'package:datei/features/memories/domain/memory.dart';
import 'package:datei/features/memories/presentation/memories_providers.dart';
import 'package:datei/features/milestones/domain/milestone.dart';
import 'package:datei/features/projects/domain/project.dart';
import 'package:datei/features/events/presentation/events_providers.dart';
import 'package:datei/features/people/domain/custom_field.dart';
import 'package:datei/features/people/domain/person.dart';
import 'package:datei/features/people/domain/relationship.dart';
import 'package:datei/features/people/presentation/people_providers.dart';
import 'package:datei/features/settings/settings_controller.dart';
import 'package:datei/core/security/pin_hasher.dart';
import '../test/helpers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

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

Future<void> shoot(WidgetTester tester, String lang, String route, String name,
    {bool dark = false, bool hijri = false, FakeSecureStore? store, FakeBiometrics? bio, Future<void> Function(WidgetTester t)? then}) async {
  tester.view.physicalSize = const Size(1080, 3400);
  tester.view.devicePixelRatio = 2.75;
  addTearDown(tester.view.reset);
  final onboarded = route != '/welcome' && route != '/language';
  final (container, db) = (await tester.runAsync(() => createTestContainer(settings: {
        if (route != '/language') SettingKeys.language: lang,
        SettingKeys.onboardingDone: '$onboarded',
        SettingKeys.themeMode: dark ? 'dark' : 'light',
        if (hijri) SettingKeys.showHijri: 'true',
      }, secureStore: store, biometrics: bio)))!;
  await tester.runAsync(() async {
    for (final p in people) {
      await container.read(peopleRepositoryProvider).save(Person.fromJson(p));
    }
    for (final e in events) {
      await container.read(eventsRepositoryProvider).save(DateiEvent.fromJson(e));
    }
    await container.read(customFieldsRepositoryProvider)
        .saveDefinition(const CustomFieldDefinition(id: 'blood', label: 'فصيلة الدم'));
    final sara = Person.fromJson(people.first);
    await container.read(peopleRepositoryProvider).save(Person.fromJson({
      ...sara.toJson(),
      'organization': 'شركة النيل',
      'customFields': {'blood': 'O+'},
    }));
    await container.read(relationshipsRepositoryProvider)
        .add(const Relationship(id: 'r1', personId: 'p1', type: RelationshipType.sister));
    await container.read(relationshipsRepositoryProvider)
        .add(const Relationship(id: 'r2', personId: 'p3', relatedPersonId: 'p1', type: RelationshipType.colleague));
    await container.read(eventsRepositoryProvider).save(DateiEvent(
          id: 'w',
          title: 'درس العربية',
          typeId: EventType.personal.id,
          date: LocalDate.parse('2026-11-05'),
          time: '18:00',
          endTime: '19:30',
          recurrence: const RecurrenceRule(frequency: RecurrenceFrequency.weekly, weekdays: {1, 4}),
          createdAt: DateTime(2026),
        ));
    await container.read(commitmentsRepositoryProvider).save(Commitment(
          id: 'c1', name: 'datei.app', typeId: CommitmentType.domain.id, providerName: 'Namecheap',
          expiryDate: LocalDate.parse('2026-11-24'), renewalMonths: 12, amountMinor: 120000, currency: 'EGP',
          reminderDays: const [30, 7, 1], createdAt: DateTime(2026),
        ));
    await container.read(commitmentsRepositoryProvider).save(Commitment(
          id: 'c2', name: 'جواز السفر', typeId: CommitmentType.passport.id,
          expiryDate: LocalDate.parse('2026-11-10'), reminderDays: const [30], createdAt: DateTime(2026),
        ));
    await container.read(commitmentsRepositoryProvider).save(Commitment(
          id: 'c3', name: 'تأمين السيارة', typeId: CommitmentType.insurance.id, providerName: 'مصر للتأمين',
          expiryDate: LocalDate.parse('2027-03-01'), renewalMonths: 12, amountMinor: 850000, currency: 'EGP',
          reminderDays: const [30, 7], createdAt: DateTime(2026),
        ));
    await container.read(commitmentsRepositoryProvider).renew('c3', newExpiry: LocalDate.parse('2028-03-01'), amountMinor: 900000);
    await container.read(memoriesRepositoryProvider).save(Memory(
          id: 'm1', title: 'رحلة الأقصر مع العائلة', date: LocalDate.parse('2023-02-14'),
          body: 'زرنا معبد الكرنك ووادي الملوك، وكان الجو جميلًا.', personIds: const ['p1'], tags: const ['سفر', 'عائلة'],
          createdAt: DateTime(2026),
        ));
    await container.read(memoriesRepositoryProvider).save(Memory(
          id: 'm2', title: 'أول يوم في العمل الجديد', date: LocalDate.parse('2024-09-01'), tags: const ['عمل'], createdAt: DateTime(2026),
        ));
    await container.read(projectsRepositoryProvider).save(Project(
          id: 'pr1', name: 'تأليف كتاب عن تاريخ العائلة', startDate: LocalDate.parse('2026-01-10'),
          dueDate: LocalDate.parse('2027-03-01'), status: ProjectStatus.active, personIds: const ['p1'], createdAt: DateTime(2026),
        ));
    await container.read(milestonesRepositoryProvider).save(Milestone(
          id: 'ms1', title: 'تخرّج سارة من الجامعة', date: LocalDate.parse('2018-06-30'), kind: MilestoneKind.graduation,
          personId: 'p1', createdAt: DateTime(2026),
        ));
    await container.read(eventsRepositoryProvider).save(DateiEvent(
          id: 'trip',
          title: 'مؤتمر دبي',
          typeId: EventType.travel.id,
          date: LocalDate.parse('2026-11-18'),
          endDate: LocalDate.parse('2026-11-21'),
          createdAt: DateTime(2026),
        ));
  });
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox());
    container.dispose();
    await tester.runAsync(db.close);
  });
  await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const DateiApp()));
  await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
  await tester.pumpAndSettle();
  if (onboarded && route != '/home') container.read(routerProvider).go(route);
  await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
  await tester.pumpAndSettle();
  if (then != null) {
    await then(tester);
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
    await tester.pumpAndSettle();
  }
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
    testWidgets('$lang more', (t) => shoot(t, lang, '/more', '${lang}_7_more'));
    testWidgets('$lang categories', (t) => shoot(t, lang, '/settings/categories', '${lang}_8_categories'));
    testWidgets('$lang calendar', (t) => shoot(t, lang, '/calendar', '${lang}_5_calendar'));
  }
  testWidgets('ar calendar hijri', (t) => shoot(t, 'ar', '/calendar', 'ar_9_calendar_hijri', hijri: true));
  testWidgets('ar week', (t) => shoot(t, 'ar', '/calendar', 'ar_10_week', then: (t) => t.tap(find.text('أسبوع'))));
  testWidgets('ar day', (t) => shoot(t, 'ar', '/calendar', 'ar_11_day', then: (t) => t.tap(find.text('يوم'))));
  testWidgets('ar event form', (t) => shoot(t, 'ar', '/events/w/edit?occurrence=2026-11-19', 'ar_12_event_form', hijri: true));
  testWidgets('ar recurrence', (t) => shoot(t, 'ar', '/events/w/edit', 'ar_13_recurrence',
      then: (t) async {
        await t.ensureVisible(find.byKey(const Key('recurrence-tile')));
        await t.tap(find.byKey(const Key('recurrence-tile')));
      }));
  testWidgets('ar commitments', (t) => shoot(t, 'ar', '/commitments', 'ar_14_commitments'));
  testWidgets('ar commitment', (t) => shoot(t, 'ar', '/commitments/c3', 'ar_15_commitment'));
  testWidgets('ar commitment form', (t) => shoot(t, 'ar', '/commitments/c1/edit', 'ar_16_commitment_form'));
  testWidgets('ar timeline', (t) => shoot(t, 'ar', '/timeline', 'ar_17_timeline'));
  testWidgets('ar memories', (t) => shoot(t, 'ar', '/memories', 'ar_18_memories'));
  testWidgets('ar memory', (t) => shoot(t, 'ar', '/memories/m1', 'ar_19_memory'));
  testWidgets('ar projects', (t) => shoot(t, 'ar', '/projects/pr1', 'ar_20_project'));
  testWidgets('ar person timeline', (t) => shoot(t, 'ar', '/people/p1/timeline', 'ar_21_person_timeline'));
  testWidgets('ar reports', (t) => shoot(t, 'ar', '/reports', 'ar_22_reports'));
  testWidgets('ar search', (t) => shoot(t, 'ar', '/search', 'ar_23_search', then: (t) async {
        await t.enterText(find.byKey(const Key('search-field')), 'ساره');
      }));
  testWidgets('ar search filters', (t) => shoot(t, 'ar', '/search', 'ar_24_search_filters', then: (t) async {
        await t.tap(find.byKey(const Key('add-condition')));
        await t.pumpAndSettle();
        await t.tap(find.byKey(const Key('cond-time-upcoming')));
        await t.pumpAndSettle();
        await t.tap(find.byKey(const Key('add-condition')));
        await t.pumpAndSettle();
        await t.tap(find.byKey(const Key('cond-recurring')));
      }));
  testWidgets('ar home dark', (t) => shoot(t, 'ar', '/home', 'ar_6_home_dark', dark: true));

  Future<FakeSecureStore> lockedStore(WidgetTester t, {bool bio = false}) async {
    final store = FakeSecureStore();
    await t.runAsync(() async {
      store.values['lock.pin_hash'] = await const PinHasher(iterations: 1000).hash('1234');
      if (bio) store.values['lock.biometric'] = 'true';
    });
    return store;
  }

  for (final lang in ['ar', 'en']) {
    testWidgets('$lang lock', (t) async => shoot(t, lang, '/home', '${lang}_25_lock',
        store: await lockedStore(t, bio: true), bio: FakeBiometrics()..available = true..succeed = false,
        then: (t) async {
          await t.tap(find.byKey(const Key('pin-key-1')));
          await t.tap(find.byKey(const Key('pin-key-2')));
        }));
    testWidgets('$lang backup', (t) => shoot(t, lang, '/settings/backup', '${lang}_27_backup'));
    testWidgets('$lang privacy', (t) => shoot(t, lang, '/settings/privacy', '${lang}_28_privacy'));
  }
  testWidgets('ar lock dark', (t) async =>
      shoot(t, 'ar', '/home', 'ar_25_lock_dark', dark: true, store: await lockedStore(t)));
  testWidgets('ar security settings', (t) async {
    final store = FakeSecureStore();
    await t.runAsync(() async => store.values['lock.pin_hash'] = await const PinHasher(iterations: 1000).hash('1234'));
    await shoot(t, 'ar', '/more', 'ar_26_security', store: store, bio: FakeBiometrics()..available = true, then: (t) async {
      // Unlock, then scroll to the security section.
      for (final d in '1234'.split('')) {
        await t.tap(find.byKey(Key('pin-key-$d')));
        await t.pump();
      }
      await t.tap(find.byKey(const Key('pin-ok')));
      for (var i = 0; i < 10; i++) {
        await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
        await t.pump(const Duration(milliseconds: 50));
      }
      await t.scrollUntilVisible(find.byKey(const Key('open-privacy')), 300, scrollable: find.byType(Scrollable).first);
    });
  });
  testWidgets('ar create backup dialog', (t) => shoot(t, 'ar', '/settings/backup', 'ar_29_backup_dialog', then: (t) async {
        await t.tap(find.byKey(const Key('backup-create')));
        await t.pumpAndSettle();
        await t.tap(find.byKey(const Key('backup-encrypt')));
      }));
}
