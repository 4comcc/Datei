import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/time_engine/hijri.dart';
import '../../core/time_engine/local_date.dart';
import '../../shared/l10n_labels.dart';
import '../../shared/widgets/common.dart';
import '../agenda/agenda.dart';
import '../events/domain/event.dart';
import '../events/presentation/events_providers.dart';
import '../home/home_screen.dart';
import '../people/presentation/people_providers.dart';
import '../settings/settings_controller.dart';

enum CalendarView { month, week, day }

/// What the calendar shows (state kept outside widgets).
class CalendarFilter {
  const CalendarFilter({this.hiddenTypeIds = const {}, this.showBirthdays = true});
  final Set<String> hiddenTypeIds;
  final bool showBirthdays;

  bool get isActive => hiddenTypeIds.isNotEmpty || !showBirthdays;

  bool allows(AgendaItem i) => i.kind == AgendaKind.birthday ? showBirthdays : !hiddenTypeIds.contains(i.event!.typeId);
}

class CalendarFilterController extends Notifier<CalendarFilter> {
  @override
  CalendarFilter build() => const CalendarFilter();
  void set(CalendarFilter f) => state = f;
}

final calendarFilterProvider = NotifierProvider<CalendarFilterController, CalendarFilter>(CalendarFilterController.new);

