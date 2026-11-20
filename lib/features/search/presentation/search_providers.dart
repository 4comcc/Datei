import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_providers.dart';
import '../../agenda/agenda.dart';
import '../../commitments/presentation/commitments_providers.dart';
import '../../events/presentation/events_providers.dart';
import '../../memories/presentation/memories_providers.dart';
import '../../people/presentation/people_providers.dart';
import '../../reports/domain/reports.dart';
import '../data/drift_saved_searches_repository.dart';
import '../domain/search.dart';

final searchEngineProvider = Provider<SearchEngine>(
  (ref) => SearchEngine(ref.watch(agendaServiceProvider), ref.watch(timeEngineProvider), ref.watch(commitmentRulesProvider)),
);

final searchDataProvider = Provider<SearchData>((ref) => SearchData(
      people: ref.watch(peopleProvider),
      events: ref.watch(eventsProvider),
      commitments: ref.watch(commitmentsProvider),
      memories: ref.watch(memoriesProvider),
      milestones: ref.watch(milestonesProvider),
      projects: ref.watch(projectsProvider),
    ));

class SearchQueryController extends Notifier<SearchQuery> {
  @override
  SearchQuery build() => const SearchQuery();
  void set(SearchQuery q) => state = q;
}

final searchQueryProvider = NotifierProvider<SearchQueryController, SearchQuery>(SearchQueryController.new);

final searchResultsProvider = Provider<List<SearchResult>>((ref) {
  final q = ref.watch(searchQueryProvider);
  if (q.isEmpty) return const [];
  return ref.watch(searchEngineProvider).search(q, ref.watch(searchDataProvider), ref.watch(todayProvider));
});

final savedSearchesRepositoryProvider =
    Provider<DriftSavedSearchesRepository>((ref) => DriftSavedSearchesRepository(ref.watch(appDatabaseProvider)));
final savedSearchesProvider = StreamProvider<List<SavedSearch>>((ref) => ref.watch(savedSearchesRepositoryProvider).watchAll());

final reportServiceProvider = Provider<ReportService>(
  (ref) => ReportService(ref.watch(agendaServiceProvider), ref.watch(timeEngineProvider), ref.watch(commitmentRulesProvider)),
);

final reportDataProvider = Provider<ReportData>((ref) => ref.watch(reportServiceProvider).build(
      today: ref.watch(todayProvider),
      people: ref.watch(peopleProvider),
      events: ref.watch(eventsProvider),
      commitments: ref.watch(commitmentsProvider),
      memories: ref.watch(memoriesProvider),
      milestones: ref.watch(milestonesProvider),
    ));
