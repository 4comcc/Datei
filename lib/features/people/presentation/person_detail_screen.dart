import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../shared/l10n_labels.dart';
import '../../../shared/widgets/common.dart';
import '../../agenda/agenda.dart';
import '../../events/presentation/events_providers.dart';
import 'people_providers.dart';

class PersonDetailScreen extends ConsumerWidget {
  const PersonDetailScreen({super.key, required this.personId});
  final String personId;

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, String name) async {
    final l = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.confirmDeleteTitle),
        content: Text(l.confirmDeletePerson(name)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.delete)),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    await ref.read(peopleRepositoryProvider).delete(personId);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.deletedSuccessfully)));
    context.pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final person = ref.watch(personByIdProvider(personId));
    if (person == null) {
      return Scaffold(appBar: AppBar(), body: Center(child: Text(l.noResults)));
    }
    final engine = ref.watch(timeEngineProvider);
    final today = ref.watch(todayProvider);
    final birth = person.birthDate;
    final age = birth == null ? null : engine.ageOn(birth, today);
    final next = birth == null ? null : engine.nextBirthday(birth, today);
    final linkedEvents = ref.watch(eventsProvider).where((e) => e.personIds.contains(person.id)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: l.edit,
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/people/${person.id}/edit'),
          ),
          IconButton(
            tooltip: l.delete,
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context, ref, person.shownName),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 32),
        children: [
          Center(child: PersonAvatar(person.shownName, radius: 40)),
          const SizedBox(height: 12),
          Text(person.fullName,
              textAlign: TextAlign.center, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
          if (person.occupation?.isNotEmpty ?? false)
            Text(person.occupation!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          if (person.categories.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 6,
              children: [for (final c in person.categories) Chip(label: Text(c.label(l)))],
            ),
          ],
          SectionHeader(l.labelAge),
          if (birth == null || age == null || next == null)
            InlineEmpty(l.noBirthDate)
          else
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.ageYears(age.years),
                        style: theme.textTheme.headlineMedium
                            ?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(l.ageBreakdown(age.years, age.months, age.days)),
                    Text(l.totalDaysLived(birth.daysUntil(today)),
                        style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                    const Divider(height: 28),
                    _InfoRow(icon: Icons.cake_outlined, label: l.fieldBirthDate, value: context.formatLongDate(birth)),
                    const SizedBox(height: 10),
                    _InfoRow(
                      icon: Icons.celebration_outlined,
                      label: l.labelNextBirthday,
                      value:
                          '${context.formatDate(next)} · ${l.turnsAge(next.year - birth.year)} · ${l.relativeDays(today.daysUntil(next))}',
                    ),
                  ],
                ),
              ),
            ),
          if ([person.phone, person.email].any((v) => v?.isNotEmpty ?? false)) ...[
            SectionHeader(l.labelContact),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (person.phone?.isNotEmpty ?? false)
                      _InfoRow(icon: Icons.phone_outlined, label: l.fieldPhone, value: person.phone!, ltrValue: true),
                    if ((person.phone?.isNotEmpty ?? false) && (person.email?.isNotEmpty ?? false))
                      const SizedBox(height: 10),
                    if (person.email?.isNotEmpty ?? false)
                      _InfoRow(icon: Icons.email_outlined, label: l.fieldEmail, value: person.email!, ltrValue: true),
                  ],
                ),
              ),
            ),
          ],
          SectionHeader(
            l.labelLinkedEvents,
            trailing: TextButton.icon(
              onPressed: () => context.push('/events/new?person=${person.id}'),
              icon: const Icon(Icons.add, size: 18),
              label: Text(l.addEvent),
            ),
          ),
          if (linkedEvents.isEmpty)
            InlineEmpty(l.noLinkedEvents)
          else
            for (final e in linkedEvents)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Card(
                  child: ListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    leading: Icon(e.type.icon, color: theme.colorScheme.primary),
                    title: Text(e.title),
                    subtitle: Text([
                      context.formatDate(e.date),
                      e.type.label(l),
                      if (e.repeatsYearly) l.yearly,
                    ].join(' · ')),
                    onTap: () => context.push('/events/${e.id}/edit'),
                  ),
                ),
              ),
          if (person.notes?.isNotEmpty ?? false) ...[
            SectionHeader(l.fieldNotes),
            Card(child: Padding(padding: const EdgeInsets.all(16), child: Text(person.notes!))),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value, this.ltrValue = false});
  final IconData icon;
  final String label;
  final String value;
  final bool ltrValue;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: scheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
              Text(
                ltrValue ? '\u2066$value\u2069' : value, // LTR isolate for phone/email in RTL
                style: const TextStyle(fontSize: 15),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
