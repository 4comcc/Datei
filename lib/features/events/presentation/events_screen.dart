import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../shared/l10n_labels.dart';
import '../../../shared/widgets/common.dart';
import '../../agenda/agenda.dart';
import '../../home/home_screen.dart';
import 'events_providers.dart';

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  bool _showPast = false;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final events = ref.watch(eventsProvider);
    final loaded = ref.watch(eventsStreamProvider).hasValue;
    final agenda = ref.watch(agendaServiceProvider);
    final today = ref.watch(todayProvider);

    // Upcoming: the next occurrence of each event (ongoing multi-day events included).
    final upcoming = [
      for (final e in events) ?agenda.nextOccurrence(e, today),
    ]..sort((a, b) => a.date.compareTo(b.date));
    // Past: single events that are over, and recurring series that have ended.
    final past = [
      for (final e in events)
        if (!e.isRecurring && e.date.addDays(e.spanDays).isBefore(today))
          ...agenda.eventOccurrences(e, e.date, e.date)
        else if (e.isRecurring && agenda.nextOccurrence(e, today) == null && e.date.isBefore(today))
          ...agenda.eventOccurrences(e, e.date, e.date),
    ]..sort((a, b) => b.date.compareTo(a.date));
    final items = _showPast ? past : upcoming;

    return Scaffold(
      appBar: AppBar(title: Text(l.navEvents)),
      body: !loaded
          ? const Center(child: CircularProgressIndicator())
          : events.isEmpty
              ? EmptyState(
                  icon: Icons.event_note_outlined,
                  title: l.eventsEmptyTitle,
                  body: l.eventsEmptyBody,
                  action: FilledButton.icon(
                    onPressed: () => context.push('/events/new'),
                    icon: const Icon(Icons.add),
                    label: Text(l.addEvent),
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: SegmentedButton<bool>(
                        segments: [
                          ButtonSegment(value: false, label: Text(l.tabUpcoming), icon: const Icon(Icons.upcoming_outlined)),
                          ButtonSegment(value: true, label: Text(l.tabPast), icon: const Icon(Icons.history)),
                        ],
                        selected: {_showPast},
                        onSelectionChanged: (s) => setState(() => _showPast = s.first),
                      ),
                    ),
                    Expanded(
                      child: items.isEmpty
                          ? Center(child: Text(l.noResults))
                          : ListView.separated(
                              padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 96),
                              itemCount: items.length,
                              separatorBuilder: (_, _) => const SizedBox(height: 8),
                              itemBuilder: (context, i) => AgendaTile(
                                item: items[i],
                                today: today,
                                showRelative: !_showPast,
                                onTap: () => HomeScreen.openItem(context, items[i]),
                              ),
                            ),
                    ),
                  ],
                ),
    );
  }
}
