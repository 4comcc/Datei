import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_providers.dart';
import '../data/drift_events_repository.dart';
import '../domain/event.dart';
import '../domain/events_repository.dart';

final eventsRepositoryProvider = Provider<EventsRepository>(
  (ref) => DriftEventsRepository(ref.watch(appDatabaseProvider), ref.watch(currentProfileIdProvider)),
);

final eventTypesRepositoryProvider =
    Provider<EventTypesRepository>((ref) => DriftEventTypesRepository(ref.watch(appDatabaseProvider)));

final eventsStreamProvider = StreamProvider<List<DateiEvent>>((ref) => ref.watch(eventsRepositoryProvider).watchAll());

final eventsProvider = Provider<List<DateiEvent>>((ref) => ref.watch(eventsStreamProvider).value ?? const []);

final eventByIdProvider = Provider.family<DateiEvent?, String>((ref, id) {
  for (final e in ref.watch(eventsProvider)) {
    if (e.id == id) return e;
  }
  return null;
});

final eventTypesProvider =
    StreamProvider<List<EventTypeInfo>>((ref) => ref.watch(eventTypesRepositoryProvider).watchAll());

final eventTypeByIdProvider = Provider<Map<String, EventTypeInfo>>(
  (ref) => {for (final t in ref.watch(eventTypesProvider).value ?? const <EventTypeInfo>[]) t.id: t},
);
