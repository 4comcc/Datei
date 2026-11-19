import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/local_store.dart';
import '../domain/event.dart';

class EventsController extends Notifier<List<DateiEvent>> {
  static const storageKey = 'data.events';

  LocalStore get _store => ref.read(localStoreProvider);

  @override
  List<DateiEvent> build() =>
      ref.watch(localStoreProvider).readCollection(storageKey).map(DateiEvent.fromJson).toList();

  Future<void> _persist(List<DateiEvent> next) async {
    await _store.writeCollection(storageKey, next.map((e) => e.toJson()).toList());
    state = next;
  }

  Future<void> upsert(DateiEvent event) =>
      _persist([...state.where((e) => e.id != event.id), event]);

  Future<void> delete(String id) => _persist(state.where((e) => e.id != id).toList());

  Future<void> unlinkPerson(String personId) => _persist([
        for (final e in state)
          e.personIds.contains(personId)
              ? e.copyWith(personIds: e.personIds.where((id) => id != personId).toList())
              : e,
      ]);

  Future<void> clearAll() async {
    await _store.remove(storageKey);
    state = const [];
  }
}

final eventsProvider = NotifierProvider<EventsController, List<DateiEvent>>(EventsController.new);

final eventByIdProvider = Provider.family<DateiEvent?, String>((ref, id) {
  for (final e in ref.watch(eventsProvider)) {
    if (e.id == id) return e;
  }
  return null;
});
