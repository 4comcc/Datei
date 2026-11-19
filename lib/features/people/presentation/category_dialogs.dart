import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../shared/l10n_labels.dart';
import '../domain/category.dart';
import 'people_providers.dart';

const categoryColors = <int>[0xFF596B35, 0xFF788B4A, 0xFFB08A2E, 0xFF8C5A3C, 0xFF3F6F7A, 0xFF6B5B95, 0xFFA34E5C, 0xFF5E6452];

/// Creates (when [existing] is null) or edits a user category. Returns the saved category.
Future<PersonCategoryInfo?> showCategoryEditor(BuildContext context, WidgetRef ref, {PersonCategoryInfo? existing}) {
  return showDialog<PersonCategoryInfo>(
    context: context,
    builder: (_) => _CategoryEditorDialog(existing: existing),
  );
}

class _CategoryEditorDialog extends ConsumerStatefulWidget {
  const _CategoryEditorDialog({this.existing});
  final PersonCategoryInfo? existing;

  @override
  ConsumerState<_CategoryEditorDialog> createState() => _CategoryEditorDialogState();
}

class _CategoryEditorDialogState extends ConsumerState<_CategoryEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name = TextEditingController(text: widget.existing?.name);
  late int? _color = widget.existing?.color ?? categoryColors.first;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final repo = ref.read(categoriesRepositoryProvider);
    final existing = widget.existing;
    final PersonCategoryInfo result;
    if (existing == null) {
      result = await repo.create(_name.text, color: _color);
    } else {
      await repo.rename(existing.id, _name.text, color: _color);
      result = PersonCategoryInfo(id: existing.id, name: _name.text.trim(), color: _color, sortOrder: existing.sortOrder);
    }
    if (mounted) Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AlertDialog(
      title: Text(widget.existing == null ? l.addCategory : l.editCategory),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              key: const Key('category-name'),
              controller: _name,
              autofocus: true,
              maxLength: 40,
              decoration: InputDecoration(labelText: l.categoryName),
              validator: (v) => (v == null || v.trim().isEmpty) ? l.errorRequired : null,
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final c in categoryColors)
                  InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => setState(() => _color = c),
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Color(c),
                      child: _color == c ? const Icon(Icons.check, size: 18, color: Colors.white) : null,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
        FilledButton(
          key: const Key('category-save'),
          style: FilledButton.styleFrom(minimumSize: const Size(64, 40)),
          onPressed: _submit,
          child: Text(l.save),
        ),
      ],
    );
  }
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
