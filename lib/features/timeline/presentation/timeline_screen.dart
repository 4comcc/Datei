import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../shared/l10n_labels.dart';
import '../../agenda/agenda.dart';
import '../../events/presentation/events_providers.dart';
import '../../people/presentation/people_providers.dart';
import '../domain/timeline.dart';
import 'timeline_providers.dart';

class TimelineScreen extends ConsumerStatefulWidget {
  const TimelineScreen({super.key, this.personId});
  final String? personId;

  @override
  ConsumerState<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends ConsumerState<TimelineScreen> {
  TimelinePeriod _period = TimelinePeriod.all;
  Set<TimelineGroup> _groups = {...TimelineGroup.values};

  String _groupLabel(TimelineGroup g) {
    final l = context.l10n;
    return switch (g) {
      TimelineGroup.events => l.groupEvents,
      TimelineGroup.birthdays => l.groupBirthdays,
      TimelineGroup.memories => l.groupMemories,
      TimelineGroup.milestones => l.groupMilestones,
      TimelineGroup.projects => l.groupProjects,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final person = widget.personId == null ? null : ref.watch(personByIdProvider(widget.personId!));
    final entries = ref.watch(timelineProvider((_period, _groups, widget.personId)));
    final today = ref.watch(todayProvider);

    // Insert a "today" marker between future and past entries, and year headers.
    final rows = <Widget>[];
    int? year;
    var todayShown = false;
    for (final e in entries) {
      if (!todayShown && !e.date.isAfter(today)) {
        rows.add(_TodayMarker(label: '${l.todayMarker} · ${context.formatDate(today)}'));
        todayShown = true;
      }
      if (e.date.year != year) {
        year = e.date.year;
        rows.add(Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(4, 16, 4, 6),
          child: Text('$year', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
        ));
      }
      rows.add(_EntryTile(entry: e));
    }
    if (!todayShown && entries.isNotEmpty) rows.add(_TodayMarker(label: '${l.todayMarker} · ${context.formatDate(today)}'));

    return Scaffold(
      appBar: AppBar(title: Text(person == null ? l.timeline : l.timelineOf(person.shownName))),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SegmentedButton<TimelinePeriod>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(value: TimelinePeriod.all, label: Text(l.periodAll)),
                ButtonSegment(value: TimelinePeriod.pastYear, label: Text(l.periodPastYear)),
                ButtonSegment(value: TimelinePeriod.thisYear, label: Text(l.periodThisYear)),
                ButtonSegment(value: TimelinePeriod.upcoming, label: Text(l.periodUpcoming)),
              ],
              selected: {_period},
              onSelectionChanged: (s) => setState(() => _period = s.first),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              children: [
                for (final g in TimelineGroup.values)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: FilterChip(
                      key: Key('timeline-group-${g.name}'),
                      label: Text(_groupLabel(g)),
                      selected: _groups.contains(g),
                      onSelected: (s) => setState(() => _groups = s ? {..._groups, g} : ({..._groups}..remove(g))),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: entries.isEmpty
                ? Center(child: Text(l.timelineEmpty))
                : ListView(padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 12, 32), children: rows),
          ),
        ],
      ),
    );
  }
}

class _TodayMarker extends StatelessWidget {
  const _TodayMarker({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(child: Divider(color: scheme.primary, thickness: 1.5)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(label, style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w700)),
          ),
          Expanded(child: Divider(color: scheme.primary, thickness: 1.5)),
        ],
      ),
    );
  }
}

class _EntryTile extends ConsumerWidget {
  const _EntryTile({required this.entry});
  final TimelineEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final types = ref.watch(eventTypeByIdProvider);
    final e = entry;
    final (IconData icon, Color bg, Color fg) = switch (e.kind) {
      TimelineKind.birth => (Icons.child_care, scheme.tertiaryContainer, scheme.onTertiaryContainer),
      TimelineKind.birthday => (Icons.cake_outlined, scheme.tertiaryContainer, scheme.onTertiaryContainer),
      TimelineKind.event => (types[e.eventTypeId]?.icon ?? Icons.event_note_outlined, scheme.primaryContainer, scheme.onPrimaryContainer),
      TimelineKind.memory => (Icons.auto_stories_outlined, scheme.secondaryContainer, scheme.onSecondaryContainer),
      TimelineKind.milestone => (e.milestoneKind?.icon ?? Icons.flag_outlined, scheme.tertiaryContainer, scheme.onTertiaryContainer),
      TimelineKind.projectStart || TimelineKind.projectDue => (Icons.rocket_launch_outlined, scheme.surfaceContainerHighest, scheme.onSurfaceVariant),
    };
    final title = switch (e.kind) {
      TimelineKind.birth => l.timelineBorn(e.title),
      TimelineKind.birthday => e.turningAge == null ? l.birthdayOf(e.title) : '${l.birthdayOf(e.title)} · ${l.turnsAge(e.turningAge!)}',
      TimelineKind.projectStart => l.timelineProjectStarted(e.title),
      TimelineKind.projectDue => l.timelineProjectDue(e.title),
      _ => e.title,
    };
    final subtitle = [
      e.endDate == null ? context.formatDayMonth(e.date) : '${context.formatDayMonth(e.date)} – ${context.formatDayMonth(e.endDate!)}',
      if (e.kind == TimelineKind.milestone && e.milestoneKind != null) e.milestoneKind!.label(l),
      if (e.photoCount > 0) l.photoCount(e.photoCount),
      if (e.subtitle != null) e.subtitle!.split('\n').first,
    ].join(' · ');
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Card(
        child: ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          leading: CircleAvatar(backgroundColor: bg, child: Icon(icon, color: fg)),
          title: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis),
          subtitle: Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
          onTap: () => context.push(e.route),
        ),
      ),
    );
  }
}
