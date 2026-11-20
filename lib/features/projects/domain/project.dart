import '../../../core/time_engine/local_date.dart';
import '../../events/domain/event.dart' show EventPriority;

enum ProjectStatus { planned, active, onHold, done, cancelled }

class Project {
  const Project({
    required this.id,
    required this.name,
    required this.createdAt,
    this.description,
    this.startDate,
    this.dueDate,
    this.status = ProjectStatus.planned,
    this.priority = EventPriority.normal,
    this.notes,
    this.personIds = const [],
    this.eventIds = const [],
  });

  final String id;
  final String name;
  final String? description;
  final LocalDate? startDate;
  final LocalDate? dueDate;
  final ProjectStatus status;
  final EventPriority priority;
  final String? notes;
  final List<String> personIds;
  final List<String> eventIds;
  final DateTime createdAt;

  bool get isOpen => status == ProjectStatus.planned || status == ProjectStatus.active || status == ProjectStatus.onHold;

  /// Open and past its due date.
  bool isOverdue(LocalDate today) => isOpen && dueDate != null && dueDate!.isBefore(today);
}

abstract interface class ProjectsRepository {
  Stream<List<Project>> watchAll();
  Future<void> save(Project project);
  Future<void> delete(String id);
}
