import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/time_engine/local_date.dart';
import '../../shared/l10n_labels.dart';
import '../../shared/widgets/common.dart';
import '../agenda/agenda.dart';
import '../home/home_screen.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late LocalDate _month; // first day of displayed month
  late LocalDate _selected;

  @override
  void initState() {
    super.initState();
    final today = ref.read(todayProvider);
    _selected = today;
    _month = LocalDate(today.year, today.month, 1);
  }

  void _goToday() {
    final today = ref.read(todayProvider);
    setState(() {
      _selected = today;
      _month = LocalDate(today.year, today.month, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final materialL10n = MaterialLocalizations.of(context);
    final today = ref.watch(todayProvider);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    final firstWeekday = materialL10n.firstDayOfWeekIndex; // 0 = Sunday
    final monthEnd = LocalDate(_month.year, _month.month, LocalDate.daysInMonth(_month.year, _month.month));
    final leading = (_month.toUtcDateTime().weekday % 7 - firstWeekday + 7) % 7;
    final gridStart = _month.addDays(-leading);
    final cellCount = ((leading + monthEnd.day + 6) ~/ 7) * 7;
    final gridEnd = gridStart.addDays(cellCount - 1);

    final items = ref.watch(agendaRangeProvider((gridStart, gridEnd)));
    final byDate = <LocalDate, List<AgendaItem>>{};
    for (final i in items) {
      byDate.putIfAbsent(i.date, () => []).add(i);
    }
    final selectedItems = byDate[_selected] ?? const [];

    return Scaffold(
      appBar: AppBar(
        title: Text(l.navCalendar),
        actions: [TextButton(onPressed: _goToday, child: Text(l.calendarToday))],
      ),
      body: ListView(
        padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 12, 96),
        children: [
          Row(
            children: [
              IconButton(
                tooltip: l.previousMonth,
                icon: Icon(isRtl ? Icons.chevron_right : Icons.chevron_left),
                onPressed: () => setState(() => _month = _month.addMonths(-1)),
              ),
              Expanded(
                child: Text(context.formatMonthYear(_month),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              ),
              IconButton(
                tooltip: l.nextMonth,
                icon: Icon(isRtl ? Icons.chevron_left : Icons.chevron_right),
                onPressed: () => setState(() => _month = _month.addMonths(1)),
              ),
            ],
          ),
          Row(
            children: [
              for (var i = 0; i < 7; i++)
                Expanded(
                  child: Center(
                    child: Text(
                      materialL10n.narrowWeekdays[(firstWeekday + i) % 7],
                      style: theme.textTheme.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 0.95),
            itemCount: cellCount,
            itemBuilder: (context, index) {
              final date = gridStart.addDays(index);
              final inMonth = date.month == _month.month;
              final isSelected = date == _selected;
              final isToday = date == today;
              final dayItems = byDate[date] ?? const [];
              final hasBirthday = dayItems.any((i) => i.kind == AgendaKind.birthday);
              final hasEvent = dayItems.any((i) => i.kind == AgendaKind.event);
              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => setState(() {
                  _selected = date;
                  if (!inMonth) _month = LocalDate(date.year, date.month, 1);
                }),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isSelected ? scheme.primary : null,
                    borderRadius: BorderRadius.circular(12),
                    border: isToday && !isSelected ? Border.all(color: scheme.primary, width: 1.5) : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${date.day}',
                        style: TextStyle(
                          fontWeight: isToday || isSelected ? FontWeight.w700 : FontWeight.w400,
                          color: isSelected
                              ? scheme.onPrimary
                              : inMonth
                                  ? scheme.onSurface
                                  : scheme.onSurface.withValues(alpha: 0.35),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (hasBirthday) _Dot(color: isSelected ? scheme.onPrimary : scheme.tertiary),
                          if (hasBirthday && hasEvent) const SizedBox(width: 3),
                          if (hasEvent) _Dot(color: isSelected ? scheme.onPrimary : scheme.secondary),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          SectionHeader(
            context.formatLongDate(_selected),
            trailing: IconButton(
              tooltip: l.addEvent,
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => context.push('/events/new?date=${_selected.toIso()}'),
            ),
          ),
          if (selectedItems.isEmpty)
            InlineEmpty(l.calendarNoItems)
          else
            for (final i in selectedItems)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: AgendaTile(
                  item: i,
                  today: today,
                  showRelative: !i.date.isBefore(today),
                  onTap: () => HomeScreen.openItem(context, i),
                ),
              ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) =>
      Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
}
