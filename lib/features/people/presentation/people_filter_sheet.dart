import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:uuid/uuid.dart';

import '../../../shared/l10n_labels.dart';
import '../domain/people_filter.dart';
import '../domain/relationship.dart';
import 'category_dialogs.dart';
import 'people_providers.dart';

Future<void> showPeopleFilterSheet(BuildContext context) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  useSafeArea: true,
  builder: (_) => const _PeopleFilterSheet(),
);

class _PeopleFilterSheet extends ConsumerStatefulWidget {
  const _PeopleFilterSheet();

  @override
  ConsumerState<_PeopleFilterSheet> createState() => _PeopleFilterSheetState();
}

class _PeopleFilterSheetState extends ConsumerState<_PeopleFilterSheet> {
  final _formKey = GlobalKey<FormState>();
  late PeopleFilter _draft;
  late final TextEditingController _minAge;
  late final TextEditingController _maxAge;
  late final TextEditingController _birthYear;
  late final TextEditingController _occupation;
  late final TextEditingController _organization;

  @override
  void initState() {
    super.initState();
    _draft = ref.read(peopleFilterProvider);
    _minAge = TextEditingController(text: _draft.minAge?.toString());
    _maxAge = TextEditingController(text: _draft.maxAge?.toString());
    _birthYear = TextEditingController(text: _draft.birthYear?.toString());
    _occupation = TextEditingController(text: _draft.occupation);
    _organization = TextEditingController(text: _draft.organization);
  }

  @override
  void dispose() {
    for (final c in [_minAge, _maxAge, _birthYear, _occupation, _organization]) {
      c.dispose();
    }
    super.dispose();
  }

