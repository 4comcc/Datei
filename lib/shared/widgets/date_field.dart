import 'package:material_ui/material_ui.dart';

import '../../core/time_engine/local_date.dart';
import '../l10n_labels.dart';

/// Form field that opens a date picker and holds a [LocalDate].
class LocalDateFormField extends FormField<LocalDate> {
  LocalDateFormField({
    super.key,
    required String label,
    super.initialValue,
    super.validator,
    required ValueChanged<LocalDate?> onChanged,
    LocalDate? firstDate,
    LocalDate? lastDate,
    bool clearable = true,
  }) : super(
          builder: (state) {
            final context = state.context;
            final l = context.l10n;
            Future<void> pick() async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: context,
                initialDate: state.value?.toDateTime() ?? now,
                firstDate: firstDate?.toDateTime() ?? DateTime(1900),
                lastDate: lastDate?.toDateTime() ?? DateTime(now.year + 50),
              );
              if (picked != null) {
                final v = LocalDate.fromDateTime(picked);
                state.didChange(v);
                onChanged(v);
              }
            }

            return InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: pick,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: label,
                  errorText: state.errorText,
                  prefixIcon: const Icon(Icons.calendar_today_outlined),
                  suffixIcon: clearable && state.value != null
                      ? IconButton(
                          tooltip: l.clear,
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            state.didChange(null);
                            onChanged(null);
                          },
                        )
                      : null,
                ),
                child: Text(
                  state.value == null ? l.pickDate : context.formatLongDate(state.value!),
                  style: state.value == null
                      ? TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)
                      : null,
                ),
              ),
            );
          },
        );
}
