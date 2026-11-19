import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/time_engine/hijri.dart';
import '../../../core/time_engine/local_date.dart';
import '../../../shared/l10n_labels.dart';
import '../../settings/settings_controller.dart';

/// Lets the user type a Hijri date and returns the matching Gregorian date.
Future<LocalDate?> showHijriDateDialog(BuildContext context, {LocalDate? initial}) =>
    showDialog<LocalDate>(context: context, builder: (_) => _HijriDateDialog(initial: initial));

class _HijriDateDialog extends ConsumerStatefulWidget {
  const _HijriDateDialog({this.initial});
  final LocalDate? initial;

  @override
  ConsumerState<_HijriDateDialog> createState() => _HijriDateDialogState();
}

class _HijriDateDialogState extends ConsumerState<_HijriDateDialog> {
  late int _day;
  late int _month;
  late final TextEditingController _year;

  @override
  void initState() {
    super.initState();
    final h = ref.read(hijriConverterProvider).fromGregorian(widget.initial ?? LocalDate.today()) ??
        const HijriDate(1447, 1, 1);
    _day = h.day;
    _month = h.month;
    _year = TextEditingController(text: '${h.year}');
  }

  @override
  void dispose() {
    _year.dispose();
    super.dispose();
  }

  LocalDate? get _result {
    final y = int.tryParse(_year.text.trim());
    if (y == null) return null;
    return ref.read(hijriConverterProvider).toGregorian(HijriDate(y, _month, _day));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final result = _result;
    return AlertDialog(
      title: Text(l.hijriInput),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              SizedBox(
                width: 96,
                child: DropdownButtonFormField<int>(
                  initialValue: _day,
                  isExpanded: true,
                  decoration: InputDecoration(labelText: l.hijriDay, isDense: true),
                  items: [for (var d = 1; d <= 30; d++) DropdownMenuItem(value: d, child: Text('$d'))],
                  onChanged: (v) => setState(() => _day = v ?? _day),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<int>(
                  initialValue: _month,
                  isExpanded: true,
                  decoration: InputDecoration(labelText: l.hijriMonth, isDense: true),
                  items: [for (var m = 1; m <= 12; m++) DropdownMenuItem(value: m, child: Text(l.hijriMonthName(m)))],
                  onChanged: (v) => setState(() => _month = v ?? _month),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('hijri-year'),
            controller: _year,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: l.hijriYear, isDense: true),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          Text(
            result == null ? l.hijriInvalid : l.hijriConverted(context.formatLongDate(result)),
            style: TextStyle(color: result == null ? Theme.of(context).colorScheme.error : null),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
        FilledButton(
          key: const Key('hijri-ok'),
          style: FilledButton.styleFrom(minimumSize: const Size(64, 40)),
          onPressed: result == null ? null : () => Navigator.pop(context, result),
          child: Text(MaterialLocalizations.of(context).okButtonLabel),
        ),
      ],
    );
  }
}
