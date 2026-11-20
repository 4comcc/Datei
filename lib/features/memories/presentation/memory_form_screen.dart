import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/database_providers.dart';
import '../../../core/time_engine/local_date.dart';
import '../../../shared/l10n_labels.dart';
import '../../../shared/navigation.dart';
import '../../../shared/widgets/date_field.dart';
import '../../agenda/agenda.dart';
import '../../events/presentation/events_providers.dart';
import '../../people/presentation/people_providers.dart';
import '../domain/memory.dart';
import 'memories_providers.dart';
import 'memory_photo.dart';

/// Picks images from the system photo picker (no storage permission needed).
/// Overridable in tests.
final imageSourceProvider = Provider<Future<List<String>> Function()>((ref) => () async {
      final files = await ImagePicker().pickMultiImage(maxWidth: 1920, maxHeight: 1920, imageQuality: 82, limit: 10);
      return [for (final f in files) f.path];
    });

class MemoryFormScreen extends ConsumerStatefulWidget {
  const MemoryFormScreen({super.key, this.memoryId, this.initialPersonId});
  final String? memoryId;
  final String? initialPersonId;

  @override
  ConsumerState<MemoryFormScreen> createState() => _MemoryFormScreenState();
}

class _MemoryFormScreenState extends ConsumerState<MemoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _body;
  late final TextEditingController _category;
  final _tagInput = TextEditingController();
  late LocalDate? _date;
  String? _eventId;
  late Set<String> _personIds;
  late List<String> _tags;
  late List<MemoryPhoto> _photos;

  /// Files imported in this session; deleted again if the form is left without saving.
  final _imported = <String>{};
  Memory? _existing;
  bool _saved = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _existing = widget.memoryId == null ? null : ref.read(memoryByIdProvider(widget.memoryId!));
    final m = _existing;
    _title = TextEditingController(text: m?.title);
    _body = TextEditingController(text: m?.body);
    _category = TextEditingController(text: m?.category);
    _date = m?.date ?? ref.read(todayProvider);
    _eventId = m?.eventId;
    _personIds = {...?m?.personIds, ?widget.initialPersonId};
    _tags = [...?m?.tags];
    _photos = [...?m?.photos];
  }

  @override
  void dispose() {
    if (!_saved) {
      final store = ref.read(attachmentStoreProvider);
      for (final p in _imported) {
        store.delete(p);
      }
    }
    for (final c in [_title, _body, _category, _tagInput]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _addPhotos() async {
    final l = context.l10n;
    try {
      final paths = await ref.read(imageSourceProvider)();
      final store = ref.read(attachmentStoreProvider);
      for (final path in paths) {
        final stored = await store.importFile(path);
        _imported.add(stored.relativePath);
        _photos.add(MemoryPhoto(
          id: const Uuid().v4(),
          relativePath: stored.relativePath,
          mimeType: stored.mimeType,
          sizeBytes: stored.sizeBytes,
        ));
      }
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Photo import failed: $e');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.photosPickFailed)));
    }
  }

  void _addTag(String raw) {
    final t = raw.trim().replaceAll('#', '');
    if (t.isEmpty || _tags.any((x) => x.toLowerCase() == t.toLowerCase())) {
      _tagInput.clear();
      return;
    }
    setState(() {
      _tags.add(t);
      _tagInput.clear();
    });
  }

  Future<void> _save() async {
    if (_tagInput.text.trim().isNotEmpty) _addTag(_tagInput.text);
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    final memory = Memory(
      id: _existing?.id ?? const Uuid().v4(),
      title: _title.text.trim(),
      body: _body.text.trim().isEmpty ? null : _body.text.trim(),
      date: _date!,
      eventId: _eventId,
      category: _category.text.trim().isEmpty ? null : _category.text.trim(),
      personIds: _personIds.toList(),
      tags: _tags,
      photos: _photos,
      createdAt: _existing?.createdAt ?? DateTime.now(),
    );
    try {
      await ref.read(memoriesRepositoryProvider).save(memory);
      _saved = true;
      // Photos added and removed again before saving were never stored in the database.
      final kept = {for (final p in _photos) p.relativePath};
      final store = ref.read(attachmentStoreProvider);
      for (final path in _imported.where((p) => !kept.contains(p))) {
        await store.delete(path);
      }
    } catch (_) {
      if (mounted) setState(() => _busy = false);
      rethrow;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.savedSuccessfully)));
    if (_existing == null) {
      context.pushReplacement('/memories/${memory.id}');
    } else {
      context.popOrGo('/memories');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final people = ref.watch(peopleProvider);
    final events = ref.watch(eventsProvider);
    final allTags = ref.watch(tagNamesProvider).value ?? const <String>[];
    final suggestions = [for (final t in allTags) if (!_tags.any((x) => x.toLowerCase() == t.toLowerCase())) t];
    const gap = SizedBox(height: 14);
    return Scaffold(
      appBar: AppBar(
        title: Text(_existing == null ? l.addMemory : l.editMemory),
        actions: [TextButton(key: const Key('memory-save-top'), onPressed: _busy ? null : _save, child: Text(l.save))],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              key: const Key('memory-title'),
              controller: _title,
              decoration: InputDecoration(labelText: l.fieldTitle, prefixIcon: const Icon(Icons.title)),
              validator: (v) => (v == null || v.trim().isEmpty) ? l.errorRequired : null,
            ),
            gap,
            LocalDateFormField(
              label: l.fieldDate,
              initialValue: _date,
              clearable: false,
              onChanged: (v) => setState(() => _date = v),
              validator: (v) => v == null ? l.errorDateRequired : null,
            ),
            gap,
            TextFormField(
              controller: _body,
              minLines: 3,
              maxLines: 10,
              decoration: InputDecoration(labelText: l.fieldMemoryText, alignLabelWithHint: true),
            ),
            gap,
            Row(
              children: [
                Expanded(child: Text(l.photos, style: Theme.of(context).textTheme.labelLarge)),
                TextButton.icon(
                  key: const Key('add-photos'),
                  onPressed: _addPhotos,
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  label: Text(l.addPhotos),
                ),
              ],
            ),
            if (_photos.isNotEmpty)
              SizedBox(
                height: 96,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _photos.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (_, i) => Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox.square(dimension: 96, child: MemoryPhotoImage(photo: _photos[i], cacheWidth: 300)),
                      ),
                      PositionedDirectional(
                        top: 2,
                        end: 2,
                        child: IconButton.filledTonal(
                          visualDensity: VisualDensity.compact,
                          tooltip: l.removePhoto,
                          icon: const Icon(Icons.close, size: 16),
                          onPressed: () => setState(() => _photos.removeAt(i)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            gap,
            if (people.isNotEmpty) ...[
              Text(l.fieldLinkedPeople, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final p in people)
                    FilterChip(
                      label: Text(p.shownName),
                      selected: _personIds.contains(p.id),
                      onSelected: (s) => setState(() => s ? _personIds.add(p.id) : _personIds.remove(p.id)),
                    ),
                ],
              ),
              gap,
            ],
            DropdownButtonFormField<String?>(
              initialValue: events.any((e) => e.id == _eventId) ? _eventId : null,
              isExpanded: true,
              decoration: InputDecoration(labelText: l.fieldLinkedEvent, prefixIcon: const Icon(Icons.event_outlined)),
              items: [
                DropdownMenuItem(value: null, child: Text(l.noneOption)),
                for (final e in events) DropdownMenuItem(value: e.id, child: Text(e.title, overflow: TextOverflow.ellipsis)),
              ],
              onChanged: (v) => setState(() => _eventId = v),
            ),
            gap,
            Text(l.fieldTags, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                for (final t in _tags) InputChip(label: Text('#$t'), onDeleted: () => setState(() => _tags.remove(t))),
              ],
            ),
            TextField(
              key: const Key('memory-tag-input'),
              controller: _tagInput,
              decoration: InputDecoration(hintText: l.addTagHint, prefixIcon: const Icon(Icons.tag), isDense: true),
              onSubmitted: _addTag,
            ),
            if (suggestions.isNotEmpty) ...[
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                children: [for (final t in suggestions.take(8)) ActionChip(label: Text('#$t'), onPressed: () => _addTag(t))],
              ),
            ],
            gap,
            TextFormField(
              controller: _category,
              decoration: InputDecoration(labelText: l.fieldCategory, prefixIcon: const Icon(Icons.folder_outlined)),
            ),
            const SizedBox(height: 24),
            FilledButton(key: const Key('memory-save'), onPressed: _busy ? null : _save, child: Text(l.save)),
          ],
        ),
      ),
    );
  }
}
