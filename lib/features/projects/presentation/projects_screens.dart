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
import '../../events/domain/event.dart';
import '../../events/presentation/events_providers.dart';
import '../../memories/presentation/memories_providers.dart';
import '../../people/presentation/category_dialogs.dart';
import '../../people/presentation/people_providers.dart';
import '../domain/project.dart';

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final items = ref.watch(projectsProvider);
    final loaded = ref.watch(projectsStreamProvider).hasValue;
    return Scaffold(
      appBar: AppBar(title: Text(l.projects)),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('add-project-fab'),
        onPressed: () => context.push('/projects/new'),
        icon: const Icon(Icons.add),
        label: Text(l.addProject),
      ),
      body: !loaded
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
              ? EmptyState(icon: Icons.rocket_launch_outlined, title: l.projectsEmptyTitle, body: l.projectsEmptyBody)
              : ListView.separated(
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 96),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, i) => ProjectTile(project: items[i]),
                ),
    );
  }
}

class ProjectTile extends ConsumerWidget {
  const ProjectTile({super.key, required this.project});
  final Project project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final today = ref.watch(todayProvider);
    final overdue = project.isOverdue(today);
    final done = !project.isOpen;
    return Card(
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        leading: CircleAvatar(
          backgroundColor: done ? scheme.surfaceContainerHighest : scheme.primaryContainer,
          child: Icon(done ? Icons.check : Icons.rocket_launch_outlined, color: done ? scheme.onSurfaceVariant : scheme.onPrimaryContainer),
        ),
        title: Text(project.name, style: done ? TextStyle(color: scheme.onSurfaceVariant) : null),
        subtitle: Text([
          project.status.label(l),
          if (project.dueDate != null) context.formatDate(project.dueDate!),
          if (project.personIds.isNotEmpty) l.resultsCount(project.personIds.length),
        ].join(' · ')),
        trailing: overdue
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: scheme.errorContainer, borderRadius: BorderRadius.circular(20)),
                child: Text(l.projectOverdue, style: TextStyle(fontSize: 12, color: scheme.onErrorContainer)),
              )
            : null,
        onTap: () => context.push('/projects/${project.id}'),
      ),
    );
  }
}

class ProjectDetailScreen extends ConsumerWidget {
  const ProjectDetailScreen({super.key, required this.projectId});
  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final p = ref.watch(projectByIdProvider(projectId));
    if (p == null) return Scaffold(appBar: AppBar(), body: Center(child: Text(l.noResults)));
    final milestones = ref.watch(milestonesProvider).where((m) => m.projectId == p.id).toList();
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(tooltip: l.edit, icon: const Icon(Icons.edit_outlined), onPressed: () => context.push('/projects/${p.id}/edit')),
          IconButton(
            tooltip: l.delete,
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              if (!await confirmDialog(context, title: l.confirmDeleteTitle, message: l.confirmDeleteProject(p.name))) return;
              await ref.read(projectsRepositoryProvider).delete(p.id);
              if (context.mounted) context.popOrGo('/projects');
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 32),
        children: [
          Text(p.name, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(
            [
              p.status.label(l),
              p.priority.label(l),
              if (p.startDate != null && p.dueDate != null)
                '${context.formatDate(p.startDate!)} – ${context.formatDate(p.dueDate!)}'
              else if (p.dueDate != null)
                context.formatDate(p.dueDate!)
              else if (p.startDate != null)
                context.formatDate(p.startDate!),
            ].join(' · '),
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
          ),
          if (p.description != null) ...[const SizedBox(height: 12), Text(p.description!, style: theme.textTheme.bodyLarge)],
          if (p.personIds.isNotEmpty) ...[
            SectionHeader(l.fieldParticipants),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                for (final id in p.personIds)
                  if (ref.watch(personByIdProvider(id)) case final person?)
                    ActionChip(label: Text(person.shownName), onPressed: () => context.push('/people/${person.id}')),
              ],
            ),
          ],
          if (p.eventIds.isNotEmpty) ...[
            SectionHeader(l.fieldRelatedEvents),
            for (final id in p.eventIds)
              if (ref.watch(eventByIdProvider(id)) case final e?)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.event_outlined),
                    title: Text(e.title),
                    subtitle: Text(context.formatDate(e.date)),
                    onTap: () => context.push('/events/${e.id}/edit'),
                  ),
                ),
          ],
          if (milestones.isNotEmpty) ...[
            SectionHeader(l.milestones),
            for (final m in milestones)
              Card(
                child: ListTile(
                  leading: Icon(m.kind.icon),
                  title: Text(m.title),
                  subtitle: Text(context.formatDate(m.date)),
                  onTap: () => context.push('/milestones/${m.id}/edit'),
                ),
              ),
          ],
          if (p.notes != null) ...[SectionHeader(l.fieldNotes), Card(child: Padding(padding: const EdgeInsets.all(16), child: Text(p.notes!)))],
        ],
      ),
    );
  }
}

