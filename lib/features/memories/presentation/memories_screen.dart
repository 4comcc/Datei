import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../shared/l10n_labels.dart';
import '../../../shared/widgets/common.dart';
import '../../people/presentation/people_providers.dart';
import '../domain/memory.dart';
import 'memories_providers.dart';
import 'memory_photo.dart';

class MemoriesScreen extends ConsumerWidget {
  const MemoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final memories = ref.watch(memoriesProvider);
    final loaded = ref.watch(memoriesStreamProvider).hasValue;
    return Scaffold(
      appBar: AppBar(title: Text(l.memories)),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('add-memory-fab'),
        onPressed: () => context.push('/memories/new'),
        icon: const Icon(Icons.add),
        label: Text(l.addMemory),
      ),
      body: !loaded
          ? const Center(child: CircularProgressIndicator())
          : memories.isEmpty
              ? EmptyState(icon: Icons.auto_stories_outlined, title: l.memoriesEmptyTitle, body: l.memoriesEmptyBody)
              : ListView.separated(
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 96),
                  itemCount: memories.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) => MemoryCard(memory: memories[i]),
                ),
    );
  }
}

class MemoryCard extends ConsumerWidget {
  const MemoryCard({super.key, required this.memory});
  final Memory memory;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final names = [
      for (final id in memory.personIds) ?ref.watch(personByIdProvider(id))?.shownName,
    ];
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/memories/${memory.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (memory.photos.isNotEmpty)
              AspectRatio(aspectRatio: 16 / 9, child: MemoryPhotoImage(photo: memory.photos.first, cacheWidth: 900)),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(memory.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(
                    [
                      context.formatLongDate(memory.date),
                      if (memory.photos.length > 1) l.photoCount(memory.photos.length),
                    ].join(' · '),
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  if (memory.body != null) ...[
                    const SizedBox(height: 6),
                    Text(memory.body!, maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                  if (names.isNotEmpty || memory.tags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        for (final n in names) Chip(avatar: const Icon(Icons.person_outline, size: 16), label: Text(n), visualDensity: VisualDensity.compact),
                        for (final t in memory.tags) Chip(label: Text('#$t'), visualDensity: VisualDensity.compact),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
