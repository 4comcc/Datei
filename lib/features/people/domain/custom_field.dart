enum CustomFieldType { text, number, date, url }

class CustomFieldDefinition {
  const CustomFieldDefinition({required this.id, required this.label, this.type = CustomFieldType.text, this.sortOrder = 0});

  final String id;
  final String label;
  final CustomFieldType type;
  final int sortOrder;
}
