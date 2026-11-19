import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:uuid/uuid.dart';

import '../../../shared/l10n_labels.dart';
import '../../../shared/widgets/common.dart';
import '../domain/custom_field.dart';
import 'category_dialogs.dart';
import 'people_providers.dart';

class CustomFieldsScreen extends ConsumerWidget {
  const CustomFieldsScreen({super.key});

  Future<void> _edit(BuildContext context, WidgetRef ref, {CustomFieldDefinition? existing, int order = 0}) async {
    final def = await showDialog<CustomFieldDefinition>(
      context: context,
      builder: (_) => _FieldDialog(existing: existing, order: order),
    );
    if (def != null) await ref.read(customFieldsRepositoryProvider).saveDefinition(def);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final fields = ref.watch(customFieldDefinitionsProvider).value ?? const <CustomFieldDefinition>[];
    return Scaffold(
      appBar: AppBar(title: Text(l.customFieldsTitle)),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('add-custom-field'),
        onPressed: () => _edit(context, ref, order: fields.length),
        icon: const Icon(Icons.add),
        label: Text(l.addCustomField),
      ),
      body: ListView(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 96),
        children: [
          Padding(
            padding: const EdgeInsets.all(4),
            child: Text(l.customFieldsHint, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ),
          const SizedBox(height: 8),
          if (fields.isEmpty)
            InlineEmpty(l.noCustomFields)
          else
            Card(
              child: Column(
                children: [
                  for (final f in fields)
                    ListTile(
                      leading: const Icon(Icons.tune),
                      title: Text(f.label),
                      subtitle: Text(f.type.label(l)),
                      onTap: () => _edit(context, ref, existing: f),
                      trailing: IconButton(
                        tooltip: l.delete,
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async {
                          final ok = await confirmDialog(context,
                              title: l.confirmDeleteTitle, message: l.deleteCustomFieldConfirm(f.label));
                          if (ok) await ref.read(customFieldsRepositoryProvider).deleteDefinition(f.id);
                        },
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _FieldDialog extends StatefulWidget {
  const _FieldDialog({this.existing, required this.order});
  final CustomFieldDefinition? existing;
  final int order;

  @override
  State<_FieldDialog> createState() => _FieldDialogState();
}

class _FieldDialogState extends State<_FieldDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _label = TextEditingController(text: widget.existing?.label);
  late CustomFieldType _type = widget.existing?.type ?? CustomFieldType.text;

  @override
  void dispose() {
    _label.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      CustomFieldDefinition(
        id: widget.existing?.id ?? const Uuid().v4(),
        label: _label.text.trim(),
        type: _type,
        sortOrder: widget.existing?.sortOrder ?? widget.order,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AlertDialog(
      title: Text(widget.existing == null ? l.addCustomField : l.editCustomField),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              key: const Key('custom-field-label'),
              controller: _label,
              autofocus: true,
              maxLength: 80,
              decoration: InputDecoration(labelText: l.customFieldLabel),
              validator: (v) => (v == null || v.trim().isEmpty) ? l.errorRequired : null,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<CustomFieldType>(
              initialValue: _type,
              decoration: InputDecoration(labelText: l.customFieldType),
              items: [for (final t in CustomFieldType.values) DropdownMenuItem(value: t, child: Text(t.label(l)))],
              onChanged: (t) => setState(() => _type = t ?? _type),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
        FilledButton(
          key: const Key('custom-field-save'),
          style: FilledButton.styleFrom(minimumSize: const Size(64, 40)),
          onPressed: _submit,
          child: Text(l.save),
        ),
      ],
    );
  }
}
