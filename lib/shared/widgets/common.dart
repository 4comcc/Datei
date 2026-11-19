import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/time_engine/local_date.dart';
import '../../features/agenda/agenda.dart';
import '../../features/events/domain/event.dart';
import '../../features/events/presentation/events_providers.dart';
import '../l10n_labels.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.trailing});
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(4, 20, 4, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, this.body, this.action});
  final IconData icon;
  final String title;
  final String? body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(icon, size: 34, color: theme.colorScheme.onPrimaryContainer),
            ),
            const SizedBox(height: 16),
            Text(title, style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
            if (body != null) ...[
              const SizedBox(height: 8),
              Text(body!, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  textAlign: TextAlign.center),
            ],
            if (action != null) ...[const SizedBox(height: 20), action!],
          ],
        ),
      ),
    );
  }
}

class InlineEmpty extends StatelessWidget {
  const InlineEmpty(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(text, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ),
    );
  }
}

class PersonAvatar extends StatelessWidget {
  const PersonAvatar(this.name, {super.key, this.radius = 22});
  final String name;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final initial = name.trim().isEmpty ? '?' : name.trim().characters.first.toUpperCase();
    return CircleAvatar(
      radius: radius,
      backgroundColor: scheme.secondaryContainer,
      child: Text(initial, style: TextStyle(color: scheme.onSecondaryContainer, fontWeight: FontWeight.w600)),
    );
  }
}

/// A list tile for an agenda occurrence (birthday or event).
class AgendaTile extends ConsumerWidget {
  const AgendaTile({super.key, required this.item, required this.today, this.onTap, this.showRelative = true});
  final AgendaItem item;
  final LocalDate today;
  final VoidCallback? onTap;
  final bool showRelative;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final days = today.daysUntil(item.date);
    final isBirthday = item.kind == AgendaKind.birthday;
    final event = item.event;
    final type = event == null ? null : ref.watch(eventTypeByIdProvider)[event.typeId];
    final title = isBirthday ? l.birthdayOf(item.person!.shownName) : item.title!;
    final cancelled = event?.status == EventStatus.cancelled;
    final subtitleParts = <String>[
      if (item.endDate != null)
        '${context.formatDayMonth(item.date)} – ${context.formatDate(item.endDate!)}'
      else
        context.formatDate(item.date),
      if (isBirthday && item.turningAge != null) l.turnsAge(item.turningAge!),
      if (!isBirthday && item.time != null) context.formatTime(item.time!),
      if (event != null && event.isRecurring) l.repeatsLabel,
      if (event != null && event.status != EventStatus.planned) event.status.label(l),
    ];
    return Card(
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        leading: CircleAvatar(
          backgroundColor: isBirthday ? scheme.tertiaryContainer : scheme.primaryContainer,
          child: Icon(
            isBirthday ? Icons.cake_outlined : (type?.icon ?? Icons.event_note_outlined),
            color: isBirthday ? scheme.onTertiaryContainer : scheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: cancelled ? const TextStyle(decoration: TextDecoration.lineThrough) : null,
        ),
        subtitle: Text(subtitleParts.join(' · ')),
        trailing: showRelative && days >= 0
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: days == 0 ? scheme.primary : scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  l.relativeDays(days),
                  style: TextStyle(fontSize: 12, color: days == 0 ? scheme.onPrimary : scheme.onSurfaceVariant),
                ),
              )
            : null,
      ),
    );
  }
}