class ProjectFormScreen extends ConsumerStatefulWidget {
  const ProjectFormScreen({super.key, this.projectId});
  final String? projectId;

  @override
  ConsumerState<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends ConsumerState<ProjectFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _notes;
  LocalDate? _start;
  LocalDate? _due;
  late ProjectStatus _status;
  late EventPriority _priority;
  late Set<String> _personIds;
  late Set<String> _eventIds;
  Project? _existing;

  @override
  void initState() {
    super.initState();
    _existing = widget.projectId == null ? null : ref.read(projectByIdProvider(widget.projectId!));
    final p = _existing;
    _name = TextEditingController(text: p?.name);
    _description = TextEditingController(text: p?.description);
    _notes = TextEditingController(text: p?.notes);
    _start = p?.startDate;
    _due = p?.dueDate;
    _status = p?.status ?? ProjectStatus.active;
    _priority = p?.priority ?? EventPriority.normal;
    _personIds = {...?p?.personIds};
    _eventIds = {...?p?.eventIds};
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _notes.dispose();
    super.dispose();
  }

  String? _trim(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final project = Project(
      id: _existing?.id ?? const Uuid().v4(),
      name: _name.text.trim(),
      description: _trim(_description),
      startDate: _start,
      dueDate: _due,
      status: _status,
      priority: _priority,
      notes: _trim(_notes),
      personIds: _personIds.toList(),
      eventIds: _eventIds.toList(),
      createdAt: _existing?.createdAt ?? DateTime.now(),
    );
    await ref.read(projectsRepositoryProvider).save(project);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.savedSuccessfully)));
    if (_existing == null) {
      context.pushReplacement('/projects/${project.id}');
    } else {
      context.popOrGo('/projects');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final people = ref.watch(peopleProvider);
    final events = ref.watch(eventsProvider);
    const gap = SizedBox(height: 14);
    Widget chips<T>(String label, List<(String, String)> options, Set<String> selected) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final (id, name) in options)
                  FilterChip(
                    label: Text(name),
                    selected: selected.contains(id),
                    onSelected: (s) => setState(() => s ? selected.add(id) : selected.remove(id)),
                  ),
              ],
            ),
          ],
        );
    return Scaffold(
      appBar: AppBar(
        title: Text(_existing == null ? l.addProject : l.editProject),
        actions: [TextButton(key: const Key('project-save-top'), onPressed: _save, child: Text(l.save))],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              key: const Key('project-name'),
              controller: _name,
              decoration: InputDecoration(labelText: l.fieldName, prefixIcon: const Icon(Icons.title)),
              validator: (v) => (v == null || v.trim().isEmpty) ? l.errorRequired : null,
            ),
            gap,
            TextFormField(
              controller: _description,
              minLines: 2,
              maxLines: 6,
              decoration: InputDecoration(labelText: l.fieldDescription, alignLabelWithHint: true),
            ),
            gap,
            LocalDateFormField(label: l.fieldStartDate, initialValue: _start, onChanged: (v) => setState(() => _start = v)),
            gap,
            LocalDateFormField(
              key: const Key('project-due'),
              label: l.fieldDueDate,
              initialValue: _due,
              onChanged: (v) => setState(() => _due = v),
              validator: (v) => v != null && _start != null && v.isBefore(_start!) ? l.errorDueBeforeStart : null,
            ),
            gap,
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<ProjectStatus>(
                    initialValue: _status,
                    isExpanded: true,
                    decoration: InputDecoration(labelText: l.fieldStatus, isDense: true),
                    items: [for (final s in ProjectStatus.values) DropdownMenuItem(value: s, child: Text(s.label(l)))],
                    onChanged: (v) => setState(() => _status = v ?? _status),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<EventPriority>(
                    initialValue: _priority,
                    isExpanded: true,
                    decoration: InputDecoration(labelText: l.fieldPriority, isDense: true),
                    items: [for (final p in EventPriority.values) DropdownMenuItem(value: p, child: Text(p.label(l)))],
                    onChanged: (v) => setState(() => _priority = v ?? _priority),
                  ),
                ),
              ],
            ),
            gap,
            if (people.isNotEmpty) ...[chips(l.fieldParticipants, [for (final p in people) (p.id, p.shownName)], _personIds), gap],
            if (events.isNotEmpty) ...[chips(l.fieldRelatedEvents, [for (final e in events) (e.id, e.title)], _eventIds), gap],
            TextFormField(
              controller: _notes,
              minLines: 2,
              maxLines: 6,
              decoration: InputDecoration(labelText: l.fieldNotes, alignLabelWithHint: true),
            ),
            const SizedBox(height: 24),
            FilledButton(key: const Key('project-save'), onPressed: _save, child: Text(l.save)),
          ],
        ),
      ),
    );
  }
}
