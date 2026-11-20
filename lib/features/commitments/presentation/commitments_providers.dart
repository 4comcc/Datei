import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_providers.dart';
import '../data/drift_commitments_repository.dart';
import '../domain/commitment.dart';
import '../domain/commitments_repository.dart';

final commitmentsRepositoryProvider = Provider<CommitmentsRepository>(
  (ref) => DriftCommitmentsRepository(ref.watch(appDatabaseProvider), ref.watch(currentProfileIdProvider)),
);

final commitmentRulesProvider = Provider<CommitmentRules>((ref) => const CommitmentRules());

final commitmentsStreamProvider =
    StreamProvider<List<Commitment>>((ref) => ref.watch(commitmentsRepositoryProvider).watchAll());

final commitmentsProvider = Provider<List<Commitment>>((ref) => ref.watch(commitmentsStreamProvider).value ?? const []);

final commitmentByIdProvider = Provider.family<Commitment?, String>((ref, id) {
  for (final c in ref.watch(commitmentsProvider)) {
    if (c.id == id) return c;
  }
  return null;
});

final commitmentRenewalsProvider = StreamProvider.family<List<CommitmentRenewal>, String>(
  (ref, id) => ref.watch(commitmentsRepositoryProvider).watchRenewals(id),
);
