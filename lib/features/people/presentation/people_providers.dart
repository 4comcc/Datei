import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_providers.dart';
import '../data/drift_people_repository.dart';
import '../domain/people_repository.dart';
import '../domain/person.dart';

final peopleRepositoryProvider = Provider<PeopleRepository>(
  (ref) => DriftPeopleRepository(ref.watch(appDatabaseProvider), ref.watch(currentProfileIdProvider)),
);

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
