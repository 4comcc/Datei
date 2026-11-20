import '../../../core/time_engine/local_date.dart';
import 'commitment.dart';

abstract interface class CommitmentsRepository {
  /// Live list of non-deleted commitments with their reminder offsets.
  Stream<List<Commitment>> watchAll();

  /// Renewal history of one commitment, newest first.
  Stream<List<CommitmentRenewal>> watchRenewals(String commitmentId);

  Future<void> save(Commitment commitment);
  Future<void> delete(String id);

  /// Records a renewal and moves the commitment's dates, in one transaction.
  Future<void> renew(String id, {required LocalDate newExpiry, int? amountMinor, String? currency, String? notes});
}