/// Filtered agenda for a date range.
final calendarItemsProvider = Provider.family<List<AgendaItem>, (LocalDate, LocalDate)>((ref, range) {
  final filter = ref.watch(calendarFilterProvider);
  return [for (final i in ref.watch(agendaRangeProvider(range))) if (filter.allows(i)) i];
});

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  CalendarView _view = CalendarView.month;
  late LocalDate _selected;
  bool _searching = false;
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selected = ref.read(todayProvider);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _move(int direction) => setState(() {
        _selected = switch (_view) {
          CalendarView.month => _selected.addMonths(direction),
          CalendarView.week => _selected.addDays(7 * direction),
          CalendarView.day => _selected.addDays(direction),
        };
      });

  Future<void> _goToDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selected.toDateTime(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2200),
      helpText: context.l10n.goToDate,
    );
    if (picked != null) setState(() => _selected = LocalDate.fromDateTime(picked));
  }

  Future<void> _openFilter() => showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (_) => const _CalendarFilterSheet(),
      );

  LocalDate _weekStart(LocalDate d) {
    final first = MaterialLocalizations.of(context).firstDayOfWeekIndex; // 0 = Sunday
    final weekday0 = d.toUtcDateTime().weekday % 7; // 0 = Sunday
    return d.addDays(-((weekday0 - first + 7) % 7));
  }

  String _periodTitle() => switch (_view) {
        CalendarView.month => context.formatMonthYear(_selected),
        CalendarView.week => () {
            final s = _weekStart(_selected);
            return '${context.formatDayMonth(s)} – ${context.formatDate(s.addDays(6))}';
          }(),
        CalendarView.day => context.formatLongDate(_selected),
      };

  String? _hijriSubtitle(HijriConverter h, bool show) {
    if (!show) return null;
    final l = context.l10n;
    if (_view == CalendarView.month) {
      final first = h.fromGregorian(LocalDate(_selected.year, _selected.month, 1));
      final last = h.fromGregorian(LocalDate(_selected.year, _selected.month, LocalDate.daysInMonth(_selected.year, _selected.month)));
      if (first == null || last == null) return null;
      final a = '${l.hijriMonthName(first.month)} ${first.year}';
      final b = '${l.hijriMonthName(last.month)} ${last.year}';
      return a == b ? a : '$a – $b';
    }
    final hd = h.fromGregorian(_selected);
    return hd == null ? null : l.formatHijri(hd);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final settings = ref.watch(settingsProvider);
    final hijri = ref.watch(hijriConverterProvider);
    final filter = ref.watch(calendarFilterProvider);
    final hijriSubtitle = _hijriSubtitle(hijri, settings.showHijri);

    return Scaffold(
      appBar: _searching
          ? AppBar(
              leading: IconButton(
                icon: const BackButtonIcon(),
                onPressed: () => setState(() {
                  _searching = false;
                  _search.clear();
                }),
              ),
              title: TextField(
                key: const Key('calendar-search'),
                controller: _search,
                autofocus: true,
                decoration: InputDecoration(hintText: l.searchCalendarHint, border: InputBorder.none, filled: false),
                onChanged: (_) => setState(() {}),
              ),
            )
          : AppBar(
              title: Text(l.navCalendar),
              actions: [
                IconButton(
                  key: const Key('calendar-search-open'),
                  tooltip: l.searchCalendar,
                  icon: const Icon(Icons.search),
                  onPressed: () => setState(() => _searching = true),
                ),
                IconButton(
                  key: const Key('calendar-filter'),
                  tooltip: l.calendarFilter,
                  icon: Badge(isLabelVisible: filter.isActive, smallSize: 8, child: const Icon(Icons.filter_list)),
                  onPressed: _openFilter,
                ),
                IconButton(
                  key: const Key('calendar-goto'),
                  tooltip: l.goToDate,
                  icon: const Icon(Icons.event_outlined),
                  onPressed: _goToDate,
                ),
                TextButton(
                  onPressed: () => setState(() => _selected = ref.read(todayProvider)),
                  child: Text(l.calendarToday),
                ),
              ],
            ),
      body: _searching
          ? _SearchResults(
              query: _search.text,
              onPick: (d) => setState(() {
                _searching = false;
                _search.clear();
                _selected = d;
                _view = CalendarView.day;
              }),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: SegmentedButton<CalendarView>(
                    segments: [
                      ButtonSegment(value: CalendarView.month, label: Text(l.viewMonth)),
                      ButtonSegment(value: CalendarView.week, label: Text(l.viewWeek)),
                      ButtonSegment(value: CalendarView.day, label: Text(l.viewDay)),
                    ],
                    selected: {_view},
                    onSelectionChanged: (s) => setState(() => _view = s.first),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      tooltip: l.previousPeriod,
                      icon: Icon(isRtl ? Icons.chevron_right : Icons.chevron_left),
                      onPressed: () => _move(-1),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(_periodTitle(),
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                          if (hijriSubtitle != null)
                            Text(hijriSubtitle,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.tertiary)),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: l.nextPeriod,
                      icon: Icon(isRtl ? Icons.chevron_left : Icons.chevron_right),
                      onPressed: () => _move(1),
                    ),
                  ],
                ),
                Expanded(
                  child: switch (_view) {
                    CalendarView.month => _MonthView(
                        selected: _selected,
                        showHijri: settings.showHijri,
                        onSelect: (d) => setState(() => _selected = d),
                      ),
                    CalendarView.week => _WeekView(
                        start: _weekStart(_selected),
                        selected: _selected,
                        onSelect: (d) => setState(() => _selected = d),
                      ),
                    CalendarView.day => _DayView(day: _selected),
                  },
                ),
              ],
            ),
    );
  }
}

void _open(BuildContext context, AgendaItem i) => HomeScreen.openItem(context, i);

class _DayItems extends ConsumerWidget {
  const _DayItems({required this.day, required this.items});
  final LocalDate day;
  final List<AgendaItem> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final today = ref.watch(todayProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          context.formatLongDate(day),
          trailing: IconButton(
            tooltip: l.addEvent,
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => context.push('/events/new?date=${day.toIso()}'),
          ),
        ),
        if (items.isEmpty)
          InlineEmpty(l.calendarNoItems)
        else
          for (final i in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AgendaTile(item: i, today: today, showRelative: !i.date.isBefore(today), onTap: () => _open(context, i)),
            ),
      ],
    );
  }
}

class _MonthView extends ConsumerWidget {
  const _MonthView({required this.selected, required this.showHijri, required this.onSelect});
  final LocalDate selected;
  final bool showHijri;
  final ValueChanged<LocalDate> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final ml = MaterialLocalizations.of(context);
    final today = ref.watch(todayProvider);
    final hijri = ref.watch(hijriConverterProvider);
    final month = LocalDate(selected.year, selected.month, 1);
    final first = ml.firstDayOfWeekIndex;
    final leading = (month.toUtcDateTime().weekday % 7 - first + 7) % 7;
    final gridStart = month.addDays(-leading);
    final cells = ((leading + LocalDate.daysInMonth(month.year, month.month) + 6) ~/ 7) * 7;
    final gridEnd = gridStart.addDays(cells - 1);
    final items = ref.watch(calendarItemsProvider((gridStart, gridEnd)));
    List<AgendaItem> on(LocalDate d) => [for (final i in items) if (i.coversDay(d)) i];

