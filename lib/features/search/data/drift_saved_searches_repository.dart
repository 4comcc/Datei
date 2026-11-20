import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_providers.dart';
import '../domain/search.dart';

/// Saved unified searches live in `saved_filters` with scope 'global'.
class DriftSavedSearchesRepository {
  DriftSavedSearchesRepository(this._db);
  final AppDatabase _db;

  Stream<List<SavedSearch>> watchAll() => (_db.select(_db.savedFilters)
        ..where((t) => t.scope.equals('global'))
        ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
      .watch()
      .map((rows) => [
            for (final r in rows)
              SavedSearch(id: r.id, name: r.name, query: SearchQuery.fromJson(jsonDecode(r.definition) as Map<String, dynamic>)),
          ]);

  Future<void> save(SavedSearch s) async {
    final name = s.name.trim();
    if (name.isEmpty) throw ArgumentError('Name is required');
    final now = nowUtcMs();
    await _db.into(_db.savedFilters).insertOnConflictUpdate(SavedFiltersCompanion.insert(
          id: s.id,
          scope: 'global',
          name: name,
          definition: jsonEncode(s.query.toJson()),
          createdAt: now,
          updatedAt: now,
        ));
  }

  Future<void> delete(String id) => (_db.delete(_db.savedFilters)..where((t) => t.id.equals(id))).go();
}
