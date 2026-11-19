import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:uuid/uuid.dart';

import '../../../shared/l10n_labels.dart';
import '../domain/person.dart';
import '../domain/relationship.dart';
import 'people_providers.dart';

/// "[person] is [type] of [me | other person]".
Future<void> showAddRelationshipSheet(BuildContext context, Person person) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _AddRelationshipSheet(person: person),
    );

const _me = '__me__';

class _AddRelationshipSheet extends ConsumerStatefulWidget {
  const _AddRelationshipSheet({required this.person});
  final Person person;

  @override
  ConsumerState<_AddRelationshipSheet> createState() => _AddRelationshipSheetState();
}

class _AddRelationshipSheetState extends ConsumerState<_AddRelationshipSheet> {
  final _formKey = GlobalKey<FormState>();
  RelationshipType _type = RelationshipType.friend;
  String? _target = _me;
  final _label = TextEditingController();

  @override
  void dispose() {
    _label.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(relationshipsRepositoryProvider).add(Relationship(
          id: const Uuid().v4(),
          personId: widget.person.id,
          relatedPersonId: _target == _me ? null : _target,
          type: _type,
          customLabel: _type == RelationshipType.custom ? _label.text.trim() : null,
        ));
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final others = ref.watch(peopleProvider).where((p) => p.id != widget.person.id).toList();
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16 + MediaQuery.viewInsetsOf(context).bottom),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.addRelationship, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Text(l.relationshipIs(widget.person.shownName), style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final t in RelationshipType.values)
                  ChoiceChip(
                    label: Text(t.label(l)),
                    selected: _type == t,
                    onSelected: (_) => setState(() => _type = t),
                  ),
              ],
            ),
            if (_type == RelationshipType.custom) ...[
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('relationship-label'),
                controller: _label,
                maxLength: 40,
                decoration: InputDecoration(labelText: l.customRelationshipLabel),
                validator: (v) => (v == null || v.trim().isEmpty) ? l.errorRequired : null,
              ),
            ],
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              key: const Key('relationship-target'),
              initialValue: _target,
              isExpanded: true,
              decoration: InputDecoration(labelText: l.relationshipOf, prefixIcon: const Icon(Icons.person_outline)),
              items: [
                DropdownMenuItem(value: _me, child: Text(l.relatedToMe)),
                for (final p in others) DropdownMenuItem(value: p.id, child: Text(p.shownName)),
              ],
              validator: (v) => v == null ? l.errorChoosePerson : null,
              onChanged: (v) => setState(() => _target = v),
            ),
            const SizedBox(height: 20),
            FilledButton(key: const Key('relationship-save'), onPressed: _submit, child: Text(l.save)),
          ],
        ),
      ),
    );
  }
}
