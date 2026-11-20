import '../../../core/time_engine/local_date.dart';

enum MilestoneKind { firstSchoolDay, graduation, firstJob, marriage, newHome, achievement, projectStart, goalReached, custom }

class Milestone {
  const Milestone({
    required this.id,
    required this.title,
    required this.date,
    required this.createdAt,
    this.kind = MilestoneKind.custom,
    this.description,
    this.personId,
    this.projectId,
    this.eventId,
  });

  final String id;
  final String title;
  final String? description;
  final LocalDate date;
  final MilestoneKind kind;
  final String? personId;
  final String? projectId;
  final String? eventId;
  final DateTime createdAt;
}

abstract interface class MilestonesRepository {
  Stream<List<Milestone>> watchAll();
  Future<void> save(Milestone milestone);
  Future<void> delete(String id);
}
