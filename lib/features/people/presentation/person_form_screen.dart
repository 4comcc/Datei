import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:uuid/uuid.dart';

import '../../../core/time_engine/local_date.dart';
import '../../../shared/l10n_labels.dart';
import '../../../shared/widgets/date_field.dart';
import '../../agenda/agenda.dart';
import '../domain/custom_field.dart';
import '../domain/person.dart';
import 'category_dialogs.dart';
import 'people_providers.dart';

class PersonFormScreen extends ConsumerStatefulWidget {
  const PersonFormScreen({super.key, this.personId});
  final String? personId;

  @override
  ConsumerState<PersonFormScreen> createState() => _PersonFormScreenState();
}

class _PersonFormScreenState extends ConsumerState<PersonFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullName;
  late final TextEditingController _displayName;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  late final TextEditingController _address;
  late final TextEditingController _occupation;
  late final TextEditingController _organization;
  late final TextEditingController _notes;
  final Map<String, TextEditingController> _customText = {};
  final Map<String, LocalDate?> _customDates = {};
  LocalDate? _birthDate;
  late bool _birthYearKnown;
  Gender? _gender;
  late Set<String> _categoryIds;
  Person? _existing;
  bool _saving = false;

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final _urlPattern = RegExp(r'^https?://\S+\.\S+$');

  @override
  void initState() {
    super.initState();
    _existing = widget.personId == null ? null : ref.read(personByIdProvider(widget.personId!));
    final p = _existing;
    _fullName = TextEditingController(text: p?.fullName);
    _displayName = TextEditingController(text: p?.displayName);
    _phone = TextEditingController(text: p?.phone);
    _email = TextEditingController(text: p?.email);
    _address = TextEditingController(text: p?.address);
    _occupation = TextEditingController(text: p?.occupation);
    _organization = TextEditingController(text: p?.organization);
    _notes = TextEditingController(text: p?.notes);
    _birthDate = p?.birthDate;
    _birthYearKnown = p?.birthYearKnown ?? true;
    _gender = p?.gender;
    _categoryIds = {...?p?.categoryIds};
  }

  @override
  void dispose() {
    for (final c in [_fullName, _displayName, _phone, _email, _address, _occupation, _organization, _notes,
      ..._customText.values]) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _controllerFor(CustomFieldDefinition d) =>
      _customText.putIfAbsent(d.id, () => TextEditingController(text: _existing?.customFields[d.id]));

  String? _trimOrNull(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();

  Future<void> _save(List<CustomFieldDefinition> fields) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final custom = <String, String>{};
    for (final d in fields) {
      final String? value;
      if (d.type == CustomFieldType.date) {
        value = _customDates.containsKey(d.id) ? _customDates[d.id]?.toIso() : _existing?.customFields[d.id];
      } else {
        value = _trimOrNull(_controllerFor(d));
      }
      if (value != null) custom[d.id] = value;
    }
    final person = Person(
      id: _existing?.id ?? const Uuid().v4(),
      fullName: _fullName.text.trim(),
      displayName: _trimOrNull(_displayName),
      birthDate: _birthDate,
      birthYearKnown: _birthDate == null ? true : _birthYearKnown,
      gender: _gender,
      phone: _trimOrNull(_phone),
      email: _trimOrNull(_email),
      address: _trimOrNull(_address),
      occupation: _trimOrNull(_occupation),
      organization: _trimOrNull(_organization),
      notes: _trimOrNull(_notes),
      categoryIds: _categoryIds.toList(),
      customFields: custom,
      createdAt: _existing?.createdAt ?? DateTime.now(),
    );
    try {
      await ref.read(peopleRepositoryProvider).save(person);
    } catch (e) {
      if (mounted) setState(() => _saving = false);
      rethrow;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.savedSuccessfully)));
    if (_existing == null) {
      context.pushReplacement('/people/${person.id}');
    } else {
      context.pop();
    }
  }

  Future<void> _addCategory() async {
    final created = await showCategoryEditor(context, ref);
    if (created != null) setState(() => _categoryIds.add(created.id));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final today = ref.watch(todayProvider);
    final categories = ref.watch(categoriesProvider).value ?? const [];
    final fields = ref.watch(customFieldDefinitionsProvider).value ?? const <CustomFieldDefinition>[];
    const gap = SizedBox(height: 14);
    return Scaffold(
      appBar: AppBar(
        title: Text(_existing == null ? l.addPerson : l.editPerson),
        actions: [
          TextButton(
            key: const Key('person-save-top'),
            onPressed: _saving ? null : () => _save(fields),
            child: Text(l.save),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              key: const Key('person-fullName'),
              controller: _fullName,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(labelText: l.fieldFullName, prefixIcon: const Icon(Icons.badge_outlined)),
              validator: (v) => (v == null || v.trim().isEmpty) ? l.errorRequired : null,
            ),
            gap,
            TextFormField(
              controller: _displayName,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(labelText: l.fieldDisplayName, prefixIcon: const Icon(Icons.short_text)),
            ),
            gap,
            LocalDateFormField(
              key: ValueKey('birth-$_birthYearKnown'),
              label: l.fieldBirthDate,
              initialValue: _birthDate,
              lastDate: today,
              showYear: _birthYearKnown,
              onChanged: (v) => setState(() => _birthDate = v),
              validator: (v) => v != null && _birthYearKnown && v.isAfter(today) ? l.errorFutureBirthDate : null,
            ),
            if (_birthDate != null)
              SwitchListTile(
                key: const Key('birth-year-unknown'),
                contentPadding: const EdgeInsetsDirectional.only(start: 4, end: 0),
                title: Text(l.birthYearUnknown),
                subtitle: Text(l.birthYearUnknownHint),
                value: !_birthYearKnown,
                onChanged: (v) => setState(() => _birthYearKnown = !v),
              ),
            gap,
            DropdownButtonFormField<Gender?>(
              initialValue: _gender,
              decoration: InputDecoration(labelText: l.fieldGender, prefixIcon: const Icon(Icons.wc_outlined)),
              items: [
                for (final g in <Gender?>[null, ...Gender.values])
                  DropdownMenuItem(value: g, child: Text(g.label(l))),
              ],
              onChanged: (g) => setState(() => _gender = g),
            ),
            gap,
            Text(l.fieldCategories, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final c in categories)
                  FilterChip(
                    label: Text(c.label(l)),
                    selected: _categoryIds.contains(c.id),
                    onSelected: (s) => setState(() => s ? _categoryIds.add(c.id) : _categoryIds.remove(c.id)),
                  ),
                ActionChip(
                  key: const Key('add-category-chip'),
                  avatar: const Icon(Icons.add, size: 18),
                  label: Text(l.addCategory),
                  onPressed: _addCategory,
                ),
              ],
            ),
            gap,
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              textDirection: TextDirection.ltr,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(labelText: l.fieldPhone, prefixIcon: const Icon(Icons.phone_outlined)),
            ),
            gap,
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              textDirection: TextDirection.ltr,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(labelText: l.fieldEmail, prefixIcon: const Icon(Icons.email_outlined)),
              validator: (v) =>
                  (v != null && v.trim().isNotEmpty && !_emailPattern.hasMatch(v.trim())) ? l.errorInvalidEmail : null,
            ),
            gap,
            TextFormField(
              controller: _occupation,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(labelText: l.fieldOccupation, prefixIcon: const Icon(Icons.work_outline)),
            ),
            gap,
            TextFormField(
              controller: _organization,
              textInputAction: TextInputAction.next,
              decoration:
                  InputDecoration(labelText: l.fieldOrganization, prefixIcon: const Icon(Icons.business_outlined)),
            ),
            gap,
            TextFormField(
              controller: _address,
              minLines: 1,
              maxLines: 3,
              decoration: InputDecoration(labelText: l.fieldAddress, prefixIcon: const Icon(Icons.home_outlined)),
            ),
            for (final d in fields) ...[
              gap,
              if (d.type == CustomFieldType.date)
                LocalDateFormField(
                  label: d.label,
                  initialValue: _customDates.containsKey(d.id)
                      ? _customDates[d.id]
                      : switch (_existing?.customFields[d.id]) {
                          final v? => _tryParseDate(v),
                          null => null,
                        },
                  onChanged: (v) => setState(() => _customDates[d.id] = v),
                )
              else
                TextFormField(
                  controller: _controllerFor(d),
                  keyboardType: switch (d.type) {
                    CustomFieldType.number => const TextInputType.numberWithOptions(decimal: true, signed: true),
                    CustomFieldType.url => TextInputType.url,
                    _ => TextInputType.text,
                  },
                  textDirection: d.type == CustomFieldType.url ? TextDirection.ltr : null,
                  decoration: InputDecoration(labelText: d.label, prefixIcon: const Icon(Icons.tune)),
                  validator: (v) {
                    final t = v?.trim() ?? '';
                    if (t.isEmpty) return null;
                    if (d.type == CustomFieldType.number && num.tryParse(t) == null) return l.errorInvalidNumber;
                    if (d.type == CustomFieldType.url && !_urlPattern.hasMatch(t)) return l.errorInvalidUrl;
                    return null;
                  },
                ),
            ],
            gap,
            TextFormField(
              controller: _notes,
              minLines: 3,
              maxLines: 6,
              decoration: InputDecoration(labelText: l.fieldNotes, alignLabelWithHint: true),
            ),
            const SizedBox(height: 24),
            FilledButton(
              key: const Key('person-save'),
              onPressed: _saving ? null : () => _save(fields),
              child: Text(l.save),
            ),
          ],
        ),
      ),
    );
  }

  static LocalDate? _tryParseDate(String s) {
    try {
      return LocalDate.parse(s);
    } on FormatException {
      return null;
    }
  }
}
