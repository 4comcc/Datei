import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:uuid/uuid.dart';

import '../../../core/time_engine/local_date.dart';
import '../../../shared/l10n_labels.dart';
import '../../../shared/widgets/date_field.dart';
import '../../agenda/agenda.dart';
import '../data/people_repository.dart';
import '../domain/person.dart';

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
  late final TextEditingController _occupation;
  late final TextEditingController _notes;
  LocalDate? _birthDate;
  late Set<PersonCategory> _categories;
  Person? _existing;
  bool _saving = false;

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void initState() {
    super.initState();
    _existing = widget.personId == null ? null : ref.read(personByIdProvider(widget.personId!));
    final p = _existing;
    _fullName = TextEditingController(text: p?.fullName);
    _displayName = TextEditingController(text: p?.displayName);
    _phone = TextEditingController(text: p?.phone);
    _email = TextEditingController(text: p?.email);
    _occupation = TextEditingController(text: p?.occupation);
    _notes = TextEditingController(text: p?.notes);
    _birthDate = p?.birthDate;
    _categories = {...?p?.categories};
  }

  @override
  void dispose() {
    for (final c in [_fullName, _displayName, _phone, _email, _occupation, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _trimOrNull(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final person = Person(
      id: _existing?.id ?? const Uuid().v4(),
      fullName: _fullName.text.trim(),
      displayName: _trimOrNull(_displayName),
      birthDate: _birthDate,
      phone: _trimOrNull(_phone),
      email: _trimOrNull(_email),
      occupation: _trimOrNull(_occupation),
      notes: _trimOrNull(_notes),
      categories: PersonCategory.values.where(_categories.contains).toList(),
      createdAt: _existing?.createdAt ?? DateTime.now(),
    );
    await ref.read(peopleProvider.notifier).upsert(person);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.savedSuccessfully)));
    if (_existing == null) {
      context.pushReplacement('/people/${person.id}');
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final today = ref.watch(todayProvider);
    const gap = SizedBox(height: 14);
    return Scaffold(
      appBar: AppBar(title: Text(_existing == null ? l.addPerson : l.editPerson)),
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
              label: l.fieldBirthDate,
              initialValue: _birthDate,
              lastDate: today,
              onChanged: (v) => setState(() => _birthDate = v),
              validator: (v) => v != null && v.isAfter(today) ? l.errorFutureBirthDate : null,
            ),
            gap,
            Text(l.fieldCategories, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final c in PersonCategory.values)
                  FilterChip(
                    label: Text(c.label(l)),
                    selected: _categories.contains(c),
                    onSelected: (s) => setState(() => s ? _categories.add(c) : _categories.remove(c)),
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
              controller: _notes,
              minLines: 3,
              maxLines: 6,
              decoration: InputDecoration(labelText: l.fieldNotes, alignLabelWithHint: true),
            ),
            const SizedBox(height: 24),
            FilledButton(
              key: const Key('person-save'),
              onPressed: _saving ? null : _save,
              child: Text(l.save),
            ),
          ],
        ),
      ),
    );
  }
}
