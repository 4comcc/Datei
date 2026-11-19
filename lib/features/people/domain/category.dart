/// A people category: built-in (has [systemKey], label localized) or user-created ([name]).
class PersonCategoryInfo {
  const PersonCategoryInfo({required this.id, this.systemKey, this.name, this.color, this.sortOrder = 0});

  final String id;
  final String? systemKey;
  final String? name;

  /// ARGB colour, optional.
  final int? color;
  final int sortOrder;

  bool get isSystem => systemKey != null;
}

String systemCategoryIdFor(String key) => 'sys:category:$key';
