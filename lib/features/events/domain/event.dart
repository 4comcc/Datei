import '../../../core/time_engine/local_date.dart';

enum EventType {
  anniversary,
  appointment,
  travel,
  graduation,
  achievement,
  family,
  religious,
  personal,
  other,
}

class DateiEvent {
  const DateiEvent({
    required this.id,
    required this.title,
    required this.type,
    required this.date,
    required this.createdAt,
    this.time,
    this.repeatsYearly = false,
    this.personIds = const [],
    this.location,
    this.notes,
  });

  factory DateiEvent.fromJson(Map<String, dynamic> json) => DateiEvent(
        id: json['id'] as String,
        title: json['title'] as String,
        type: EventType.values.asNameMap()[json['type']] ?? EventType.other,
        date: LocalDate.parse(json['date'] as String),
        time: json['time'] as String?,
        repeatsYearly: json['repeatsYearly'] as bool? ?? false,
        personIds: (json['personIds'] as List<dynamic>? ?? const []).cast<String>(),
        location: json['location'] as String?,
        notes: json['notes'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  final String id;
  final String title;
  final EventType type;
  final LocalDate date;

  /// Optional `HH:mm` (local wall time).
  final String? time;
  final bool repeatsYearly;
  final List<String> personIds;
  final String? location;
  final String? notes;
  final DateTime createdAt;

  DateiEvent copyWith({List<String>? personIds}) => DateiEvent(
        id: id,
        title: title,
        type: type,
        date: date,
        time: time,
        repeatsYearly: repeatsYearly,
        personIds: personIds ?? this.personIds,
        location: location,
        notes: notes,
        createdAt: createdAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'type': type.name,
        'date': date.toIso(),
        'time': time,
        'repeatsYearly': repeatsYearly,
        'personIds': personIds,
        'location': location,
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
      };
}
