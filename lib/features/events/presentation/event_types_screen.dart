import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../shared/l10n_labels.dart';
import '../../../shared/widgets/common.dart';
import '../../../shared/widgets/name_color_dialog.dart';
import '../../people/presentation/category_dialogs.dart';
import '../domain/event.dart';
import 'events_providers.dart';

/// Creates or edits a user event type. Returns the saved type.
Future<EventTypeInfo?> showEventTypeEditor(BuildContext context, WidgetRef ref, {EventTypeInfo? existing}) async {
  final l = context.l10n;
  final result = await showNameColorDialog(
    context,
    title: existing == null ? l.addEventType : l.editEventType,
    label: l.eventTypeName,
    initialName: existing?.name,
    initialColor: existing?.color,
  );
  if (result == null) return null;
  final (name, color) = result;
  final repo = ref.read(eventTypesRepositoryProvider);
  if (existing == null) return repo.create(name, color: color);
  await repo.rename(existing.id, name, color: color);
  return EventTypeInfo(id: existing.id, name: name, color: color, sortOrder: existing.sortOrder);
}

class EventTypesScreen extends ConsumerWidget {
  const EventTypesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final all = ref.watch(eventTypesProvider).value ?? const <EventTypeInfo>[];
    final custom = all.where((t) => !t.isSystem).toList();
    final system = all.where((t) => t.isSystem).toList();
    return Scaffold(
      appBar: AppBar(title: Text(l.manageEventTypes)),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('add-event-type'),
        onPressed: () => showEventTypeEditor(context, ref),
        icon: const Icon(Icons.add),
        label: Text(l.addEventType),
      ),
      body: ListView(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 96),
        children: [
          SectionHeader(l.yourEventTypes),
          if (custom.isEmpty)
            InlineEmpty(l.noCustomEventTypes)
          else
            Card(
              child: Column(
                children: [
                  for (final t in custom)
                    ListTile(
                      leading: CircleAvatar(radius: 10, backgroundColor: Color(t.color ?? pickerColors.first)),
                      title: Text(t.label(l)),
                      onTap: () => showEventTypeEditor(context, ref, existing: t),
                      trailing: IconButton(
                        tooltip: l.delete,
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async {
                          final ok = await confirmDialog(context,
                              title: l.confirmDeleteTitle, message: l.deleteEventTypeConfirm(t.label(l)));
                          if (ok) await ref.read(eventTypesRepositoryProvider).delete(t.id);
                        },
                      ),
                    ),
                ],
              ),
            ),
          SectionHeader(l.builtInCategories),
          Card(
            child: Column(
              children: [for (final t in system) ListTile(leading: Icon(t.icon), title: Text(t.label(l)))],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(l.systemEventTypesNote, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ),
        ],
      ),
    );
  }
}
