import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:uuid/uuid.dart';

import '../../../core/time_engine/local_date.dart';
import '../../../shared/l10n_labels.dart';
import '../../events/domain/event.dart';
import '../../events/presentation/events_providers.dart';
import '../../memories/presentation/memories_providers.dart';
import '../../people/presentation/category_dialogs.dart';
import '../../people/presentation/people_providers.dart';
import '../domain/search.dart';
import 'search_providers.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _text = TextEditingController(text: ref.read(searchQueryProvider).text);

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  SearchQuery get _q => ref.read(searchQueryProvider);
  void _set(SearchQuery q) => ref.read(searchQueryProvider.notifier).set(q);

  String _typeLabel(SearchEntityType t) {
    final l = context.l10n;
    return switch (t) {
      SearchEntityType.person => l.typePerson,
      SearchEntityType.event => l.typeEvent,
      SearchEntityType.commitment => l.typeCommitment,
      SearchEntityType.memory => l.typeMemory,
      SearchEntityType.milestone => l.typeMilestone,
      SearchEntityType.project => l.typeProject,
    };
  }

  IconData _typeIcon(SearchEntityType t) => switch (t) {
        SearchEntityType.person => Icons.person_outline,
        SearchEntityType.event => Icons.event_note_outlined,
        SearchEntityType.commitment => Icons.autorenew,
        SearchEntityType.memory => Icons.auto_stories_outlined,
        SearchEntityType.milestone => Icons.flag_outlined,
        SearchEntityType.project => Icons.rocket_launch_outlined,
      };

  String _conditionLabel(SearchCondition c) {
    final l = context.l10n;
    return switch (c) {
      DateRangeCondition(:final from, :final to) =>
        '${l.condDateRange}: ${from == null ? l.anyDate : context.formatDate(from)} – ${to == null ? l.anyDate : context.formatDate(to)}',
      PersonCondition(:final personId) => '${l.condPerson}: ${ref.read(personByIdProvider(personId))?.shownName ?? '?'}',
      EventTypeCondition(:final typeId) => '${l.condEventType}: ${ref.read(eventTypeByIdProvider)[typeId]?.label(l) ?? '?'}',
      CategoryCondition(:final categoryId) => '${l.condCategory}: ${ref.read(categoryByIdProvider)[categoryId]?.label(l) ?? '?'}',
      AgeRangeCondition(:final min, :final max) =>
        l.ageBetween('\u2066${min ?? 0}', max == null ? '∞\u2069' : '$max\u2069'),
      PriorityCondition(:final priority) => '${l.condPriority}: ${priority.label(l)}',
      TimeStateCondition(:final state) => '${l.condTimeState}: ${switch (state) {
          TimeState.upcoming => l.timeUpcoming,
          TimeState.past => l.timePast,
          TimeState.overdue => l.timeOverdue,
        }}',
      RecurringCondition() => l.condRecurring,
      TagCondition(:final tag) => '#$tag',
    };
  }

  Future<void> _addCondition() async {
    final c = await showModalBottomSheet<SearchCondition>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => const _ConditionPicker(),
    );
    if (c != null) _set(_q.copyWith(conditions: [..._q.conditions, c]));
  }

  Future<void> _save() async {
    final l = context.l10n;
    final name = await showTextInputDialog(context, title: l.saveSearch, label: l.filterName, fieldKey: const Key('search-name'));
    if (name == null || name.isEmpty) return;
    await ref.read(savedSearchesRepositoryProvider).save(SavedSearch(id: const Uuid().v4(), name: name, query: _q));
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.searchSaved)));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final q = ref.watch(searchQueryProvider);
    final results = ref.watch(searchResultsProvider);
    final saved = ref.watch(savedSearchesProvider).value ?? const <SavedSearch>[];
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          key: const Key('search-field'),
          controller: _text,
          autofocus: true,
          decoration: InputDecoration(hintText: l.searchHint, border: InputBorder.none, filled: false),
          onChanged: (v) => _set(_q.copyWith(text: v)),
        ),
        actions: [
          if (q.conditions.isNotEmpty || q.types.isNotEmpty)
            IconButton(key: const Key('search-save'), tooltip: l.saveSearch, icon: const Icon(Icons.bookmark_add_outlined), onPressed: _save),
        ],
      ),
      body: ListView(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 32),
        children: [
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              for (final t in SearchEntityType.values)
                FilterChip(
                  key: Key('search-type-${t.name}'),
                  avatar: Icon(_typeIcon(t), size: 18),
                  label: Text(_typeLabel(t)),
                  selected: q.types.contains(t),
                  onSelected: (s) => _set(q.copyWith(types: s ? {...q.types, t} : ({...q.types}..remove(t)))),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(l.advancedFilters, style: Theme.of(context).textTheme.labelLarge),
              const Spacer(),
              if (q.conditions.length > 1)
                SegmentedButton<bool>(
                  showSelectedIcon: false,
                  segments: [ButtonSegment(value: true, label: Text(l.matchAll)), ButtonSegment(value: false, label: Text(l.matchAny))],
                  selected: {q.matchAll},
                  onSelectionChanged: (s) => _set(q.copyWith(matchAll: s.first)),
                ),
            ],
          ),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              for (final (i, c) in q.conditions.indexed)
                InputChip(
                  label: Text(_conditionLabel(c)),
                  onDeleted: () => _set(q.copyWith(conditions: [...q.conditions]..removeAt(i))),
                ),
              ActionChip(
                key: const Key('add-condition'),
                avatar: const Icon(Icons.add, size: 18),
                label: Text(l.addCondition),
                onPressed: _addCondition,
              ),
            ],
          ),
          if (q.conditions.length > 1)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(l.matchHint, style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
            ),
          if (saved.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                for (final s in saved)
                  GestureDetector(
                    onLongPress: () async {
                      if (await confirmDialog(context, title: l.confirmDeleteTitle, message: l.deleteSavedSearchConfirm(s.name))) {
                        await ref.read(savedSearchesRepositoryProvider).delete(s.id);
                      }
                    },
                    child: ActionChip(
                      avatar: const Icon(Icons.bookmark_outline, size: 18),
                      label: Text(s.name),
                      onPressed: () => _set(s.query.copyWith(text: _text.text)),
                    ),
                  ),
              ],
            ),
          ],
          const Divider(height: 24),
          if (q.isEmpty)
            Padding(padding: const EdgeInsets.all(24), child: Text(l.searchStart, textAlign: TextAlign.center))
          else ...[
            Text(l.resultsFound(results.length), style: TextStyle(color: scheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            for (final r in results)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Card(
                  child: ListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    leading: CircleAvatar(backgroundColor: scheme.secondaryContainer, child: Icon(_typeIcon(r.type), color: scheme.onSecondaryContainer)),
                    title: Text(r.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(
                      [_typeLabel(r.type), if (r.date != null) context.formatDate(r.date!), if (r.subtitle != null) r.subtitle!.split('\n').first]
                          .join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => context.push(r.route),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

/// Lets the user choose a condition type and its value.
class _ConditionPicker extends ConsumerStatefulWidget {
  const _ConditionPicker();

  @override
  ConsumerState<_ConditionPicker> createState() => _ConditionPickerState();
}

class _ConditionPickerState extends ConsumerState<_ConditionPicker> {
  final _min = TextEditingController();
  final _max = TextEditingController();
  LocalDate? _from;
  LocalDate? _to;

  @override
  void dispose() {
    _min.dispose();
    _max.dispose();
    super.dispose();
  }

  Future<LocalDate?> _pick(LocalDate? initial) async {
    final d = await showDatePicker(
      context: context,
      initialDate: (initial ?? LocalDate.today()).toDateTime(),
      firstDate: DateTime(1800),
      lastDate: DateTime(2200),
    );
    return d == null ? null : LocalDate.fromDateTime(d);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final people = ref.watch(peopleProvider);
    final types = ref.watch(eventTypesProvider).value ?? const <EventTypeInfo>[];
    final categories = ref.watch(categoriesProvider).value ?? const [];
    final tags = ref.watch(tagNamesProvider).value ?? const <String>[];
    void done(SearchCondition c) => Navigator.pop(context, c);
    Widget section(String title, List<Widget> chips) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(padding: const EdgeInsets.only(top: 12, bottom: 6), child: Text(title, style: Theme.of(context).textTheme.labelLarge)),
            Wrap(spacing: 6, runSpacing: 4, children: chips),
          ],
        );

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
          children: [
            Text(l.addCondition, style: Theme.of(context).textTheme.titleLarge),
            section(l.condTimeState, [
              for (final (s, label) in [(TimeState.upcoming, l.timeUpcoming), (TimeState.past, l.timePast), (TimeState.overdue, l.timeOverdue)])
                ActionChip(key: Key('cond-time-${s.name}'), label: Text(label), onPressed: () => done(TimeStateCondition(s))),
              ActionChip(key: const Key('cond-recurring'), label: Text(l.condRecurring), onPressed: () => done(const RecurringCondition())),
            ]),
            section(l.condDateRange, [
              ActionChip(
                label: Text('${l.dateFrom}: ${_from == null ? l.anyDate : context.formatDate(_from!)}'),
                onPressed: () async {
                  final d = await _pick(_from);
                  setState(() => _from = d);
                },
              ),
              ActionChip(
                label: Text('${l.dateTo}: ${_to == null ? l.anyDate : context.formatDate(_to!)}'),
                onPressed: () async {
                  final d = await _pick(_to);
                  setState(() => _to = d);
                },
              ),
              FilledButton.tonal(
                onPressed: _from == null && _to == null ? null : () => done(DateRangeCondition(from: _from, to: _to)),
                child: Text(l.add),
              ),
            ]),
            section(l.condPriority, [
              for (final p in EventPriority.values) ActionChip(label: Text(p.label(l)), onPressed: () => done(PriorityCondition(p))),
            ]),
            section(l.condAge, [
              SizedBox(width: 80, child: TextField(controller: _min, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: l.minAge, isDense: true))),
              SizedBox(width: 80, child: TextField(controller: _max, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: l.maxAge, isDense: true))),
              FilledButton.tonal(
                onPressed: () {
                  final min = int.tryParse(_min.text.trim());
                  final max = int.tryParse(_max.text.trim());
                  if (min == null && max == null) return;
                  done(AgeRangeCondition(min: min, max: max));
                },
                child: Text(l.add),
              ),
            ]),
            if (people.isNotEmpty)
              section(l.condPerson, [for (final p in people) ActionChip(label: Text(p.shownName), onPressed: () => done(PersonCondition(p.id)))]),
            section(l.condEventType, [for (final t in types) ActionChip(label: Text(t.label(l)), onPressed: () => done(EventTypeCondition(t.id)))]),
            section(l.condCategory, [for (final c in categories) ActionChip(label: Text(c.label(l)), onPressed: () => done(CategoryCondition(c.id)))]),
            if (tags.isNotEmpty) section(l.condTag, [for (final t in tags) ActionChip(label: Text('#$t'), onPressed: () => done(TagCondition(t)))]),
          ],
        ),
      ),
    );
  }
}
