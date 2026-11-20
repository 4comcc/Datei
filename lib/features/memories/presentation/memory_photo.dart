import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/database/database_providers.dart';
import '../domain/memory.dart';

/// Shows a stored photo; a neutral placeholder if the file is missing.
class MemoryPhotoImage extends ConsumerWidget {
  const MemoryPhotoImage({super.key, required this.photo, this.fit = BoxFit.cover, this.cacheWidth});
  final MemoryPhoto photo;
  final BoxFit fit;
  final int? cacheWidth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final file = ref.watch(attachmentStoreProvider).fileFor(photo.relativePath);
    final scheme = Theme.of(context).colorScheme;
    return Image.file(
      file,
      fit: fit,
      cacheWidth: cacheWidth,
      errorBuilder: (_, _, _) => ColoredBox(
        color: scheme.surfaceContainerHighest,
        child: Icon(Icons.broken_image_outlined, color: scheme.onSurfaceVariant),
      ),
    );
  }
}

/// Full-screen, zoomable photo viewer with swipe between photos.
class PhotoViewerScreen extends StatelessWidget {
  const PhotoViewerScreen({super.key, required this.photos, this.initialIndex = 0});
  final List<MemoryPhoto> photos;
  final int initialIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, foregroundColor: Colors.white),
      body: PageView.builder(
        controller: PageController(initialPage: initialIndex),
        itemCount: photos.length,
        itemBuilder: (_, i) => InteractiveViewer(
          maxScale: 5,
          child: Center(child: MemoryPhotoImage(photo: photos[i], fit: BoxFit.contain)),
        ),
      ),
    );
  }
}
