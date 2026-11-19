import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:uuid/uuid.dart';

import '../../../core/recurrence_engine/recurrence.dart';
import '../../../core/time_engine/local_date.dart';
import '../../../shared/l10n_labels.dart';
import '../../../shared/navigation.dart';
import '../../../shared/widgets/date_field.dart';
import '../../people/presentation/category_dialogs.dart';
import '../../people/presentation/people_providers.dart';
import '../../settings/settings_controller.dart';
import '../domain/event.dart';
import '../domain/series_editing.dart';
import 'event_types_screen.dart';
import 'events_providers.dart';
import 'hijri_date_dialog.dart';
import 'recurrence_editor.dart';

/// Creates or edits an event. When opened from one occurrence of a recurring
/// event ([occurrenceDate]), saving and deleting ask for the edit scope.
class EventFormScreen extends ConsumerStatefulWidget {
  const EventFormScreen({super.key, this.eventId, this.initialDate, this.initialPersonId, this.occurrenceDate});
  final String? eventId;
  final LocalDate? initialDate;
  final String? initialPersonId;
  final LocalDate? occurrenceDate;

  @override
  ConsumerState<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends ConsumerState<EventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _location;
  late final TextEditingController _notes;
  late String _typeId;
  LocalDate? _date;
  TimeOfDay? _time;
  LocalDate? _endDate;
  TimeOfDay? _endTime;
  RecurrenceRule? _rule;
  late EventPriority _priority;
  late EventStatus _status;
  late Set<String> _personIds;
  DateiEvent? _existing;
  OccurrenceOverride? _override;
  bool _saving = false;

  /// True when editing one occurrence of a recurring series.
  bool get _isOccurrence => _existing?.isRecurring == true && widget.occurrenceDate != null;

  static TimeOfDay? _parseTime(String? t) {
    if (t == null) return null;
    final p = t.split(':');
    return TimeOfDay(hour: int.parse(p[0]), minute: int.parse(p[1]));
  }

