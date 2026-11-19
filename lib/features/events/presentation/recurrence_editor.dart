import 'package:material_ui/material_ui.dart';

import '../../../core/recurrence_engine/recurrence.dart';
import '../../../core/time_engine/local_date.dart';
import '../../../shared/l10n_labels.dart';
import '../domain/series_editing.dart';

/// Wraps the result so "no repetition" (rule == null) differs from "cancelled" (null result).
class RecurrenceChoice {
  const RecurrenceChoice(this.rule);
  final RecurrenceRule? rule;
}

Future<RecurrenceChoice?> showRecurrenceEditor(BuildContext context, {RecurrenceRule? rule, required LocalDate start}) =>
    showModalBottomSheet<RecurrenceChoice>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (_) => _RecurrenceEditor(initial: rule, start: start),
    );

enum _MonthlyMode { day, nth, last }

enum _EndMode { never, until, count }

class _RecurrenceEditor extends StatefulWidget {
  const _RecurrenceEditor({required this.initial, required this.start});
  final RecurrenceRule? initial;
  final LocalDate start;

  @override
  State<_RecurrenceEditor> createState() => _RecurrenceEditorState();
}

class _RecurrenceEditorState extends State<_RecurrenceEditor> {
  final _formKey = GlobalKey<FormState>();
  RecurrenceFrequency? _freq;
  late final TextEditingController _interval;
  late final TextEditingController _count;
  late Set<int> _weekdays;
  late _MonthlyMode _monthlyMode;
  late bool _skipShort;
  late _EndMode _endMode;
  LocalDate? _until;

  int get _startWeekday => RecurrenceEngine.weekdayOf(widget.start);
  int get _nthOfStart => (widget.start.day - 1) ~/ 7 + 1;
  bool get _startInLastWeek => widget.start.day + 7 > LocalDate.daysInMonth(widget.start.year, widget.start.month);

  @override
  void initState() {
    super.initState();
    final r = widget.initial;
    _freq = r?.frequency;
    _interval = TextEditingController(text: '${r?.interval ?? 1}');
    _count = TextEditingController(text: '${r?.count ?? 10}');
    _weekdays = {...?r?.weekdays};
    if (_weekdays.isEmpty) _weekdays = {_startWeekday};
    _monthlyMode = r?.setPos == null ? _MonthlyMode.day : (r!.setPos! < 0 ? _MonthlyMode.last : _MonthlyMode.nth);
    _skipShort = r?.overflow == MonthOverflow.skip;
    _endMode = r?.until != null ? _EndMode.until : (r?.count != null ? _EndMode.count : _EndMode.never);
    _until = r?.until ?? widget.start.addMonths(6);
  }

  @override
  void dispose() {
    _interval.dispose();
    _count.dispose();
    super.dispose();
  }

