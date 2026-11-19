import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:uuid/uuid.dart';

import '../../../core/time_engine/local_date.dart';
import '../../../shared/l10n_labels.dart';
import '../../../shared/widgets/date_field.dart';
import '../../people/data/people_repository.dart';
import '../data/events_repository.dart';
import '../domain/event.dart';

class EventFormScreen extends ConsumerStatefulWidget {
  const EventFormScreen({super.key, this.eventId, this.initialDate, this.initialPersonId});
  final String? eventId;
  final LocalDate? initialDate;
  final String? initialPersonId;

  @override
  ConsumerState<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends ConsumerState<EventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _location;
  late final TextEditingController _notes;
  late EventType _type;
  LocalDate? _date;
  TimeOfDay? _time;
  late bool _yearly;
  late Set<String> _personIds;
  DateiEvent? _existing;

  @override
  void initState() {
    super.initState();
    _existing = widget.eventId == null ? null : ref.read(eventByIdProvider(widget.eventId!));
    final e = _existing;
    _title = TextEditingController(text: e?.title);
    _location = TextEditingController(text: e?.location);
    _notes = TextEditingController(text: e?.notes);
    _type = e?.type ?? EventType.personal;
    _date = e?.date ?? widget.initialDate;
    if (e?.time case final t?) {
      final parts = t.split(':');
      _time = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }
    _yearly = e?.repeatsYearly ?? false;
    _personIds = {...?e?.personIds, ?widget.initialPersonId};
  }

  @override
  void dispose() {
    _title.dispose();
    _location.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(context: context, initialTime: _time ?? const TimeOfDay(hour: 9, minute: 0));
    if (t != null) setState(() => _time = t);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    String? trimOrNull(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();
    final event = DateiEvent(
      id: _existing?.id ?? const Uuid().v4(),
      title: _title.text.trim(),
      type: _type,
      date: _date!,
      time: _time == null
          ? null
          : '${_time!.hour.toString().padLeft(2, '0')}:${_time!.minute.toString().padLeft(2, '0')}',
      repeatsYearly: _yearly,
      personIds: _personIds.toList(),
      location: trimOrNull(_location),
      notes: trimOrNull(_notes),
      createdAt: _existing?.createdAt ?? DateTime.now(),
    );
    await ref.read(eventsProvider.notifier).upsert(event);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.savedSuccessfully)));
    context.pop();
  }

  Future<void> _delete() async {
    final l = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.confirmDeleteTitle),
        content: Text(l.confirmDeleteEvent(_existing!.title)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.delete)),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await ref.read(eventsProvider.notifier).delete(_existing!.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.deletedSuccessfully)));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final people = ref.watch(peopleProvider);
    const gap = SizedBox(height: 14);
    return Scaffold(
      appBar: AppBar(
        title: Text(_existing == null ? l.addEvent : l.editEvent),
        actions: [
          if (_existing != null)
            IconButton(tooltip: l.delete, icon: const Icon(Icons.delete_outline), onPressed: _delete),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              key: const Key('event-title'),
              controller: _title,
              decoration: InputDecoration(labelText: l.fieldTitle, prefixIcon: const Icon(Icons.title)),
              validator: (v) => (v == null || v.trim().isEmpty) ? l.errorRequired : null,
            ),
            gap,
            DropdownButtonFormField<EventType>(
              initialValue: _type,
              decoration: InputDecoration(labelText: l.fieldEventType, prefixIcon: Icon(_type.icon)),
              items: [
                for (final t in EventType.values) DropdownMenuItem(value: t, child: Text(t.label(l))),
              ],
              onChanged: (t) => setState(() => _type = t ?? _type),
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
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: _pickTime,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: l.fieldTime,
                  prefixIcon: const Icon(Icons.access_time),
                  suffixIcon: _time == null
                      ? null
                      : IconButton(
                          tooltip: l.clear, icon: const Icon(Icons.close), onPressed: () => setState(() => _time = null)),
                ),
                child: Text(_time == null ? l.notSet : _time!.format(context)),
              ),
            ),
            gap,
            SwitchListTile(
              contentPadding: const EdgeInsetsDirectional.only(start: 12, end: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: Theme.of(context).colorScheme.outline),
              ),
              secondary: const Icon(Icons.repeat),
              title: Text(l.fieldRepeatsYearly),
              value: _yearly,
              onChanged: (v) => setState(() => _yearly = v),
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
            TextFormField(
              controller: _location,
              decoration: InputDecoration(labelText: l.fieldLocation, prefixIcon: const Icon(Icons.place_outlined)),
            ),
            gap,
            TextFormField(
              controller: _notes,
              minLines: 3,
              maxLines: 6,
              decoration: InputDecoration(labelText: l.fieldNotes, alignLabelWithHint: true),
            ),
            const SizedBox(height: 24),
            FilledButton(key: const Key('event-save'), onPressed: _save, child: Text(l.save)),
          ],
        ),
      ),
    );
  }
}
