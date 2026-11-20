import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../agenda/agenda.dart';
import '../../events/presentation/events_providers.dart';
import '../../memories/presentation/memories_providers.dart';
import '../../people/presentation/people_providers.dart';
import '../domain/timeline.dart';

final timelineServiceProvider = Provider<TimelineService>((ref) => TimelineService(ref.watch(agendaServiceProvider)));

/// (period, groups, personId) → entries.
final timelineProvider = Provider.family<List<TimelineEntry>, (TimelinePeriod, Set<TimelineGroup>, String?)>((ref, args) {
  return ref.watch(timelineServiceProvider).build(
        today: ref.watch(todayProvider),
        period: args.$1,
        groups: args.$2,
        personId: args.$3,
        people: ref.watch(peopleProvider),
        events: ref.watch(eventsProvider),
        memories: ref.watch(memoriesProvider),
        milestones: ref.watch(milestonesProvider),
        projects: ref.watch(projectsProvider),
      );
});
