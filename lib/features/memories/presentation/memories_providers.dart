import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_providers.dart';
import '../../milestones/data/drift_milestones_repository.dart';
import '../../milestones/domain/milestone.dart';
import '../../projects/data/drift_projects_repository.dart';
import '../../projects/domain/project.dart';
import '../data/drift_memories_repository.dart';
import '../domain/memory.dart';

final memoriesRepositoryProvider = Provider<MemoriesRepository>((ref) => DriftMemoriesRepository(
      ref.watch(appDatabaseProvider),
      ref.watch(currentProfileIdProvider),
      ref.watch(attachmentStoreProvider),
    ));
final memoriesStreamProvider = StreamProvider<List<Memory>>((ref) => ref.watch(memoriesRepositoryProvider).watchAll());
final memoriesProvider = Provider<List<Memory>>((ref) => ref.watch(memoriesStreamProvider).value ?? const []);
final memoryByIdProvider = Provider.family<Memory?, String>(
  (ref, id) => ref.watch(memoriesProvider).where((m) => m.id == id).firstOrNull,
);
final tagNamesProvider = StreamProvider<List<String>>((ref) => ref.watch(memoriesRepositoryProvider).watchTagNames());

final milestonesRepositoryProvider = Provider<MilestonesRepository>(
  (ref) => DriftMilestonesRepository(ref.watch(appDatabaseProvider), ref.watch(currentProfileIdProvider)),
);
final milestonesStreamProvider = StreamProvider<List<Milestone>>((ref) => ref.watch(milestonesRepositoryProvider).watchAll());
final milestonesProvider = Provider<List<Milestone>>((ref) => ref.watch(milestonesStreamProvider).value ?? const []);
final milestoneByIdProvider = Provider.family<Milestone?, String>(
  (ref, id) => ref.watch(milestonesProvider).where((m) => m.id == id).firstOrNull,
);

final projectsRepositoryProvider = Provider<ProjectsRepository>(
  (ref) => DriftProjectsRepository(ref.watch(appDatabaseProvider), ref.watch(currentProfileIdProvider)),
);
final projectsStreamProvider = StreamProvider<List<Project>>((ref) => ref.watch(projectsRepositoryProvider).watchAll());
final projectsProvider = Provider<List<Project>>((ref) => ref.watch(projectsStreamProvider).value ?? const []);
final projectByIdProvider = Provider.family<Project?, String>(
  (ref, id) => ref.watch(projectsProvider).where((p) => p.id == id).firstOrNull,
);
