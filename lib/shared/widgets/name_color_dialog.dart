import 'package:material_ui/material_ui.dart';

import '../l10n_labels.dart';

const pickerColors = <int>[0xFF596B35, 0xFF788B4A, 0xFFB08A2E, 0xFF8C5A3C, 0xFF3F6F7A, 0xFF6B5B95, 0xFFA34E5C, 0xFF5E6452];

/// Asks for a name and a colour. Returns null when cancelled.
Future<(String, int)?> showNameColorDialog(
  BuildContext context, {
  required String title,
  required String label,
  String? initialName,
  int? initialColor,
}) =>
    showDialog<(String, int)>(
      context: context,
      builder: (_) => _NameColorDialog(title: title, label: label, initialName: initialName, initialColor: initialColor),
    );

class _NameColorDialog extends StatefulWidget {
  const _NameColorDialog({required this.title, required this.label, this.initialName, this.initialColor});
  final String title;
  final String label;
  final String? initialName;
  final int? initialColor;

  @override
  State<_NameColorDialog> createState() => _NameColorDialogState();
}

class _NameColorDialogState extends State<_NameColorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name = TextEditingController(text: widget.initialName);
  late int _color = widget.initialColor ?? pickerColors.first;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) Navigator.pop(context, (_name.text.trim(), _color));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              key: const Key('name-color-name'),
              controller: _name,
              autofocus: true,
              maxLength: 40,
              decoration: InputDecoration(labelText: widget.label),
              validator: (v) => (v == null || v.trim().isEmpty) ? l.errorRequired : null,
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final c in pickerColors)
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
          key: const Key('name-color-save'),
          style: FilledButton.styleFrom(minimumSize: const Size(64, 40)),
          onPressed: _submit,
          child: Text(l.save),
        ),
      ],
    );
  }
}