  static String? _fmt(TimeOfDay? t) =>
      t == null ? null : '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  void initState() {
    super.initState();
    _existing = widget.eventId == null ? null : ref.read(eventByIdProvider(widget.eventId!));
    final e = _existing;
    if (_isOccurrence) {
      final ex = e!.exceptions.where((x) => x.originalDate == widget.occurrenceDate).firstOrNull;
      _override = ex?.override;
    }
    final o = _override;
    _title = TextEditingController(text: o?.title ?? e?.title);
    _location = TextEditingController(text: o?.location ?? e?.location);
    _notes = TextEditingController(text: o?.notes ?? e?.notes);
    _typeId = e?.typeId ?? EventType.personal.id;
    _date = _isOccurrence ? (o?.date ?? widget.occurrenceDate) : (e?.date ?? widget.initialDate);
    _time = (o?.clearTime ?? false) ? null : _parseTime(o?.time ?? e?.time);
    // Keep the multi-day span relative to the start that is shown.
    _endDate = (e == null || e.endDate == null) ? null : (_date ?? e.date).addDays(e.spanDays);
    _endTime = _parseTime(e?.endTime);
    _rule = e?.recurrence;
    _priority = e?.priority ?? EventPriority.normal;
    _status = e?.status ?? EventStatus.planned;
    _personIds = {...?e?.personIds, ?widget.initialPersonId};
  }

  @override
  void dispose() {
    _title.dispose();
    _location.dispose();
    _notes.dispose();
    super.dispose();
  }

  String? _trimOrNull(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();

  /// The event as entered in the form, with [start] as its start date.
  DateiEvent _fromForm({required String id, required LocalDate start, required DateTime createdAt}) {
    final span = _endDate == null ? 0 : _date!.daysUntil(_endDate!);
    return DateiEvent(
      id: id,
      title: _title.text.trim(),
      typeId: _typeId,
      date: start,
      time: _fmt(_time),
      endDate: span > 0 ? start.addDays(span) : null,
      endTime: span > 0 || _time != null ? _fmt(_endTime) : null,
      recurrence: _rule,
      personIds: _personIds.toList(),
      location: _trimOrNull(_location),
      notes: _trimOrNull(_notes),
      priority: _priority,
      status: _status,
      createdAt: createdAt,
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final repo = ref.read(eventsRepositoryProvider);
    final existing = _existing;
    setState(() => _saving = true);
    try {
      if (existing == null) {
        await repo.save(_fromForm(id: const Uuid().v4(), start: _date!, createdAt: DateTime.now()));
      } else if (!_isOccurrence) {
        await repo.save(_fromForm(id: existing.id, start: _date!, createdAt: existing.createdAt));
      } else {
        final scope = await showEditScopeDialog(context, delete: false);
        if (scope == null) {
          setState(() => _saving = false);
          return;
        }
        final occurrence = widget.occurrenceDate!;
        switch (scope) {
          case EditScope.thisOccurrence:
            await repo.overrideOccurrence(
              existing.id,
              occurrence,
              OccurrenceOverride(
                title: _title.text.trim() == existing.title ? null : _title.text.trim(),
                date: _date == occurrence ? null : _date,
                time: _time == null ? null : (_fmt(_time) == existing.time ? null : _fmt(_time)),
                clearTime: _time == null && existing.time != null,
                location: _trimOrNull(_location) == existing.location ? null : _trimOrNull(_location),
                notes: _trimOrNull(_notes) == existing.notes ? null : _trimOrNull(_notes),
              ),
            );
          case EditScope.thisAndFollowing:
            await repo.splitSeries(
              existing.id,
              occurrence,
              replacement: _fromForm(id: const Uuid().v4(), start: _date!, createdAt: DateTime.now()),
            );
          case EditScope.all:
            // Moving the shown occurrence by N days moves the whole series by N days.
            final shift = occurrence.daysUntil(_date!);
            await repo.save(_fromForm(id: existing.id, start: existing.date.addDays(shift), createdAt: existing.createdAt));
        }
      }
    } catch (_) {
      if (mounted) setState(() => _saving = false);
      rethrow;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.savedSuccessfully)));
    context.popOrGo('/events');
  }

  Future<void> _delete() async {
    final l = context.l10n;
    final existing = _existing!;
    final repo = ref.read(eventsRepositoryProvider);
    if (_isOccurrence) {
      final scope = await showEditScopeDialog(context, delete: true);
      if (scope == null) return;
      switch (scope) {
        case EditScope.thisOccurrence:
          await repo.cancelOccurrence(existing.id, widget.occurrenceDate!);
        case EditScope.thisAndFollowing:
          await repo.splitSeries(existing.id, widget.occurrenceDate!);
        case EditScope.all:
          await repo.delete(existing.id);
      }
    } else {
      if (!mounted) return;
      if (!await confirmDialog(context, title: l.confirmDeleteTitle, message: l.confirmDeleteEvent(existing.title))) return;
      await repo.delete(existing.id);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.deletedSuccessfully)));
    context.popOrGo('/events');
  }

  Future<void> _pickTime({required bool end}) async {
    final t = await showTimePicker(
      context: context,
      initialTime: (end ? _endTime : _time) ?? _time ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (t != null) setState(() => end ? _endTime = t : _time = t);
  }

  Future<void> _editRecurrence() async {
    final start = _date ?? LocalDate.today();
    final choice = await showRecurrenceEditor(context, rule: _rule, start: start);
    if (choice != null) setState(() => _rule = choice.rule);
  }

  Future<void> _hijriInput() async {
    final picked = await showHijriDateDialog(context, initial: _date);
    if (picked != null) setState(() => _date = picked);
  }

  Widget _timeField(String label, TimeOfDay? value, {required bool end}) {
    final l = context.l10n;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => _pickTime(end: end),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.access_time),
          suffixIcon: value == null
              ? null
              : IconButton(
                  tooltip: l.clear,
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => end ? _endTime = null : _time = null),
                ),
        ),
        child: Text(value == null ? l.notSet : value.format(context)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final people = ref.watch(peopleProvider);
    final types = ref.watch(eventTypesProvider).value ?? const <EventTypeInfo>[];
    final settings = ref.watch(settingsProvider);
    final hijri = ref.watch(hijriConverterProvider);
    final typeById = {for (final t in types) t.id: t};
    final currentType = typeById[_typeId];
    final hijriDate = _date == null ? null : hijri.fromGregorian(_date!);
    const gap = SizedBox(height: 14);

    return Scaffold(
      appBar: AppBar(
        title: Text(_existing == null ? l.addEvent : l.editEvent),
        actions: [
          if (_existing != null)
            IconButton(key: const Key('event-delete'), tooltip: l.delete, icon: const Icon(Icons.delete_outline), onPressed: _delete),
          TextButton(key: const Key('event-save-top'), onPressed: _saving ? null : _save, child: Text(l.save)),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_isOccurrence)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(l.occurrenceOf(context.formatLongDate(widget.occurrenceDate!)),
                    style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600)),
              ),
            TextFormField(
              key: const Key('event-title'),
              controller: _title,
              decoration: InputDecoration(labelText: l.fieldTitle, prefixIcon: const Icon(Icons.title)),
              validator: (v) => (v == null || v.trim().isEmpty) ? l.errorRequired : null,
            ),
            gap,
            DropdownButtonFormField<String>(
              key: ValueKey('type-$_typeId-${types.length}'),
              initialValue: typeById.containsKey(_typeId) ? _typeId : null,
              isExpanded: true,
              decoration: InputDecoration(labelText: l.fieldEventType, prefixIcon: Icon(currentType?.icon ?? Icons.event_note_outlined)),
              items: [
                for (final t in types) DropdownMenuItem(value: t.id, child: Text(t.label(l))),
                DropdownMenuItem(value: '__new__', child: Text('+ ${l.addEventType}')),
              ],
              onChanged: (v) async {
                if (v == '__new__') {
                  final created = await showEventTypeEditor(context, ref);
                  // Rebuild either way so the dropdown leaves the "new type" entry.
                  setState(() => _typeId = created?.id ?? _typeId);
                } else if (v != null) {
                  setState(() => _typeId = v);
                }
              },
            ),
            gap,
            LocalDateFormField(
              key: ValueKey('date-$_date'),
              label: l.fieldDate,
              initialValue: _date,
              clearable: false,
              onChanged: (v) => setState(() => _date = v),
              validator: (v) => v == null ? l.errorDateRequired : null,
            ),
            Row(
              children: [
                if (settings.showHijri && hijriDate != null)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(start: 12),
                      child: Text(l.formatHijri(hijriDate),
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    ),
                  )
                else
                  const Spacer(),
                TextButton.icon(
                  key: const Key('hijri-input'),
                  onPressed: _hijriInput,
                  icon: const Icon(Icons.nightlight_outlined, size: 18),
                  label: Text(l.hijriInput),
                ),
              ],
            ),
            _timeField(l.fieldTime, _time, end: false),
            gap,
            LocalDateFormField(
              key: ValueKey('end-$_endDate-$_date'),
              label: l.fieldEndDate,
              initialValue: _endDate,
              firstDate: _date,
              onChanged: (v) => setState(() => _endDate = v),
              validator: (v) => v != null && _date != null && v.isBefore(_date!) ? l.errorEndBeforeStart : null,
            ),
            if (_time != null || (_endDate != null && _endDate != _date)) ...[
              gap,
              FormField<TimeOfDay>(
                validator: (_) {
                  final sameDay = _endDate == null || _endDate == _date;
                  if (sameDay && _time != null && _endTime != null) {
                    final a = _time!.hour * 60 + _time!.minute;
                    final b = _endTime!.hour * 60 + _endTime!.minute;
                    if (b < a) return l.errorEndBeforeStart;
                  }
                  return null;
                },
                builder: (state) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _timeField(l.fieldEndTime, _endTime, end: true),
                    if (state.hasError)
                      Padding(
                        padding: const EdgeInsetsDirectional.only(start: 12, top: 4),
                        child: Text(state.errorText!, style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12)),
                      ),
                  ],
                ),
              ),
            ],
            gap,
            Card(
              child: ListTile(
                key: const Key('recurrence-tile'),
                leading: const Icon(Icons.repeat),
                title: Text(l.repeat),
                subtitle: Text(context.describeRecurrence(_rule, _date ?? LocalDate.today())),
                trailing: const Icon(Icons.chevron_right),
                onTap: _editRecurrence,
              ),
            ),
            gap,
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<EventPriority>(
                    initialValue: _priority,
                    isExpanded: true,
                    decoration: InputDecoration(labelText: l.fieldPriority, isDense: true),
                    items: [for (final p in EventPriority.values) DropdownMenuItem(value: p, child: Text(p.label(l)))],
                    onChanged: (v) => setState(() => _priority = v ?? _priority),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<EventStatus>(
                    initialValue: _status,
                    isExpanded: true,
                    decoration: InputDecoration(labelText: l.fieldStatus, isDense: true),
                    items: [for (final s in EventStatus.values) DropdownMenuItem(value: s, child: Text(s.label(l)))],
                    onChanged: (v) => setState(() => _status = v ?? _status),
                  ),
                ),
              ],
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
            FilledButton(key: const Key('event-save'), onPressed: _saving ? null : _save, child: Text(l.save)),
          ],
        ),
      ),
    );
  }
}