    return ListView(
      padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 12, 96),
      children: [
        Row(
          children: [
            for (var i = 0; i < 7; i++)
              Expanded(
                child: Center(
                  child: Text(ml.narrowWeekdays[(first + i) % 7],
                      style: theme.textTheme.labelMedium?.copyWith(color: scheme.onSurfaceVariant)),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: showHijri ? 0.8 : 0.95),
          itemCount: cells,
          itemBuilder: (context, index) {
            final date = gridStart.addDays(index);
            final inMonth = date.month == month.month;
            final isSelected = date == selected;
            final isToday = date == today;
            final dayItems = on(date);
            final hasBirthday = dayItems.any((i) => i.kind == AgendaKind.birthday);
            final hasEvent = dayItems.any((i) => i.kind == AgendaKind.event);
            final h = showHijri ? hijri.fromGregorian(date) : null;
            final fg = isSelected ? scheme.onPrimary : (inMonth ? scheme.onSurface : scheme.onSurface.withValues(alpha: 0.35));
            return InkWell(
              key: Key('day-${date.toIso()}'),
              borderRadius: BorderRadius.circular(12),
              onTap: () => onSelect(date),
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
                    Text('${date.day}',
                        style: TextStyle(fontWeight: isToday || isSelected ? FontWeight.w700 : FontWeight.w400, color: fg)),
                    if (h != null)
                      Text('${h.day}', style: TextStyle(fontSize: 10, color: isSelected ? scheme.onPrimary : scheme.tertiary)),
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
        _DayItems(day: selected, items: on(selected)),
      ],
    );
  }
}

class _WeekView extends ConsumerWidget {
  const _WeekView({required this.start, required this.selected, required this.onSelect});
  final LocalDate start;
  final LocalDate selected;
  final ValueChanged<LocalDate> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final today = ref.watch(todayProvider);
    final items = ref.watch(calendarItemsProvider((start, start.addDays(6))));
    final days = [for (var i = 0; i < 7; i++) start.addDays(i)];
    return ListView(
      padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 12, 96),
      children: [
        Row(
          children: [
            for (final d in days)
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => onSelect(d),
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: d == selected ? scheme.primary : null,
                      borderRadius: BorderRadius.circular(12),
                      border: d == today && d != selected ? Border.all(color: scheme.primary) : null,
                    ),
                    child: Column(
                      children: [
                        Text(context.weekdayName(d.toUtcDateTime().weekday).characters.take(3).toString(),
                            style: TextStyle(fontSize: 11, color: d == selected ? scheme.onPrimary : scheme.onSurfaceVariant)),
                        Text('${d.day}',
                            style: TextStyle(fontWeight: FontWeight.w600, color: d == selected ? scheme.onPrimary : scheme.onSurface)),
                        if (items.any((i) => i.coversDay(d))) _Dot(color: d == selected ? scheme.onPrimary : scheme.secondary),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
        for (final d in days)
          if (items.any((i) => i.coversDay(d)) || d == selected)
            _DayItems(day: d, items: [for (final i in items) if (i.coversDay(d)) i]),
      ],
    );
  }
}

class _DayView extends ConsumerWidget {
  const _DayView({required this.day});
  final LocalDate day;

  static const _hourHeight = 56.0;

  static int? _minutes(String? hhmm) {
    if (hhmm == null) return null;
    final p = hhmm.split(':');
    return int.parse(p[0]) * 60 + int.parse(p[1]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final items = ref.watch(calendarItemsProvider((day, day)));
    final allDay = [for (final i in items) if (i.time == null || i.date != day) i];
    final timed = [for (final i in items) if (i.time != null && i.date == day) i];
    final types = ref.watch(eventTypeByIdProvider);

    return ListView(
      padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 12, 96),
      children: [
        _DayItems(day: day, items: allDay),
        if (allDay.isNotEmpty || timed.isNotEmpty) const SizedBox(height: 8),
        SizedBox(
          height: 24 * _hourHeight,
          child: Stack(
            children: [
              for (var h = 0; h < 24; h++)
                PositionedDirectional(
                  top: h * _hourHeight,
                  start: 0,
                  end: 0,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 56,
                        child: Text(context.formatTime('${h.toString().padLeft(2, '0')}:00'),
                            style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant)),
                      ),
                      Expanded(child: Divider(height: 1, color: scheme.outlineVariant)),
                    ],
                  ),
                ),
              for (final (index, i) in timed.indexed)
                Builder(builder: (context) {
                  final start = _minutes(i.time)!;
                  final endRaw = i.event?.endDate == null ? _minutes(i.event?.endTime) : null;
                  final end = (endRaw != null && endRaw > start) ? endRaw : start + 60;
                  final type = types[i.event!.typeId];
                  return PositionedDirectional(
                    top: start / 60 * _hourHeight,
                    start: 60.0 + (index % 2) * 8,
                    end: 4,
                    height: ((end - start) / 60 * _hourHeight).clamp(28.0, 24 * _hourHeight),
                    child: Material(
                      color: type?.color != null ? Color(type!.color!).withValues(alpha: 0.85) : scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => _open(context, i),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Text(
                            '${context.formatTime(i.time!)} · ${i.title}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: type?.color != null ? Colors.white : scheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ],
    );
  }
}

class _CalendarFilterSheet extends ConsumerWidget {
  const _CalendarFilterSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final filter = ref.watch(calendarFilterProvider);
    final types = ref.watch(eventTypesProvider).value ?? const <EventTypeInfo>[];
    final c = ref.read(calendarFilterProvider.notifier);
    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
        children: [
          Text(l.calendarFilter, style: Theme.of(context).textTheme.titleLarge),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.cake_outlined),
            title: Text(l.birthdaysLabel),
            value: filter.showBirthdays,
            onChanged: (v) => c.set(CalendarFilter(hiddenTypeIds: filter.hiddenTypeIds, showBirthdays: v)),
          ),
          for (final t in types)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              secondary: Icon(t.icon),
              title: Text(t.label(l)),
              value: !filter.hiddenTypeIds.contains(t.id),
              onChanged: (v) => c.set(CalendarFilter(
                hiddenTypeIds: v == true ? ({...filter.hiddenTypeIds}..remove(t.id)) : {...filter.hiddenTypeIds, t.id},
                showBirthdays: filter.showBirthdays,
              )),
            ),
          TextButton(onPressed: () => c.set(const CalendarFilter()), child: Text(l.clearFilters)),
        ],
      ),
    );
  }
}

class _SearchResults extends ConsumerWidget {
  const _SearchResults({required this.query, required this.onPick});
  final String query;
  final ValueChanged<LocalDate> onPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final q = query.trim().toLowerCase();
    final today = ref.watch(todayProvider);
    if (q.isEmpty) {
      return Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(l.searchCalendarScope, textAlign: TextAlign.center)));
    }
    final items = ref.watch(agendaServiceProvider).itemsInRange(
          people: ref.watch(peopleProvider),
          events: ref.watch(eventsProvider),
          from: today.addDays(-365),
          to: today.addDays(365),
        );
    final matches = [
      for (final i in items)
        if ((i.kind == AgendaKind.birthday ? i.person!.shownName : i.title!).toLowerCase().contains(q) ||
            (i.event?.notes?.toLowerCase().contains(q) ?? false) ||
            (i.event?.location?.toLowerCase().contains(q) ?? false))
          i,
    ];
    if (matches.isEmpty) return Center(child: Text(l.noResults));
    return ListView.separated(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 96),
      itemCount: matches.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) => AgendaTile(
        item: matches[index],
        today: today,
        showRelative: !matches[index].date.isBefore(today),
        onTap: () => onPick(matches[index].date),
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