  int? _int(TextEditingController c) => int.tryParse(c.text.trim());
  String? _text(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();

  PeopleFilter? _collect() {
    if (!_formKey.currentState!.validate()) return null;
    return _draft.copyWith(
      minAge: () => _int(_minAge),
      maxAge: () => _int(_maxAge),
      birthYear: () => _int(_birthYear),
      occupation: () => _text(_occupation),
      organization: () => _text(_organization),
    );
  }

  void _apply() {
    final f = _collect();
    if (f == null) return;
    ref.read(peopleFilterProvider.notifier).set(f);
    Navigator.pop(context);
  }

  void _clear() {
    ref.read(peopleFilterProvider.notifier).clearCriteria();
    Navigator.pop(context);
  }

  Future<void> _saveNamed() async {
    final f = _collect();
    if (f == null) return;
    final l = context.l10n;
    final name = await showTextInputDialog(
      context,
      title: l.saveFilter,
      label: l.filterName,
      fieldKey: const Key('filter-name'),
    );
    if (name == null || name.isEmpty) return;
    await ref
        .read(savedPeopleFiltersRepositoryProvider)
        .save(SavedPeopleFilter(id: const Uuid().v4(), name: name, filter: f));
    ref.read(peopleFilterProvider.notifier).set(f);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.filterSaved)));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final categories = ref.watch(categoriesProvider).value ?? const [];
    const gap = SizedBox(height: 14);
    String? intValidator(String? v, {int min = 0, int max = 150}) {
      final t = v?.trim() ?? '';
      if (t.isEmpty) return null;
      final n = int.tryParse(t);
      return (n == null || n < min || n > max) ? l.errorInvalidNumber : null;
    }

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 8),
                children: [
                  Text(l.filters, style: Theme.of(context).textTheme.titleLarge),
                  gap,
                  Text(l.fieldCategories, style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      for (final c in categories)
                        FilterChip(
                          label: Text(c.label(l)),
                          selected: _draft.categoryIds.contains(c.id),
                          onSelected: (s) => setState(
                            () => _draft = _draft.copyWith(
                              categoryIds: s ? {..._draft.categoryIds, c.id} : ({..._draft.categoryIds}..remove(c.id)),
                            ),
                          ),
                        ),
                    ],
                  ),
                  gap,
                  Text(l.ageRange, style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          key: const Key('filter-min-age'),
                          controller: _minAge,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(labelText: l.minAge, isDense: true),
                          validator: intValidator,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          key: const Key('filter-max-age'),
                          controller: _maxAge,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(labelText: l.maxAge, isDense: true),
                          validator: (v) {
                            final base = intValidator(v);
                            if (base != null) return base;
                            final min = _int(_minAge);
                            final max = int.tryParse(v?.trim() ?? '');
                            return (min != null && max != null && min > max) ? l.errorAgeRange : null;
                          },
                        ),
                      ),
                    ],
                  ),
                  gap,
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int?>(
                          initialValue: _draft.birthMonth,
                          isExpanded: true,
                          decoration: InputDecoration(labelText: l.birthMonth, isDense: true),
                          items: [
                            DropdownMenuItem(value: null, child: Text(l.anyValue)),
                            for (var m = 1; m <= 12; m++)
                              DropdownMenuItem(value: m, child: Text(context.formatMonthName(m))),
                          ],
                          onChanged: (v) => setState(() => _draft = _draft.copyWith(birthMonth: () => v)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<int?>(
                          initialValue: _draft.birthDay,
                          isExpanded: true,
                          decoration: InputDecoration(labelText: l.birthDayOfMonth, isDense: true),
                          items: [
                            DropdownMenuItem(value: null, child: Text(l.anyValue)),
                            for (var d = 1; d <= 31; d++) DropdownMenuItem(value: d, child: Text('$d')),
                          ],
                          onChanged: (v) => setState(() => _draft = _draft.copyWith(birthDay: () => v)),
                        ),
                      ),
                    ],
                  ),
                  gap,
                  TextFormField(
                    controller: _birthYear,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: l.birthYear, isDense: true),
                    validator: (v) => intValidator(v, min: 1800, max: 2200),
                  ),
                  gap,
                  Text(l.birthDateFilter, style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 6),
                  SegmentedButton<bool?>(
                    segments: [
                      ButtonSegment(value: null, label: Text(l.anyValue)),
                      ButtonSegment(value: true, label: Text(l.withBirthDate)),
                      ButtonSegment(value: false, label: Text(l.withoutBirthDate)),
                    ],
                    selected: {_draft.hasBirthDate},
                    onSelectionChanged: (s) => setState(() => _draft = _draft.copyWith(hasBirthDate: () => s.first)),
                  ),
                  gap,
                  DropdownButtonFormField<int?>(
                    initialValue: _draft.birthdayWithinDays,
                    decoration: InputDecoration(labelText: l.birthdayWithin, isDense: true),
                    items: [
                      DropdownMenuItem(value: null, child: Text(l.anyValue)),
                      for (final d in const [7, 30, 90]) DropdownMenuItem(value: d, child: Text(l.withinDays(d))),
                    ],
                    onChanged: (v) => setState(() => _draft = _draft.copyWith(birthdayWithinDays: () => v)),
                  ),
                  gap,
                  TextFormField(
                    controller: _occupation,
                    decoration: InputDecoration(labelText: l.fieldOccupation, isDense: true),
                  ),
                  gap,
                  TextFormField(
                    controller: _organization,
                    decoration: InputDecoration(labelText: l.fieldOrganization, isDense: true),
                  ),
                  gap,
                  DropdownButtonFormField<RelationshipType?>(
                    initialValue: _draft.relationType,
                    decoration: InputDecoration(labelText: l.relationshipFilter, isDense: true),
                    items: [
                      DropdownMenuItem(value: null, child: Text(l.anyValue)),
                      for (final t in RelationshipType.values) DropdownMenuItem(value: t, child: Text(t.label(l))),
                    ],
                    onChanged: (v) => setState(() => _draft = _draft.copyWith(relationType: () => v)),
                  ),
                ],
              ),
            ),
            // Actions stay visible below the scrolling criteria.
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 16),
              child: Column(
                children: [
                  FilledButton(key: const Key('filter-apply'), onPressed: _apply, child: Text(l.showResults)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(onPressed: _clear, child: Text(l.clearFilters)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          key: const Key('filter-save'),
                          onPressed: _saveNamed,
                          icon: const Icon(Icons.bookmark_add_outlined),
                          label: Text(l.saveFilter),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
