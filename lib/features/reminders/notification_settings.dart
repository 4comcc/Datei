import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../shared/l10n_labels.dart';
import '../settings/settings_controller.dart';
import 'reminder_sync.dart';
import 'reminders_banner.dart';

class NotificationSettingsCard extends ConsumerWidget {
  const NotificationSettingsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final s = ref.watch(settingsProvider);
    final c = ref.read(settingsProvider.notifier);
    final parts = s.reminderTime.split(':');
    final time = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            key: const Key('reminders-enabled'),
            secondary: const Icon(Icons.notifications_outlined),
            title: Text(l.enableReminders),
            subtitle: Text(l.enableRemindersHint),
            value: s.remindersEnabled,
            onChanged: (v) => v ? enableReminders(context, ref) : c.setRemindersEnabled(false),
          ),
          if (s.remindersEnabled) ...[
            ListTile(
              leading: const Icon(Icons.schedule),
              title: Text(l.defaultReminderTime),
              trailing: Text(time.format(context)),
              onTap: () async {
                final t = await showTimePicker(context: context, initialTime: time);
                if (t != null) {
                  await c.setReminderTime('${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}');
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.cake_outlined),
              title: Text(l.birthdayReminders),
              trailing: DropdownButton<int>(
                value: s.birthdayReminderDays ?? -1,
                underline: const SizedBox.shrink(),
                items: [
                  DropdownMenuItem(value: -1, child: Text(l.reminderOff)),
                  for (final d in const [0, 1, 3, 7]) DropdownMenuItem(value: d, child: Text(l.reminderDaysBefore(d))),
                ],
                onChanged: (v) => c.setBirthdayReminderDays(v == null || v < 0 ? null : v),
              ),
            ),
            SwitchListTile(
              secondary: const Icon(Icons.alarm_on_outlined),
              title: Text(l.preciseReminders),
              subtitle: Text(l.preciseRemindersHint),
              value: s.preciseReminders,
              onChanged: (v) async {
                if (v) {
                  final gateway = ref.read(notificationGatewayProvider);
                  final ok = await gateway.canScheduleExact() || await gateway.requestExactPermission();
                  await c.setPreciseReminders(ok || await gateway.canScheduleExact());
                } else {
                  await c.setPreciseReminders(false);
                }
              },
            ),
            ListTile(
              key: const Key('test-notification'),
              leading: const Icon(Icons.notification_add_outlined),
              title: Text(l.testNotification),
              onTap: () => ref.read(notificationGatewayProvider).showNow(title: 'Datei', body: l.testNotificationBody),
            ),
          ],
        ],
      ),
    );
  }
}
