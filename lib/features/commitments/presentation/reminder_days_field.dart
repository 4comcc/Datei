import 'package:material_ui/material_ui.dart';

import '../../../shared/l10n_labels.dart';
import '../../people/presentation/category_dialogs.dart';

/// Chips for "N days before" reminders, with the standard set plus custom values.
class ReminderDaysField extends StatelessWidget {
  const ReminderDaysField({super.key, required this.days, required this.onChanged, this.presets = const [30, 14, 7, 3, 1, 0]});
  final List<int> days;
  final ValueChanged<List<int>> onChanged;
  final List<int> presets;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final all = {...presets, ...days}.toList()..sort((a, b) => b.compareTo(a));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.remindersLabel, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final d in all)
              FilterChip(
                key: Key('reminder-day-$d'),
                label: Text(l.reminderDaysBefore(d)),
                selected: days.contains(d),
                onSelected: (s) => onChanged(s ? ([...days, d]..sort((a, b) => b.compareTo(a))) : ([...days]..remove(d))),
              ),
            ActionChip(
              avatar: const Icon(Icons.add, size: 18),
              label: Text(l.addCustomReminder),
              onPressed: () async {
                final text = await showTextInputDialog(context, title: l.addCustomReminder, label: l.customReminderDays, maxLength: 3);
                final n = int.tryParse(text ?? '');
                if (n != null && n >= 0 && n <= 365 && !days.contains(n)) onChanged([...days, n]..sort((a, b) => b.compareTo(a)));
              },
            ),
          ],
        ),
      ],
    );
  }
}
