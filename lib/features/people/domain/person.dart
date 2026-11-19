import '../../../core/time_engine/local_date.dart';

enum Gender { male, female }

/// Leap year used as the stored year when only day/month of birth are known,
/// so that Feb 29 stays valid. Never displayed or used for age (see ADR-038).
const unknownBirthYearPlaceholder = 2000;

class Person {
  const Person({
    required this.id,
    required this.fullName,
    required this.createdAt,
    this.displayName,
    this.birthDate,
    this.birthYearKnown = true,
    this.gender,
    this.phone,
    this.email,
    this.address,
    this.occupation,
    this.organization,
    this.notes,
    this.categoryIds = const [],
    this.customFields = const {},
  });

  /// Reads the app's JSON shape. Also accepts the prototype v0.1 shape
  /// (`categories: ["family", ...]`), mapping keys to built-in category ids.
  factory Person.fromJson(Map<String, dynamic> json) => Person(
        id: json['id'] as String,
        fullName: json['fullName'] as String,
        displayName: json['displayName'] as String?,
        birthDate: json['birthDate'] == null ? null : LocalDate.parse(json['birthDate'] as String),
        birthYearKnown: json['birthYearKnown'] as bool? ?? true,
        gender: Gender.values.asNameMap()[json['gender']],
        phone: json['phone'] as String?,
        email: json['email'] as String?,
        address: json['address'] as String?,
        occupation: json['occupation'] as String?,
        organization: json['organization'] as String?,
        notes: json['notes'] as String?,
        categoryIds: [
          ...(json['categoryIds'] as List<dynamic>? ?? const []).cast<String>(),
          for (final key in (json['categories'] as List<dynamic>? ?? const []).cast<String>())
            'sys:category:$key',
        ],
        customFields: (json['customFields'] as Map<String, dynamic>? ?? const {}).cast<String, String>(),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  final String id;
  final String fullName;
  final String? displayName;

  /// Birth date; when [birthYearKnown] is false its year is [unknownBirthYearPlaceholder].
  final LocalDate? birthDate;
  final bool birthYearKnown;
  final Gender? gender;
  final String? phone;
  final String? email;
  final String? address;
  final String? occupation;
  final String? organization;
  final String? notes;
  final List<String> categoryIds;

  /// Custom field values keyed by field definition id.
  final Map<String, String> customFields;
  final DateTime createdAt;

  String get shownName => (displayName != null && displayName!.trim().isNotEmpty) ? displayName! : fullName;

  /// Birth date usable for age calculations (null when unknown or year unknown).
  LocalDate? get birthDateWithYear => birthYearKnown ? birthDate : null;

  Person copyWith({LocalDate? birthDate, bool? birthYearKnown, List<String>? categoryIds}) => Person(
        id: id,
        fullName: fullName,
        displayName: displayName,
        birthDate: birthDate ?? this.birthDate,
        birthYearKnown: birthYearKnown ?? this.birthYearKnown,
        gender: gender,
        phone: phone,
        email: email,
        address: address,
        occupation: occupation,
        organization: organization,
        notes: notes,
        categoryIds: categoryIds ?? this.categoryIds,
        customFields: customFields,
        createdAt: createdAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'displayName': displayName,
        'birthDate': birthDate?.toIso(),
        'birthYearKnown': birthYearKnown,
        'gender': gender?.name,
        'phone': phone,
        'email': email,
        'address': address,
        'occupation': occupation,
        'organization': organization,
        'notes': notes,
        'categoryIds': categoryIds,
        'customFields': customFields,
        'createdAt': createdAt.toIso8601String(),
      };
}
