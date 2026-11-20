import 'dart:io';

import 'package:uuid/uuid.dart';

/// A file copied into the app's private storage.
class StoredFile {
  const StoredFile({required this.relativePath, required this.sizeBytes, required this.mimeType});
  final String relativePath;
  final int sizeBytes;
  final String mimeType;
}

/// Keeps user attachments (photos) inside the app's documents directory and
/// refers to them by relative path, so backups and device moves stay portable.
abstract interface class AttachmentStore {
  Future<StoredFile> importFile(String sourcePath);
  File fileFor(String relativePath);
  Future<void> delete(String relativePath);
  Future<void> deleteAll();
}

class LocalAttachmentStore implements AttachmentStore {
  LocalAttachmentStore(this.rootPath);

  /// Absolute directory that holds the `attachments/` folder.
  final String rootPath;

  static String _mimeFor(String path) {
    final ext = path.split('.').last.toLowerCase();
    return switch (ext) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'webp' => 'image/webp',
      'heic' => 'image/heic',
      'gif' => 'image/gif',
      _ => 'application/octet-stream',
    };
  }

  @override
  Future<StoredFile> importFile(String sourcePath) async {
    final source = File(sourcePath);
    final ext = sourcePath.contains('.') ? sourcePath.split('.').last.toLowerCase() : 'bin';
    final relative = 'attachments/${const Uuid().v4()}.$ext';
    final target = fileFor(relative);
    await target.parent.create(recursive: true);
    await source.copy(target.path);
    return StoredFile(relativePath: relative, sizeBytes: await target.length(), mimeType: _mimeFor(sourcePath));
  }

  @override
  File fileFor(String relativePath) {
    if (relativePath.contains('..')) throw ArgumentError('Invalid attachment path');
    return File('$rootPath/$relativePath');
  }

  @override
  Future<void> delete(String relativePath) async {
    final f = fileFor(relativePath);
    if (await f.exists()) await f.delete();
  }

  @override
  Future<void> deleteAll() async {
    final dir = Directory('$rootPath/attachments');
    if (await dir.exists()) await dir.delete(recursive: true);
  }
}
