import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_providers.dart';
import '../../agenda/agenda.dart';
import '../data/drift_people_extras_repositories.dart';
import '../data/drift_people_repository.dart';
import '../domain/category.dart';
import '../domain/custom_field.dart';
import '../domain/people_filter.dart';
import '../domain/people_repository.dart';
import '../domain/person.dart';
import '../domain/relationship.dart';

// Repositories
final peopleRepositoryProvider = Provider<PeopleRepository>(
  (ref) => DriftPeopleRepository(ref.watch(appDatabaseProvider), ref.watch(currentProfileIdProvider)),
);
final categoriesRepositoryProvider =
    Provider<CategoriesRepository>((ref) => DriftCategoriesRepository(ref.watch(appDatabaseProvider)));
final relationshipsRepositoryProvider =
    Provider<RelationshipsRepository>((ref) => DriftRelationshipsRepository(ref.watch(appDatabaseProvider)));
final customFieldsRepositoryProvider =
    Provider<CustomFieldsRepository>((ref) => DriftCustomFieldsRepository(ref.watch(appDatabaseProvider)));
final savedPeopleFiltersRepositoryProvider =
    Provider<SavedPeopleFiltersRepository>((ref) => DriftSavedPeopleFiltersRepository(ref.watch(appDatabaseProvider)));

// Live data
final peopleStreamProvider = StreamProvider<List<Person>>((ref) => ref.watch(peopleRepositoryProvider).watchAll());

/// Current people (empty while the first query is loading). Use [peopleStreamProvider]
/// where the loading state matters (e.g. to avoid flashing an empty state).
final peopleProvider = Provider<List<Person>>((ref) => ref.watch(peopleStreamProvider).value ?? const []);

final personByIdProvider = Provider.family<Person?, String>((ref, id) {
  for (final p in ref.watch(peopleProvider)) {
    if (p.id == id) return p;
  }
  return null;
});

final categoriesProvider = StreamProvider<List<PersonCategoryInfo>>(
  (ref) => ref.watch(categoriesRepositoryProvider).watchAll(),
);

final categoryByIdProvider = Provider<Map<String, PersonCategoryInfo>>(
  (ref) => {for (final c in ref.watch(categoriesProvider).value ?? const <PersonCategoryInfo>[]) c.id: c},
);

final relationshipsProvider = StreamProvider<List<Relationship>>(
  (ref) => ref.watch(relationshipsRepositoryProvider).watchAll(),
);

/// Relationships where the given person is the subject or the related person.
final relationshipsForPersonProvider = Provider.family<List<Relationship>, String>((ref, personId) => [
      for (final r in ref.watch(relationshipsProvider).value ?? const <Relationship>[])
        if (r.personId == personId || r.relatedPersonId == personId) r,
    ]);

final customFieldDefinitionsProvider = StreamProvider<List<CustomFieldDefinition>>(
  (ref) => ref.watch(customFieldsRepositoryProvider).watchDefinitions(),
);

final savedPeopleFiltersProvider = StreamProvider<List<SavedPeopleFilter>>(
  (ref) => ref.watch(savedPeopleFiltersRepositoryProvider).watchAll(),
);

// Filtering (state lives here, not in widgets)
class PeopleFilterController extends Notifier<PeopleFilter> {
  @override
  PeopleFilter build() => PeopleFilter.empty;

  void set(PeopleFilter filter) => state = filter;
  void setQuery(String query) => state = state.copyWith(query: query);
  void clearCriteria() => state = PeopleFilter(query: state.query);
}

final peopleFilterProvider = NotifierProvider<PeopleFilterController, PeopleFilter>(PeopleFilterController.new);

final filteredPeopleProvider = Provider<List<Person>>((ref) {
  final filter = ref.watch(peopleFilterProvider);
  final people = ref.watch(peopleProvider);
  if (filter.isEmpty) return people;
  final engine = ref.watch(timeEngineProvider);
  final today = ref.watch(todayProvider);
  final typesByPerson = <String, Set<RelationshipType>>{};
  for (final r in ref.watch(relationshipsProvider).value ?? const <Relationship>[]) {
    typesByPerson.putIfAbsent(r.personId, () => {}).add(r.type);
  }
  return [
    for (final p in people)
      if (filter.matches(p, today: today, engine: engine, relationTypes: typesByPerson[p.id] ?? const {})) p,
  ];
});
