import '../../../core/time_engine/local_date.dart';

class MemoryPhoto {
  const MemoryPhoto({required this.id, required this.relativePath, required this.mimeType, required this.sizeBytes});
  final String id;
  final String relativePath;
  final String mimeType;
  final int sizeBytes;
}

class Memory {
  const Memory({
    required this.id,
    required this.title,
    required this.date,
    required this.createdAt,
    this.body,
    this.eventId,
    this.category,
    this.personIds = const [],
    this.tags = const [],
    this.photos = const [],
  });

  final String id;
  final String title;
  final String? body;
  final LocalDate date;
  final String? eventId;
  final String? category;
  final List<String> personIds;

  /// Tag names (case-insensitive unique).
  final List<String> tags;
  final List<MemoryPhoto> photos;
  final DateTime createdAt;
}

abstract interface class MemoriesRepository {
  /// Newest first.
  Stream<List<Memory>> watchAll();

  /// Saves the memory with its people, tags and photo list. Photos missing from
  /// [memory.photos] are removed (rows now, files after the transaction).
  Future<void> save(Memory memory);
  Future<void> delete(String id);

  /// All tag names in use, for suggestions.
  Stream<List<String>> watchTagNames();
}
