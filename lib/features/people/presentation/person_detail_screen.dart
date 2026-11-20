import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/time_engine/local_date.dart';
import '../../../shared/l10n_labels.dart';
import '../../../shared/navigation.dart';
import '../../../shared/widgets/common.dart';
import '../../agenda/agenda.dart';
import '../../events/presentation/events_providers.dart';
import '../../memories/presentation/memories_providers.dart';
import '../../memories/presentation/memories_screen.dart';
import '../domain/custom_field.dart';
import '../domain/person.dart';
import '../domain/relationship.dart';
import 'category_dialogs.dart';
import 'people_providers.dart';
import 'relationship_sheet.dart';

class PersonDetailScreen extends ConsumerWidget {
  const PersonDetailScreen({super.key, required this.personId});
  final String personId;

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, String name) async {
    final l = context.l10n;
    if (!await confirmDialog(context, title: l.confirmDeleteTitle, message: l.confirmDeletePerson(name))) return;
    await ref.read(peopleRepositoryProvider).delete(personId);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.deletedSuccessfully)));
    context.popOrGo('/people');
  }

  Future<void> _ageOnDate(BuildContext context, WidgetRef ref, LocalDate birth) async {
    final l = context.l10n;
    final picked = await showDatePicker(
      context: context,
      helpText: l.ageOnDate,
      initialDate: DateTime.now(),
      firstDate: DateTime(1800),
      lastDate: DateTime(2200),
    );
    if (picked == null || !context.mounted) return;
    final on = LocalDate.fromDateTime(picked);
    final age = ref.read(timeEngineProvider).ageOn(birth, on);
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.formatLongDate(on)),
        content: Text(
          age == null ? l.notBornYet : '${l.ageYears(age.years)}\n${l.ageBreakdown(age.years, age.months, age.days)}',
          style: Theme.of(ctx).textTheme.titleMedium,
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text(MaterialLocalizations.of(ctx).okButtonLabel))],
      ),
    );
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
    final categories = ref.watch(categoryByIdProvider);
    final fields = ref.watch(customFieldDefinitionsProvider).value ?? const <CustomFieldDefinition>[];
    final relations = ref.watch(relationshipsForPersonProvider(person.id));
    final birth = person.birthDate;
    final withYear = person.birthDateWithYear;
    final age = withYear == null ? null : engine.ageOn(withYear, today);
    final next = birth == null ? null : engine.nextBirthday(birth, today);
    final untilNext = next == null ? null : engine.difference(today, next);
    final eventTypes = ref.watch(eventTypeByIdProvider);
    final memories = ref.watch(memoriesProvider).where((m) => m.personIds.contains(person.id)).toList();
    final linkedEvents = ref.watch(eventsProvider).where((e) => e.personIds.contains(person.id)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    final details = <(IconData, String, String, bool)>[
      if (person.phone?.isNotEmpty ?? false) (Icons.phone_outlined, l.fieldPhone, person.phone!, true),
      if (person.email?.isNotEmpty ?? false) (Icons.email_outlined, l.fieldEmail, person.email!, true),
      if (person.organization?.isNotEmpty ?? false) (Icons.business_outlined, l.fieldOrganization, person.organization!, false),
      if (person.address?.isNotEmpty ?? false) (Icons.home_outlined, l.fieldAddress, person.address!, false),
      if (person.gender != null) (Icons.wc_outlined, l.fieldGender, person.gender.label(l), false),
      for (final f in fields)
        if (person.customFields[f.id] case final v?)
          (
            Icons.tune,
            f.label,
            f.type == CustomFieldType.date ? _formatIsoDate(context, v) : v,
            f.type == CustomFieldType.url || f.type == CustomFieldType.number,
          ),
    ];

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
          if (person.categoryIds.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 6,
              children: [
                for (final id in person.categoryIds)
                  if (categories[id] case final c?) Chip(label: Text(c.label(l))),
              ],
            ),
          ],
          SectionHeader(l.labelAge),
          if (birth == null || next == null)
            InlineEmpty(l.noBirthDate)
          else
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (age != null && withYear != null) ...[
                      Text(l.ageYears(age.years),
                          style: theme.textTheme.headlineMedium
                              ?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(l.ageBreakdown(age.years, age.months, age.days)),
                      Text(l.totalDaysLived(withYear.daysUntil(today)),
                          style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                      const Divider(height: 28),
                    ],
                    _InfoRow(
                      icon: Icons.cake_outlined,
                      label: l.fieldBirthDate,
                      value: context.formatBirthDate(birth, yearKnown: person.birthYearKnown),
                    ),
                    const SizedBox(height: 10),
                    _InfoRow(
                      icon: Icons.celebration_outlined,
                      label: l.labelNextBirthday,
                      value: [
                        context.formatDate(next),
                        if (person.birthYearKnown) l.turnsAge(next.year - birth.year),
                        l.relativeDays(today.daysUntil(next)),
                      ].join(' · '),
                    ),
                    if (untilNext != null && untilNext.years * 12 + untilNext.months > 0) ...[
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsetsDirectional.only(start: 32),
                        child: Text(l.untilBirthday(untilNext.years * 12 + untilNext.months, untilNext.days),
                            style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                      ),
                    ],
                    if (withYear != null) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: TextButton.icon(
                          key: const Key('age-on-date'),
                          onPressed: () => _ageOnDate(context, ref, withYear),
                          icon: const Icon(Icons.event_available_outlined, size: 18),
                          label: Text(l.ageOnDate),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          if (details.isNotEmpty) ...[
            SectionHeader(l.labelContact),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    for (final (i, (icon, label, value, ltr)) in details.indexed) ...[
                      if (i > 0) const SizedBox(height: 10),
                      _InfoRow(icon: icon, label: label, value: value, ltrValue: ltr),
                    ],
                  ],
                ),
              ),
            ),
          ],
          SectionHeader(
            l.sectionRelationships,
            trailing: TextButton.icon(
              key: const Key('add-relationship'),
              onPressed: () => showAddRelationshipSheet(context, person),
              icon: const Icon(Icons.add, size: 18),
              label: Text(l.add),
            ),
          ),
          if (relations.isEmpty)
            InlineEmpty(l.noRelationships)
          else
            Card(
              child: Column(
                children: [
                  for (final r in relations) _RelationshipTile(person: person, relationship: r),
                ],
              ),
            ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            key: const Key('person-timeline'),
            onPressed: () => context.push('/people/${person.id}/timeline'),
            icon: const Icon(Icons.timeline),
            label: Text(l.viewTimeline),
          ),
          SectionHeader(
            l.sectionMemories,
            trailing: TextButton.icon(
              onPressed: () => context.push('/memories/new?person=${person.id}'),
              icon: const Icon(Icons.add, size: 18),
              label: Text(l.addMemory),
            ),
          ),
          for (final m in memories.take(3))
            Padding(padding: const EdgeInsets.only(bottom: 8), child: MemoryCard(memory: m)),
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
                    leading: Icon(eventTypes[e.typeId]?.icon ?? Icons.event_note_outlined, color: theme.colorScheme.primary),
                    title: Text(e.title),
                    subtitle: Text([
                      context.formatDate(e.date),
                      ?eventTypes[e.typeId]?.label(l),
                      if (e.isRecurring) context.describeRecurrence(e.recurrence, e.date),
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

  static String _formatIsoDate(BuildContext context, String iso) {
    try {
      return context.formatLongDate(LocalDate.parse(iso));
    } on FormatException {
      return iso;
    }
  }
}

/// Outgoing (this person is X of someone/me) or incoming (someone is X of this person).
class _RelationshipTile extends ConsumerWidget {
  const _RelationshipTile({required this.person, required this.relationship});
  final Person person;
  final Relationship relationship;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final r = relationship;
    final outgoing = r.personId == person.id;
    final String title;
    final String? subtitle;
    if (outgoing) {
      final other = r.relatedPersonId == null ? null : ref.watch(personByIdProvider(r.relatedPersonId!));
      title = other == null ? l.relationOfMe(r.typeLabel(l)) : l.relationOfPerson(r.typeLabel(l), other.shownName);
      subtitle = null;
    } else {
      final other = ref.watch(personByIdProvider(r.personId));
      title = other?.shownName ?? '';
      subtitle = r.typeLabel(l);
    }
    final otherId = outgoing ? r.relatedPersonId : r.personId;
    return ListTile(
      leading: Icon(outgoing ? Icons.arrow_outward : Icons.call_received, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle),
      onTap: otherId == null ? null : () => context.push('/people/$otherId'),
      trailing: IconButton(
        tooltip: l.removeRelationship,
        icon: const Icon(Icons.close),
        onPressed: () => ref.read(relationshipsRepositoryProvider).delete(r.id),
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
                // Isolate user text: LTR for phone/email/links, first-strong for the rest ("O+" stays "O+" in RTL).
                ltrValue ? '\u2066$value\u2069' : '\u2068$value\u2069',
                style: const TextStyle(fontSize: 15),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
