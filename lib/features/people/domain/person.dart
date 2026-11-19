import '../../../core/time_engine/local_date.dart';

enum PersonCategory { family, relatives, friends, colleagues, clients, other }

class Person {
  const Person({
    required this.id,
    required this.fullName,
    required this.createdAt,
    this.displayName,
    this.birthDate,
    this.phone,
    this.email,
    this.occupation,
    this.notes,
    this.categories = const [],
  });

  factory Person.fromJson(Map<String, dynamic> json) => Person(
        id: json['id'] as String,
        fullName: json['fullName'] as String,
        displayName: json['displayName'] as String?,
        birthDate: json['birthDate'] == null ? null : LocalDate.parse(json['birthDate'] as String),
        phone: json['phone'] as String?,
        email: json['email'] as String?,
        occupation: json['occupation'] as String?,
        notes: json['notes'] as String?,
        categories: [
          for (final c in (json['categories'] as List<dynamic>? ?? const []))
            ?PersonCategory.values.asNameMap()[c],
        ],
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  final String id;
  final String fullName;
  final String? displayName;
  final LocalDate? birthDate;
  final String? phone;
  final String? email;
  final String? occupation;
  final String? notes;
  final List<PersonCategory> categories;
  final DateTime createdAt;

  String get shownName =>
      (displayName != null && displayName!.trim().isNotEmpty) ? displayName! : fullName;

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'displayName': displayName,
        'birthDate': birthDate?.toIso(),
        'phone': phone,
        'email': email,
        'occupation': occupation,
        'notes': notes,
        'categories': categories.map((c) => c.name).toList(),
        'createdAt': createdAt.toIso8601String(),
      };
}
