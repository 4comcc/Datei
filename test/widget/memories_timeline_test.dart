import 'dart:io';

import 'package:datei/core/time_engine/local_date.dart';
import 'package:datei/features/memories/domain/memory.dart';
import 'package:datei/features/memories/presentation/memories_providers.dart';
import 'package:datei/features/memories/presentation/memory_form_screen.dart';
import 'package:datei/features/milestones/domain/milestone.dart';
import 'package:datei/features/people/domain/person.dart';
import 'package:datei/features/people/presentation/people_providers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers.dart';
import 'widget_helpers.dart';

void main() {
  testWidgets('add a memory with photos and tags from the form', (tester) async {
    final dir = Directory.systemTemp.createTempSync('datei_pick_');
    final picked = [for (final n in ['a', 'b']) (File('${dir.path}/$n.jpg')..writeAsBytesSync(List.filled(32, 1))).path];
    final c = await pumpApp(
      tester,
      settings: englishOnboarded,
      extraOverrides: [imageSourceProvider.overrideWithValue(() async => picked)],
    );

    router(tester, c).go('/memories/new');
    await settle(tester);
    await tester.tap(find.byKey(const Key('memory-save-top')));
    await tester.pumpAndSettle();
    expect(find.text('This field is required'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('memory-title')), 'First day at school');
    await tester.tap(find.byKey(const Key('add-photos')));
    // Copying files is real I/O: let it progress, then deliver results (once per photo).
    for (var i = 0; i < 25; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
      await tester.pump();
    }
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('memory-tag-input')));
    await tester.enterText(find.byKey(const Key('memory-tag-input')), 'school');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('memory-save-top')));
    await settle(tester);

    final m = c.read(memoriesProvider).single;
    expect(m.title, 'First day at school');
    expect(m.photos, hasLength(2));
    expect(m.tags, ['school']);
    dir.deleteSync(recursive: true);
  });

  testWidgets('timeline shows memories and milestones, and filters by type', (tester) async {
    final c = await pumpApp(tester, settings: englishOnboarded, seed: (c) async {
      await c.read(memoriesRepositoryProvider).save(Memory(id: 'm', title: 'Beach day', date: LocalDate.parse('2010-08-01'), createdAt: DateTime(2026)));
      await c.read(milestonesRepositoryProvider).save(Milestone(
            id: 'g', title: 'Graduated', date: LocalDate.parse('2018-06-30'), kind: MilestoneKind.graduation, createdAt: DateTime(2026)));
    });
    router(tester, c).go('/timeline');
    await settle(tester);
    expect(find.text('Beach day'), findsOneWidget);
    expect(find.text('Graduated'), findsOneWidget);
    expect(find.textContaining('Today'), findsWidgets);

    await tester.ensureVisible(find.byKey(const Key('timeline-group-memories')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('timeline-group-memories')));
    await settle(tester);
    expect(find.text('Beach day'), findsNothing);
    expect(find.text('Graduated'), findsOneWidget);
  });

  testWidgets('person page opens their own timeline', (tester) async {
    final c = await pumpApp(tester, settings: englishOnboarded, seed: (c) async {
      await c.read(peopleRepositoryProvider).save(Person(id: 'p', fullName: 'Sara', birthDate: LocalDate.parse('1996-11-24'), createdAt: DateTime(2026)));
      await c.read(memoriesRepositoryProvider).save(Memory(
            id: 'm', title: 'Her wedding', date: LocalDate.parse('2021-05-05'), personIds: const ['p'], createdAt: DateTime(2026)));
    });
    router(tester, c).go('/people/p');
    await settle(tester);
    await tester.scrollUntilVisible(find.byKey(const Key('person-timeline')), 200, scrollable: find.byType(Scrollable).first);
    await tester.tap(find.byKey(const Key('person-timeline')));
    await settle(tester);
    expect(find.text("Sara's timeline"), findsOneWidget);
    expect(find.text('Her wedding'), findsOneWidget);
    expect(find.text('Sara was born'), findsOneWidget);
  });
}
