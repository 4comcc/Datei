import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../shared/l10n_labels.dart';
import '../../../shared/widgets/common.dart';
import '../../agenda/agenda.dart';
import '../../commitments/domain/commitment.dart';
import '../../commitments/presentation/commitments_providers.dart';
import '../../events/presentation/events_providers.dart';
import '../../memories/presentation/memories_providers.dart';
import '../../people/presentation/people_providers.dart';
import '../../search/presentation/search_providers.dart';
import '../domain/reports.dart';
import 'csv_exports.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  Future<void> _export(BuildContext context, WidgetRef ref, String base, String Function(CsvExports x) build) async {
    final l = context.l10n;
    final exports = CsvExports(
      l: l,
      today: ref.read(todayProvider),
      categoryLabels: {for (final e in ref.read(categoryByIdProvider).entries) e.key: e.value.label(l)},
      eventTypeLabels: {for (final e in ref.read(eventTypeByIdProvider).entries) e.key: e.value.label(l)},
      personNames: {for (final p in ref.read(peopleProvider)) p.id: p.shownName},
      time: ref.read(timeEngineProvider),
    );
    try {
      await shareCsv(ref, baseName: base, content: build(exports), today: ref.read(todayProvider));
    } catch (e) {
      debugPrint('Export failed: $e');
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.exportFailed)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final r = ref.watch(reportDataProvider);
    final categories = ref.watch(categoryByIdProvider);
    final types = ref.watch(eventTypeByIdProvider);
    final scheme = Theme.of(context).colorScheme;

    final categoryBars = [
      for (final e in r.peopleByCategory.entries) (categories[e.key]?.label(l) ?? '?', e.value),
      if (r.uncategorized > 0) (l.reportUncategorized, r.uncategorized),
    ]..sort((a, b) => b.$2.compareTo(a.$2));
    final ageBars = [
      for (var i = 0; i < ageBuckets.length; i++)
        // LTR isolate keeps "0–17" from being reordered to "17–0" in Arabic.
        (
          '\u2066${i == ageBuckets.length - 1 ? l.ageBucketPlus(ageBuckets[i]) : l.ageBucket(ageBuckets[i], ageBuckets[i + 1] - 1)}\u2069',
          r.ageBucketCounts[i],
        ),
      if (r.unknownAge > 0) (l.reportUnknownAge, r.unknownAge),
    ];
    final typeBars = [for (final e in r.eventsByType.entries) (types[e.key]?.label(l) ?? '?', e.value)]..sort((a, b) => b.$2.compareTo(a.$2));
    final commitmentBars = [
      for (final s in CommitmentStatus.values)
        if (r.commitmentsByStatus[s]! > 0) (s.label(l), r.commitmentsByStatus[s]!),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l.reports)),
      body: ListView(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 32),
        children: [
          Row(
            children: [
              _StatTile(label: l.reportPeople, value: r.peopleCount, icon: Icons.people_outline),
              const SizedBox(width: 8),
              _StatTile(label: l.groupMemories, value: r.memoriesCount, icon: Icons.auto_stories_outlined),
              const SizedBox(width: 8),
              _StatTile(label: l.groupMilestones, value: r.milestonesCount, icon: Icons.flag_outlined),
            ],
          ),
          SectionHeader(l.reportUpcoming),
          Row(
            children: [
              for (final (i, d) in const [7, 30, 90].indexed) ...[
                if (i > 0) const SizedBox(width: 8),
                _StatTile(label: l.reportNextDays(d), value: r.upcoming[d] ?? 0, icon: Icons.upcoming_outlined),
              ],
            ],
          ),
          SectionHeader(l.reportByCategory),
          _BarChart(rows: categoryBars, color: scheme.primary),
          SectionHeader(l.reportAges),
          _BarChart(rows: ageBars, color: scheme.secondary),
          SectionHeader(l.reportBirthdaysByMonth),
          _MonthColumns(counts: r.birthdaysByMonth),
          SectionHeader(l.reportEventsByType),
          _BarChart(rows: typeBars, color: scheme.primary),
          SectionHeader(l.reportCommitments),
          _BarChart(rows: commitmentBars, color: scheme.tertiary),
          SectionHeader(l.export),
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 4),
                  child: Text(l.exportHint, style: TextStyle(color: scheme.onSurfaceVariant)),
                ),
                ListTile(
                  key: const Key('export-people'),
                  leading: const Icon(Icons.people_outline),
                  title: Text(l.exportPeople),
                  trailing: const Icon(Icons.ios_share),
                  onTap: () => _export(context, ref, 'people', (x) => x.people(ref.read(peopleProvider))),
                ),
                ListTile(
                  key: const Key('export-events'),
                  leading: const Icon(Icons.event_note_outlined),
                  title: Text(l.exportEvents),
                  trailing: const Icon(Icons.ios_share),
                  onTap: () => _export(context, ref, 'events', (x) => x.events(ref.read(eventsProvider))),
                ),
                ListTile(
                  key: const Key('export-commitments'),
                  leading: const Icon(Icons.autorenew),
                  title: Text(l.exportCommitments),
                  trailing: const Icon(Icons.ios_share),
                  onTap: () => _export(context, ref, 'commitments',
                      (x) => x.commitments(ref.read(commitmentsProvider), ref.read(commitmentRulesProvider))),
                ),
                ListTile(
                  key: const Key('export-memories'),
                  leading: const Icon(Icons.auto_stories_outlined),
                  title: Text(l.exportMemories),
                  trailing: const Icon(Icons.ios_share),
                  onTap: () => _export(context, ref, 'memories', (x) => x.memories(ref.read(memoriesProvider))),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value, required this.icon});
  final String label;
  final int value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20, color: theme.colorScheme.primary),
              const SizedBox(height: 6),
              Text('$value',
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w700, fontFeatures: const [FontFeature.tabularFigures()])),
              Text(label, maxLines: 2, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Horizontal bars scaled to the largest value (works in RTL and LTR).
class _BarChart extends StatelessWidget {
  const _BarChart({required this.rows, required this.color});
  final List<(String, int)> rows;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    if (rows.every((r) => r.$2 == 0)) return InlineEmpty(l.reportNoData);
    final max = rows.map((r) => r.$2).reduce((a, b) => a > b ? a : b);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            for (final (label, value) in rows)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    SizedBox(width: 110, child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis)),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (_, c) => Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Container(
                            height: 14,
                            width: max == 0 ? 0 : (c.maxWidth * value / max).clamp(value > 0 ? 4.0 : 0.0, c.maxWidth),
                            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(7)),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 36,
                      child: Text('$value',
                          textAlign: TextAlign.end,
                          style: TextStyle(color: scheme.onSurfaceVariant, fontFeatures: const [FontFeature.tabularFigures()])),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 12 vertical columns, one per month.
class _MonthColumns extends StatelessWidget {
  const _MonthColumns({required this.counts});
  final List<int> counts;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    if (counts.every((c) => c == 0)) return InlineEmpty(l.reportNoData);
    final max = counts.reduce((a, b) => a > b ? a : b);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 16, 8, 12),
        child: SizedBox(
          height: 150,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var m = 0; m < 12; m++)
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (counts[m] > 0) Text('${counts[m]}', style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant)),
                      const SizedBox(height: 2),
                      Container(
                        height: max == 0 ? 0 : 100 * counts[m] / max,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(color: scheme.tertiary, borderRadius: BorderRadius.circular(4)),
                      ),
                      const SizedBox(height: 4),
                      Text(context.formatMonthName(m + 1).characters.take(3).toString(),
                          style: const TextStyle(fontSize: 10), maxLines: 1, overflow: TextOverflow.clip),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
