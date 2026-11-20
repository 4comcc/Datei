import '../../../core/recurrence_engine/recurrence.dart';
import '../../../core/time_engine/local_date.dart';

/// Built-in event type keys; ids are `sys:event_type:<key>` (labels localized).
enum EventType {
  anniversary,
  appointment,
  travel,
  graduation,
  achievement,
  family,
  religious,
  personal,
  other;

  String get id => 'sys:event_type:$name';
  static EventType? fromId(String id) =>
      id.startsWith('sys:event_type:') ? EventType.values.asNameMap()[id.substring(15)] : null;
}

enum EventPriority { low, normal, high, critical }

enum EventStatus { planned, done, cancelled }

/// A built-in or user-created event type.
class EventTypeInfo {
  const EventTypeInfo({required this.id, this.systemKey, this.name, this.color, this.sortOrder = 0});
  final String id;
  final String? systemKey;
  final String? name;
  final int? color;
  final int sortOrder;

  bool get isSystem => systemKey != null;
  EventType? get builtIn => systemKey == null ? null : EventType.values.asNameMap()[systemKey];
}

/// Changes applied to one occurrence of a recurring event. Null fields keep the series value.
class OccurrenceOverride {
  const OccurrenceOverride({this.title, this.date, this.time, this.clearTime = false, this.location, this.notes});

  factory OccurrenceOverride.fromJson(Map<String, dynamic> j) => OccurrenceOverride(
        title: j['title'] as String?,
        date: j['date'] == null ? null : LocalDate.parse(j['date'] as String),
        time: j['time'] as String?,
        clearTime: j['clearTime'] as bool? ?? false,
        location: j['location'] as String?,
        notes: j['notes'] as String?,
      );

  final String? title;

  /// Moves the occurrence to another day.
  final LocalDate? date;
  final String? time;

  /// Makes this occurrence all-day even if the series has a time.
  final bool clearTime;
  final String? location;
  final String? notes;

  Map<String, dynamic> toJson() => {
        'title': ?title,
        'date': ?date?.toIso(),
        'time': ?time,
        if (clearTime) 'clearTime': true,
        'location': ?location,
        'notes': ?notes,
      };
}

class EventException {
  const EventException.cancelled(this.originalDate) : override = null;
  const EventException.overridden(this.originalDate, OccurrenceOverride this.override);

  final LocalDate originalDate;
  final OccurrenceOverride? override;
  bool get isCancelled => override == null;
}

class DateiEvent {
  const DateiEvent({
    required this.id,
    required this.title,
    required this.typeId,
    required this.date,
    required this.createdAt,
    this.time,
    this.endDate,
    this.endTime,
    this.recurrence,
    this.exceptions = const [],
    this.personIds = const [],
    this.location,
    this.notes,
    this.priority = EventPriority.normal,
    this.status = EventStatus.planned,
    this.reminderMinutes = const [],
  });

  /// Accepts the app's JSON and the prototype v0.1 shape (`type`, `repeatsYearly`).
  factory DateiEvent.fromJson(Map<String, dynamic> json) => DateiEvent(
        id: json['id'] as String,
        title: json['title'] as String,
        typeId: json['typeId'] as String? ?? (EventType.values.asNameMap()[json['type']] ?? EventType.other).id,
        date: LocalDate.parse(json['date'] as String),
        time: json['time'] as String?,
        endDate: json['endDate'] == null ? null : LocalDate.parse(json['endDate'] as String),
        endTime: json['endTime'] as String?,
        recurrence: (json['repeatsYearly'] as bool? ?? false) ? const RecurrenceRule.yearly() : null,
        personIds: (json['personIds'] as List<dynamic>? ?? const []).cast<String>(),
        location: json['location'] as String?,
        notes: json['notes'] as String?,
        priority: EventPriority.values.asNameMap()[json['priority']] ?? EventPriority.normal,
        status: EventStatus.values.asNameMap()[json['status']] ?? EventStatus.planned,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  final String id;
  final String title;
  final String typeId;

  /// Start date (first occurrence for recurring events).
  final LocalDate date;

  /// Optional `HH:mm` local wall time; null = all-day.
  final String? time;

  /// Optional last day of a multi-day event (>= [date]).
  final LocalDate? endDate;
  final String? endTime;
  final RecurrenceRule? recurrence;
  final List<EventException> exceptions;
  final List<String> personIds;
  final String? location;
  final String? notes;
  final EventPriority priority;
  final EventStatus status;

  /// Minutes before the start to remind (timed: before the time; all-day: before the
  /// default reminder time on the day, so 1440 = the day before).
  final List<int> reminderMinutes;
  final DateTime createdAt;

  bool get isRecurring => recurrence != null;
  bool get isAllDay => time == null;

  /// Extra days after the start covered by each occurrence (0 for single-day).
  int get spanDays => endDate == null ? 0 : date.daysUntil(endDate!).clamp(0, 3660);

  DateiEvent copyWith({
    String? id,
    LocalDate? date,
    LocalDate? Function()? endDate,
    RecurrenceRule? Function()? recurrence,
    List<EventException>? exceptions,
    List<String>? personIds,
    DateTime? createdAt,
  }) =>
      DateiEvent(
        id: id ?? this.id,
        title: title,
        typeId: typeId,
        date: date ?? this.date,
        time: time,
        endDate: endDate != null ? endDate() : this.endDate,
        endTime: endTime,
        recurrence: recurrence != null ? recurrence() : this.recurrence,
        exceptions: exceptions ?? this.exceptions,
        personIds: personIds ?? this.personIds,
        location: location,
        notes: notes,
        priority: priority,
        status: status,
        reminderMinutes: reminderMinutes,
        createdAt: createdAt ?? this.createdAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'typeId': typeId,
        'date': date.toIso(),
        'time': time,
        'endDate': endDate?.toIso(),
        'endTime': endTime,
        'personIds': personIds,
        'location': location,
        'notes': notes,
        'priority': priority.name,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
      };
}
