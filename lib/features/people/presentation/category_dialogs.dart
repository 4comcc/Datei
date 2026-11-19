import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../shared/l10n_labels.dart';
import '../../../shared/widgets/name_color_dialog.dart';
import '../domain/category.dart';
import 'people_providers.dart';

const categoryColors = pickerColors;

/// Creates (when [existing] is null) or edits a user category. Returns the saved category.
Future<PersonCategoryInfo?> showCategoryEditor(BuildContext context, WidgetRef ref, {PersonCategoryInfo? existing}) async {
  final l = context.l10n;
  final result = await showNameColorDialog(
    context,
    title: existing == null ? l.addCategory : l.editCategory,
    label: l.categoryName,
    initialName: existing?.name,
    initialColor: existing?.color,
  );
  if (result == null) return null;
  final (name, color) = result;
  final repo = ref.read(categoriesRepositoryProvider);
  if (existing == null) return repo.create(name, color: color);
  await repo.rename(existing.id, name, color: color);
  return PersonCategoryInfo(id: existing.id, name: name, color: color, sortOrder: existing.sortOrder);
}

Future<bool> confirmDialog(BuildContext context, {required String title, required String message, String? action}) async {
  final l = context.l10n;
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancel)),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(64, 40)),
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(action ?? l.delete),
        ),
      ],
    ),
  );
  return ok ?? false;
}

/// Asks for a single line of text. The dialog owns its controller, so it is
/// disposed only after the closing animation finishes.
Future<String?> showTextInputDialog(
  BuildContext context, {
  required String title,
  required String label,
  Key? fieldKey,
  int maxLength = 80,
}) =>
    showDialog<String>(
      context: context,
      builder: (_) => _TextInputDialog(title: title, label: label, fieldKey: fieldKey, maxLength: maxLength),
    );

class _TextInputDialog extends StatefulWidget {
  const _TextInputDialog({required this.title, required this.label, this.fieldKey, required this.maxLength});
  final String title;
  final String label;
  final Key? fieldKey;
  final int maxLength;

  @override
  State<_TextInputDialog> createState() => _TextInputDialogState();
}

class _TextInputDialogState extends State<_TextInputDialog> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) Navigator.pop(context, _controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: TextFormField(
          key: widget.fieldKey,
          controller: _controller,
          autofocus: true,
          maxLength: widget.maxLength,
          decoration: InputDecoration(labelText: widget.label),
          validator: (v) => (v == null || v.trim().isEmpty) ? l.errorRequired : null,
          onFieldSubmitted: (_) => _submit(),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
        FilledButton(
          key: const Key('text-input-save'),
          style: FilledButton.styleFrom(minimumSize: const Size(64, 40)),
          onPressed: _submit,
          child: Text(l.save),
        ),
      ],
    );
  }
}
