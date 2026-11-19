import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/time_engine/local_date.dart';
import '../../shared/l10n_labels.dart';
import '../../shared/widgets/common.dart';
import '../agenda/agenda.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static void openItem(BuildContext context, AgendaItem item) {
    if (item.kind == AgendaKind.birthday) {
      context.push('/people/${item.person!.id}');
    } else {
      context.push('/events/${item.event!.id}/edit');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final today = ref.watch(todayProvider);
    final upcoming = ref.watch(upcomingAgendaProvider(30));
    final todayItems = upcoming.where((i) => i.date == today).toList();
    final birthdays = upcoming.where((i) => i.kind == AgendaKind.birthday && i.date != today).toList();
    final events = upcoming.where((i) => i.kind == AgendaKind.event && i.date != today).toList();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 96),
          children: [
            Card(
              color: theme.colorScheme.primary,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Datei',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(color: theme.colorScheme.onPrimary.withValues(alpha: 0.8))),
                    const SizedBox(height: 6),
                    Text(context.formatLongDate(today),
                        style: theme.textTheme.headlineSmall
                            ?.copyWith(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _StatPill(text: l.todaySummaryEvents(todayItems.length)),
                        _StatPill(text: l.todaySummaryUpcoming(upcoming.length - todayItems.length)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SectionHeader(l.sectionToday),
            if (todayItems.isEmpty)
              InlineEmpty(l.emptyToday)
            else
              ..._tiles(context, todayItems, today),
            SectionHeader(l.sectionBirthdays),
            if (birthdays.isEmpty) InlineEmpty(l.emptyBirthdays) else ..._tiles(context, birthdays.take(5), today),
            SectionHeader(l.sectionUpcomingEvents),
            if (events.isEmpty) InlineEmpty(l.emptyUpcomingEvents) else ..._tiles(context, events.take(5), today),
            SectionHeader(l.sectionQuickActions),
            Row(
              children: [
                Expanded(
                  child: _QuickAction(
                    icon: Icons.person_add_alt_1_outlined,
                    label: l.addPerson,
                    onTap: () => context.push('/people/new'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickAction(
                    icon: Icons.event_outlined,
                    label: l.addEvent,
                    onTap: () => context.push('/events/new'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Iterable<Widget> _tiles(BuildContext context, Iterable<AgendaItem> items, LocalDate today) => items.map(
        (i) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: AgendaTile(item: i, today: today, onTap: () => openItem(context, i)),
        ),
      );
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.onPrimary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: TextStyle(color: scheme.onPrimary, fontSize: 13)),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
          child: Column(
            children: [
              Icon(icon, color: scheme.primary),
              const SizedBox(height: 8),
              Text(label, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
