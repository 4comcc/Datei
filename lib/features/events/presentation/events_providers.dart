import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_providers.dart';
import '../data/drift_events_repository.dart';
import '../domain/event.dart';
import '../domain/events_repository.dart';

final eventsRepositoryProvider = Provider<EventsRepository>(
  (ref) => DriftEventsRepository(ref.watch(appDatabaseProvider), ref.watch(currentProfileIdProvider)),
);

final eventsStreamProvider =
    StreamProvider<List<DateiEvent>>((ref) => ref.watch(eventsRepositoryProvider).watchAll());

final eventsProvider = Provider<List<DateiEvent>>((ref) => ref.watch(eventsStreamProvider).value ?? const []);

final eventByIdProvider = Provider.family<DateiEvent?, String>((ref, id) {
  for (final e in ref.watch(eventsProvider)) {
    if (e.id == id) return e;
  }
  return null;
});
