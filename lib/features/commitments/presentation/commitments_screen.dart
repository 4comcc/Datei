import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../shared/l10n_labels.dart';
import '../../../shared/widgets/common.dart';
import '../../agenda/agenda.dart';
import '../../reminders/reminders_banner.dart';
import '../domain/commitment.dart';
import 'commitments_providers.dart';

class CommitmentsScreen extends ConsumerStatefulWidget {
  const CommitmentsScreen({super.key});

  @override
  ConsumerState<CommitmentsScreen> createState() => _CommitmentsScreenState();
}

class _CommitmentsScreenState extends ConsumerState<CommitmentsScreen> {
  CommitmentStatus? _filter;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final all = ref.watch(commitmentsProvider);
    final loaded = ref.watch(commitmentsStreamProvider).hasValue;
    final rules = ref.watch(commitmentRulesProvider);
    final today = ref.watch(todayProvider);
    final withStatus = [for (final c in all) (c, rules.statusOf(c, today))];
    final shown = [for (final x in withStatus) if (_filter == null || x.$2 == _filter) x];

    return Scaffold(
      appBar: AppBar(title: Text(l.commitments)),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('add-commitment-fab'),
        onPressed: () => context.push('/commitments/new'),
        icon: const Icon(Icons.add),
        label: Text(l.addCommitment),
      ),
      body: !loaded
          ? const Center(child: CircularProgressIndicator())
          : all.isEmpty
              ? EmptyState(icon: Icons.autorenew, title: l.commitmentsEmptyTitle, body: l.commitmentsEmptyBody)
              : ListView(
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 96),
                  children: [
                    const RemindersOffBanner(),
                    SizedBox(
                      height: 44,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          for (final s in <CommitmentStatus?>[null, ...CommitmentStatus.values])
                            Padding(
                              padding: const EdgeInsetsDirectional.only(end: 8),
                              child: ChoiceChip(
                                label: Text(s == null
                                    ? l.filterAllCommitments
                                    : '${s.label(l)} (${withStatus.where((x) => x.$2 == s).length})'),
                                selected: _filter == s,
                                onSelected: (_) => setState(() => _filter = s),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (shown.isEmpty) Padding(padding: const EdgeInsets.all(24), child: Center(child: Text(l.noResults))),
                    for (final (c, status) in shown)
                      Padding(padding: const EdgeInsets.only(bottom: 8), child: CommitmentTile(commitment: c, status: status)),
                  ],
                ),
    );
  }
}

class CommitmentTile extends ConsumerWidget {
  const CommitmentTile({super.key, required this.commitment, required this.status});
  final Commitment commitment;
  final CommitmentStatus status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final today = ref.watch(todayProvider);
    final type = CommitmentType.fromId(commitment.typeId);
    final days = today.daysUntil(commitment.dueDate);
    final (bg, fg) = status.colors(scheme);
    final relative = days < 0 ? l.overdueBy(-days) : l.relativeDays(days);
    return Card(
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        leading: CircleAvatar(backgroundColor: scheme.secondaryContainer, child: Icon(type.icon, color: scheme.onSecondaryContainer)),
        title: Text(commitment.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text([
          context.formatDate(commitment.dueDate),
          if (status == CommitmentStatus.active || status == CommitmentStatus.upcoming ||
              status == CommitmentStatus.dueSoon || status == CommitmentStatus.overdue)
            relative,
          if (commitment.amountMinor != null) context.formatMoney(commitment.amountMinor!, commitment.currency),
        ].join(' · ')),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
          child: Text(status.label(l), style: TextStyle(fontSize: 12, color: fg)),
        ),
        onTap: () => context.push('/commitments/${commitment.id}'),
      ),
    );
  }
}
