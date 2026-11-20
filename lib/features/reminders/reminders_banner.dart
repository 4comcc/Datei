import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../shared/l10n_labels.dart';
import '../settings/settings_controller.dart';
import 'reminder_sync.dart';

/// Turns reminders on, asking Android for permission first. Returns whether enabled.
Future<bool> enableReminders(BuildContext context, WidgetRef ref) async {
  final granted = await ref.read(notificationGatewayProvider).requestPermission();
  if (!granted) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.remindersPermissionDenied)));
    }
    return false;
  }
  await ref.read(settingsProvider.notifier).setRemindersEnabled(true);
  return true;
}

/// Shown where reminders matter while they are switched off.
class RemindersOffBanner extends ConsumerWidget {
  const RemindersOffBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(settingsProvider.select((s) => s.remindersEnabled))) return const SizedBox.shrink();
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        color: scheme.tertiaryContainer,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 8, 8),
          child: Row(
            children: [
              Icon(Icons.notifications_off_outlined, color: scheme.onTertiaryContainer),
              const SizedBox(width: 12),
              Expanded(child: Text(l.remindersOffBanner, style: TextStyle(color: scheme.onTertiaryContainer))),
              TextButton(key: const Key('banner-turn-on'), onPressed: () => enableReminders(context, ref), child: Text(l.turnOn)),
            ],
          ),
        ),
      ),
    );
  }
}
