import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/local_store.dart';
import '../../events/data/events_repository.dart';
import '../domain/person.dart';

class PeopleController extends Notifier<List<Person>> {
  static const storageKey = 'data.people';

  LocalStore get _store => ref.read(localStoreProvider);

  @override
  List<Person> build() {
    final items = ref.watch(localStoreProvider).readCollection(storageKey).map(Person.fromJson).toList();
    return _sorted(items);
  }

  List<Person> _sorted(List<Person> items) =>
      items..sort((a, b) => a.shownName.toLowerCase().compareTo(b.shownName.toLowerCase()));

  Future<void> upsert(Person person) async {
    final next = [...state.where((p) => p.id != person.id), person];
    await _store.writeCollection(storageKey, next.map((p) => p.toJson()).toList());
    state = _sorted(next);
  }

  Future<void> delete(String id) async {
    final next = state.where((p) => p.id != id).toList();
    await _store.writeCollection(storageKey, next.map((p) => p.toJson()).toList());
    state = next;
    await ref.read(eventsProvider.notifier).unlinkPerson(id);
  }

  Future<void> clearAll() async {
    await _store.remove(storageKey);
    state = const [];
  }
}

final peopleProvider = NotifierProvider<PeopleController, List<Person>>(PeopleController.new);

final personByIdProvider = Provider.family<Person?, String>((ref, id) {
  for (final p in ref.watch(peopleProvider)) {
    if (p.id == id) return p;
  }
  return null;
});
