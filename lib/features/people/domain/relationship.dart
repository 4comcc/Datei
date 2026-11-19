enum RelationshipType { father, mother, son, daughter, brother, sister, spouse, relative, friend, colleague, custom }

/// Directed relationship: [personId] is [type] of [relatedPersonId].
/// [relatedPersonId] null means "of me" (the device owner). Not mirrored automatically.
class Relationship {
  const Relationship({
    required this.id,
    required this.personId,
    required this.type,
    this.relatedPersonId,
    this.customLabel,
  });

  final String id;
  final String personId;
  final String? relatedPersonId;
  final RelationshipType type;
  final String? customLabel;

  bool get isToMe => relatedPersonId == null;
}
