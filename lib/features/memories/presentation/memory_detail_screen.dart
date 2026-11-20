import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../shared/l10n_labels.dart';
import '../../../shared/navigation.dart';
import '../../events/presentation/events_providers.dart';
import '../../people/presentation/category_dialogs.dart';
import '../../people/presentation/people_providers.dart';
import 'memories_providers.dart';
import 'memory_photo.dart';

class MemoryDetailScreen extends ConsumerWidget {
  const MemoryDetailScreen({super.key, required this.memoryId});
  final String memoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final m = ref.watch(memoryByIdProvider(memoryId));
    if (m == null) return Scaffold(appBar: AppBar(), body: Center(child: Text(l.noResults)));
    final event = m.eventId == null ? null : ref.watch(eventByIdProvider(m.eventId!));
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(tooltip: l.edit, icon: const Icon(Icons.edit_outlined), onPressed: () => context.push('/memories/${m.id}/edit')),
          IconButton(
            tooltip: l.delete,
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              if (!await confirmDialog(context, title: l.confirmDeleteTitle, message: l.confirmDeleteMemory(m.title))) return;
              await ref.read(memoriesRepositoryProvider).delete(m.id);
              if (context.mounted) context.popOrGo('/memories');
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 32),
        children: [
          Text(m.title, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(context.formatLongDate(m.date), style: TextStyle(color: theme.colorScheme.primary)),
          if (m.category != null) Text(m.category!, style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
          if (m.photos.isNotEmpty) ...[
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: m.photos.length == 1 ? 1 : 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: m.photos.length == 1 ? 4 / 3 : 1,
              children: [
                for (final (i, p) in m.photos.indexed)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                        builder: (_) => PhotoViewerScreen(photos: m.photos, initialIndex: i),
                      )),
                      child: MemoryPhotoImage(photo: p, cacheWidth: 600),
                    ),
                  ),
              ],
            ),
          ],
          if (m.body != null) ...[
            const SizedBox(height: 16),
            Text(m.body!, style: theme.textTheme.bodyLarge),
          ],
          const SizedBox(height: 16),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              for (final id in m.personIds)
                if (ref.watch(personByIdProvider(id)) case final p?)
                  ActionChip(
                    avatar: const Icon(Icons.person_outline, size: 16),
                    label: Text(p.shownName),
                    onPressed: () => context.push('/people/${p.id}'),
                  ),
              if (event != null)
                ActionChip(
                  avatar: const Icon(Icons.event_outlined, size: 16),
                  label: Text(event.title),
                  onPressed: () => context.push('/events/${event.id}/edit'),
                ),
              for (final t in m.tags) Chip(label: Text('#$t')),
            ],
          ),
        ],
      ),
    );
  }
}
