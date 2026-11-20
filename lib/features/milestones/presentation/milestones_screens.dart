import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:uuid/uuid.dart';

import '../../../core/time_engine/local_date.dart';
import '../../../shared/l10n_labels.dart';
import '../../../shared/navigation.dart';
import '../../../shared/widgets/common.dart';
import '../../../shared/widgets/date_field.dart';
import '../../agenda/agenda.dart';
import '../../events/presentation/events_providers.dart';
import '../../memories/presentation/memories_providers.dart';
import '../../people/presentation/category_dialogs.dart';
import '../../people/presentation/people_providers.dart';
import '../domain/milestone.dart';

class MilestonesScreen extends ConsumerWidget {
  const MilestonesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final items = ref.watch(milestonesProvider);
    final loaded = ref.watch(milestonesStreamProvider).hasValue;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(l.milestones)),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('add-milestone-fab'),
        onPressed: () => context.push('/milestones/new'),
        icon: const Icon(Icons.add),
        label: Text(l.addMilestone),
      ),
      body: !loaded
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
              ? EmptyState(icon: Icons.flag_outlined, title: l.milestonesEmptyTitle, body: l.milestonesEmptyBody)
              : ListView.separated(
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 96),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final m = items[i];
                    final person = m.personId == null ? null : ref.watch(personByIdProvider(m.personId!));
                    return Card(
                      child: ListTile(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        leading: CircleAvatar(
                          backgroundColor: scheme.tertiaryContainer,
                          child: Icon(m.kind.icon, color: scheme.onTertiaryContainer),
                        ),
                        title: Text(m.title),
                        subtitle: Text([context.formatLongDate(m.date), m.kind.label(l), ?person?.shownName].join(' · ')),
                        onTap: () => context.push('/milestones/${m.id}/edit'),
                      ),
                    );
                  },
                ),
    );
  }
}

class MilestoneFormScreen extends ConsumerStatefulWidget {
  const MilestoneFormScreen({super.key, this.milestoneId, this.initialPersonId});
  final String? milestoneId;
  final String? initialPersonId;

  @override
  ConsumerState<MilestoneFormScreen> createState() => _MilestoneFormScreenState();
}

class _MilestoneFormScreenState extends ConsumerState<MilestoneFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _description;
  late LocalDate? _date;
  late MilestoneKind _kind;
  String? _personId;
  String? _projectId;
  String? _eventId;
  Milestone? _existing;

  @override
  void initState() {
    super.initState();
    _existing = widget.milestoneId == null ? null : ref.read(milestoneByIdProvider(widget.milestoneId!));
    final m = _existing;
    _title = TextEditingController(text: m?.title);
    _description = TextEditingController(text: m?.description);
    _date = m?.date ?? ref.read(todayProvider);
    _kind = m?.kind ?? MilestoneKind.achievement;
    _personId = m?.personId ?? widget.initialPersonId;
    _projectId = m?.projectId;
    _eventId = m?.eventId;
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(milestonesRepositoryProvider).save(Milestone(
          id: _existing?.id ?? const Uuid().v4(),
          title: _title.text.trim(),
          description: _description.text.trim().isEmpty ? null : _description.text.trim(),
          date: _date!,
          kind: _kind,
          personId: _personId,
          projectId: _projectId,
          eventId: _eventId,
          createdAt: _existing?.createdAt ?? DateTime.now(),
        ));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.savedSuccessfully)));
    context.popOrGo('/milestones');
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final people = ref.watch(peopleProvider);
    final projects = ref.watch(projectsProvider);
    final events = ref.watch(eventsProvider);
    const gap = SizedBox(height: 14);
    DropdownButtonFormField<String?> pick(String label, IconData icon, String? value, List<(String, String)> options, ValueChanged<String?> onChanged) =>
        DropdownButtonFormField<String?>(
          initialValue: options.any((o) => o.$1 == value) ? value : null,
          isExpanded: true,
          decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
          items: [
            DropdownMenuItem(value: null, child: Text(l.noneOption)),
            for (final (id, name) in options) DropdownMenuItem(value: id, child: Text(name, overflow: TextOverflow.ellipsis)),
          ],
          onChanged: onChanged,
        );

    return Scaffold(
      appBar: AppBar(
        title: Text(_existing == null ? l.addMilestone : l.editMilestone),
        actions: [
          if (_existing != null)
            IconButton(
              tooltip: l.delete,
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                if (!await confirmDialog(context, title: l.confirmDeleteTitle, message: l.confirmDeleteMilestone(_existing!.title))) return;
                await ref.read(milestonesRepositoryProvider).delete(_existing!.id);
                if (context.mounted) context.popOrGo('/milestones');
              },
            ),
          TextButton(key: const Key('milestone-save-top'), onPressed: _save, child: Text(l.save)),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              key: const Key('milestone-title'),
              controller: _title,
              decoration: InputDecoration(labelText: l.fieldTitle, prefixIcon: const Icon(Icons.title)),
              validator: (v) => (v == null || v.trim().isEmpty) ? l.errorRequired : null,
            ),
            gap,
            DropdownButtonFormField<MilestoneKind>(
              initialValue: _kind,
              decoration: InputDecoration(labelText: l.fieldMilestoneKind, prefixIcon: Icon(_kind.icon)),
              items: [for (final k in MilestoneKind.values) DropdownMenuItem(value: k, child: Text(k.label(l)))],
              onChanged: (v) => setState(() => _kind = v ?? _kind),
            ),
            gap,
            LocalDateFormField(
              label: l.fieldDate,
              initialValue: _date,
              clearable: false,
              onChanged: (v) => setState(() => _date = v),
              validator: (v) => v == null ? l.errorDateRequired : null,
            ),
            gap,
            pick(l.fieldPerson, Icons.person_outline, _personId, [for (final p in people) (p.id, p.shownName)],
                (v) => setState(() => _personId = v)),
            gap,
            pick(l.fieldProject, Icons.rocket_launch_outlined, _projectId, [for (final p in projects) (p.id, p.name)],
                (v) => setState(() => _projectId = v)),
            gap,
            pick(l.fieldLinkedEvent, Icons.event_outlined, _eventId, [for (final e in events) (e.id, e.title)],
                (v) => setState(() => _eventId = v)),
            gap,
            TextFormField(
              controller: _description,
              minLines: 2,
              maxLines: 6,
              decoration: InputDecoration(labelText: l.fieldDescription, alignLabelWithHint: true),
            ),
            const SizedBox(height: 24),
            FilledButton(key: const Key('milestone-save'), onPressed: _save, child: Text(l.save)),
          ],
        ),
      ),
    );
  }
}
