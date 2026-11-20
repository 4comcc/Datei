import 'dart:io';

import 'package:datei/core/time_engine/local_date.dart';
import 'package:datei/features/commitments/domain/commitment.dart';
import 'package:datei/features/commitments/presentation/commitments_providers.dart';
import 'package:datei/features/people/domain/person.dart';
import 'package:datei/features/people/presentation/people_providers.dart';
import 'package:datei/features/reports/presentation/csv_exports.dart';
import 'package:datei/features/search/presentation/search_providers.dart';
import 'package:datei/features/settings/settings_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers.dart';
import 'widget_helpers.dart';

class _FakeSharer implements FileSharer {
  final shared = <File>[];
  @override
  Future<void> share(File file, {required String mimeType, String? subject}) async => shared.add(file);
}

Future<void> _seed(ProviderContainer c) async {
  await c.read(peopleRepositoryProvider).save(Person(id: 'p', fullName: 'أحمد علي', birthDate: LocalDate.parse('1990-12-05'), createdAt: DateTime(2026)));
  await c.read(commitmentsRepositoryProvider).save(Commitment(
        id: 'c', name: 'datei.app', typeId: CommitmentType.domain.id, expiryDate: LocalDate.parse('2026-11-10'), createdAt: DateTime(2026)));
}

void main() {
  testWidgets('search from home finds Arabic names without hamza; overdue condition; save search', (tester) async {
    final c = await pumpApp(tester, settings: {SettingKeys.language: 'ar', SettingKeys.onboardingDone: 'true'}, seed: _seed);
    await tester.tap(find.byKey(const Key('home-search')));
    await settle(tester);
    await tester.enterText(find.byKey(const Key('search-field')), 'احمد');
    await settle(tester);
    expect(find.text('أحمد علي'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('search-field')), '');
    await tester.tap(find.byKey(const Key('add-condition')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('cond-time-overdue')));
    await settle(tester);
    expect(find.text('datei.app'), findsOneWidget);
    expect(find.text('أحمد علي'), findsNothing);

    await tester.tap(find.byKey(const Key('search-save')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('search-name')), 'المتأخر');
    await tester.tap(find.byKey(const Key('text-input-save')));
    await settle(tester);
    expect((await tester.runAsync(() => c.read(savedSearchesRepositoryProvider).watchAll().first))!.single.name, 'المتأخر');
  });

  testWidgets('reports show counts and export a CSV through the share sheet', (tester) async {
    final sharer = _FakeSharer();
    final dir = Directory.systemTemp.createTempSync('datei_export_');
    final c = await pumpApp(
      tester,
      settings: englishOnboarded,
      seed: _seed,
      extraOverrides: [
        fileSharerProvider.overrideWithValue(sharer),
        exportDirectoryProvider.overrideWithValue(() async => dir),
      ],
    );
    router(tester, c).go('/reports');
    await settle(tester);
    await tester.scrollUntilVisible(find.text('Overdue'), 200, scrollable: find.byType(Scrollable).first);
    expect(find.text('Overdue'), findsOneWidget); // commitments chart
    await tapVisible(tester, find.byKey(const Key('export-people')));
    for (var i = 0; i < 10; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pump();
    }
    expect(sharer.shared.single.path, endsWith('datei-people-2026-11-19.csv'));
    final bytes = (await tester.runAsync(() => sharer.shared.single.readAsBytes()))!;
    expect(bytes.take(3), [0xEF, 0xBB, 0xBF]); // UTF-8 BOM (readAsString strips it)
    final content = (await tester.runAsync(() => sharer.shared.single.readAsString()))!;
    expect(content, startsWith('Full name,'));
    expect(content, contains('أحمد علي'));
    dir.deleteSync(recursive: true);
  });
}
