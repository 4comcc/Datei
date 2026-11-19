import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../shared/l10n_labels.dart';
import '../../shared/widgets/common.dart';
import '../settings/settings_controller.dart';

const appVersion = '0.2.1';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final l = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.resetData),
        content: Text(l.resetDataConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancel)),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              minimumSize: const Size(64, 40),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.delete),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(dataMaintenanceRepositoryProvider).eraseAllUserData();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.deletedSuccessfully)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l.settingsTitle)),
      body: ListView(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 32),
        children: [
          SectionHeader(l.settingsLanguage),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'ar', label: Text('العربية')),
              ButtonSegment(value: 'en', label: Text('English')),
            ],
            selected: {settings.languageCode ?? 'en'},
            onSelectionChanged: (s) => controller.setLanguage(s.first),
          ),
          SectionHeader(l.settingsTheme),
          SegmentedButton<ThemeMode>(
            segments: [
              ButtonSegment(value: ThemeMode.system, label: Text(l.themeSystem), icon: const Icon(Icons.brightness_auto)),
              ButtonSegment(value: ThemeMode.light, label: Text(l.themeLight), icon: const Icon(Icons.light_mode_outlined)),
              ButtonSegment(value: ThemeMode.dark, label: Text(l.themeDark), icon: const Icon(Icons.dark_mode_outlined)),
            ],
            selected: {settings.themeMode},
            onSelectionChanged: (s) => controller.setThemeMode(s.first),
          ),
          SectionHeader(l.settingsAccount),
          Card(
            child: ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(l.continueAsGuest),
              subtitle: Text(l.guestAccountStatus),
            ),
          ),
          SectionHeader(l.moreModulesTitle),
          Card(
            child: Column(
              children: [
                for (final (icon, title) in [
                  (Icons.autorenew, l.moduleCommitments),
                  (Icons.auto_stories_outlined, l.moduleMemories),
                  (Icons.timeline, l.moduleTimeline),
                  (Icons.bar_chart, l.moduleReports),
                  (Icons.backup_outlined, l.moduleBackup),
                ])
                  ListTile(
                    enabled: false,
                    leading: Icon(icon),
                    title: Text(title),
                    subtitle: Text(l.comingInFullVersion),
                  ),
              ],
            ),
          ),
          SectionHeader(l.settingsData),
          Card(
            child: ListTile(
              leading: Icon(Icons.delete_forever_outlined, color: scheme.error),
              title: Text(l.resetData, style: TextStyle(color: scheme.error)),
              onTap: () => _confirmReset(context, ref),
            ),
          ),
          SectionHeader(l.aboutTitle),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text('Datei — ${l.tagline}'),
              subtitle: Text(l.prototypeNotice(appVersion)),
            ),
          ),
        ],
      ),
    );
  }
}