  void _save() {
    final freq = _freq;
    if (freq == null) {
      Navigator.pop(context, const RecurrenceChoice(null));
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    final interval = int.parse(_interval.text.trim());
    final rule = RecurrenceRule(
      frequency: freq,
      interval: interval,
      weekdays: switch (freq) {
        RecurrenceFrequency.weekly => _weekdays,
        RecurrenceFrequency.monthly when _monthlyMode != _MonthlyMode.day => {_startWeekday},
        _ => const {},
      },
      setPos: freq == RecurrenceFrequency.monthly
          ? switch (_monthlyMode) { _MonthlyMode.day => null, _MonthlyMode.nth => _nthOfStart, _MonthlyMode.last => -1 }
          : null,
      overflow: _skipShort ? MonthOverflow.skip : MonthOverflow.clampToLastDay,
      until: _endMode == _EndMode.until ? _until : null,
      count: _endMode == _EndMode.count ? int.parse(_count.text.trim()) : null,
    );
    Navigator.pop(context, RecurrenceChoice(rule));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final first = MaterialLocalizations.of(context).firstDayOfWeekIndex; // 0 = Sunday
    final orderedDays = [for (var i = 0; i < 7; i++) ((first + i - 1) % 7) + 1]; // ISO 1..7
    final interval = int.tryParse(_interval.text) ?? 1;
    final unit = switch (_freq) {
      RecurrenceFrequency.daily => l.unitDays(interval),
      RecurrenceFrequency.weekly => l.unitWeeks(interval),
      RecurrenceFrequency.monthly => l.unitMonths(interval),
      RecurrenceFrequency.yearly => l.unitYears(interval),
      null => '',
    };
    const gap = SizedBox(height: 16);
    String? positiveInt(String? v, {int max = 999}) {
      final n = int.tryParse(v?.trim() ?? '');
      return (n == null || n < 1 || n > max) ? l.errorInterval : null;
    }

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 8),
                children: [
                  Text(l.repeat, style: Theme.of(context).textTheme.titleLarge),
                  gap,
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      for (final (f, label) in <(RecurrenceFrequency?, String)>[
                        (null, l.repeatNone),
                        (RecurrenceFrequency.daily, l.repeatDaily),
                        (RecurrenceFrequency.weekly, l.repeatWeekly),
                        (RecurrenceFrequency.monthly, l.repeatMonthly),
                        (RecurrenceFrequency.yearly, l.repeatYearly),
                      ])
                        ChoiceChip(
                          key: Key('freq-${f?.name ?? 'none'}'),
                          label: Text(label),
                          selected: _freq == f,
                          onSelected: (_) => setState(() => _freq = f),
                        ),
                    ],
                  ),
                  if (_freq != null) ...[
                    gap,
                    Row(
                      children: [
                        Text(l.everyLabel),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 80,
                          child: TextFormField(
                            key: const Key('recurrence-interval'),
                            controller: _interval,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(isDense: true),
                            validator: positiveInt,
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(unit)),
                      ],
                    ),
                  ],
                  if (_freq == RecurrenceFrequency.weekly) ...[
                    gap,
                    Text(l.onWeekdays, style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 6),
                    FormField<Set<int>>(
                      validator: (_) => _weekdays.isEmpty ? l.errorWeekdays : null,
                      builder: (state) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              for (final d in orderedDays)
                                FilterChip(
                                  label: Text(context.weekdayName(d)),
                                  selected: _weekdays.contains(d),
                                  onSelected: (s) => setState(() => s ? _weekdays.add(d) : _weekdays.remove(d)),
                                ),
                            ],
                          ),
                          if (state.hasError)
                            Text(state.errorText!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                        ],
                      ),
                    ),
                  ],
                  if (_freq == RecurrenceFrequency.monthly) ...[
                    gap,
                    RadioGroup<_MonthlyMode>(
                      groupValue: _monthlyMode,
                      onChanged: (v) => setState(() => _monthlyMode = v ?? _monthlyMode),
                      child: Column(
                        children: [
                          RadioListTile(
                            value: _MonthlyMode.day,
                            contentPadding: EdgeInsets.zero,
                            title: Text(l.monthlyOnDay(widget.start.day)),
                          ),
                          if (_nthOfStart <= 4)
                            RadioListTile(
                              value: _MonthlyMode.nth,
                              contentPadding: EdgeInsets.zero,
                              title: Text(l.monthlyOnNth(context.positionName(_nthOfStart), context.weekdayName(_startWeekday))),
                            ),
                          if (_startInLastWeek)
                            RadioListTile(
                              value: _MonthlyMode.last,
                              contentPadding: EdgeInsets.zero,
                              title: Text(l.monthlyOnNth(context.positionName(-1), context.weekdayName(_startWeekday))),
                            ),
                        ],
                      ),
                    ),
                    if (_monthlyMode == _MonthlyMode.day && widget.start.day > 28)
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l.skipShortMonths),
                        value: _skipShort,
                        onChanged: (v) => setState(() => _skipShort = v),
                      ),
                  ],
                  if (_freq != null) ...[
                    gap,
                    Text(l.ends, style: Theme.of(context).textTheme.labelLarge),
                    RadioGroup<_EndMode>(
                      groupValue: _endMode,
                      onChanged: (v) => setState(() => _endMode = v ?? _endMode),
                      child: Column(
                        children: [
                          RadioListTile(value: _EndMode.never, contentPadding: EdgeInsets.zero, title: Text(l.endsNever)),
                          RadioListTile(
                            value: _EndMode.until,
                            contentPadding: EdgeInsets.zero,
                            title: Text(l.endsOnDate),
                            subtitle: _endMode == _EndMode.until && _until != null
                                ? Text(context.formatLongDate(_until!))
                                : null,
                            secondary: _endMode == _EndMode.until
                                ? IconButton(
                                    tooltip: l.pickDate,
                                    icon: const Icon(Icons.calendar_today_outlined),
                                    onPressed: () async {
                                      final picked = await showDatePicker(
                                        context: context,
                                        initialDate: (_until ?? widget.start).toDateTime(),
                                        firstDate: widget.start.toDateTime(),
                                        lastDate: DateTime(widget.start.year + 100),
                                      );
                                      if (picked != null) setState(() => _until = LocalDate.fromDateTime(picked));
                                    },
                                  )
                                : null,
                          ),
                          RadioListTile(
                            value: _EndMode.count,
                            contentPadding: EdgeInsets.zero,
                            title: Row(
                              children: [
                                Text(l.endsAfter),
                                const SizedBox(width: 12),
                                SizedBox(
                                  width: 80,
                                  child: TextFormField(
                                    key: const Key('recurrence-count'),
                                    controller: _count,
                                    enabled: _endMode == _EndMode.count,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    decoration: const InputDecoration(isDense: true),
                                    validator: (v) => _endMode == _EndMode.count ? positiveInt(v, max: 9999) : null,
                                    onChanged: (_) => setState(() {}),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(l.unitTimes(int.tryParse(_count.text) ?? 0)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 16),
              child: FilledButton(key: const Key('recurrence-save'), onPressed: _save, child: Text(l.save)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Asks which occurrences an edit/delete applies to.
Future<EditScope?> showEditScopeDialog(BuildContext context, {required bool delete}) {
  final l = context.l10n;
  return showDialog<EditScope>(
    context: context,
    builder: (ctx) => SimpleDialog(
      title: Text(delete ? l.deleteScopeTitle : l.editScopeTitle),
      children: [
        for (final (scope, label) in [
          (EditScope.thisOccurrence, l.scopeThis),
          (EditScope.thisAndFollowing, l.scopeFollowing),
          (EditScope.all, l.scopeAll),
        ])
          SimpleDialogOption(
            key: Key('scope-${scope.name}'),
            onPressed: () => Navigator.pop(ctx, scope),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            child: Text(label),
          ),
      ],
    ),
  );
}
