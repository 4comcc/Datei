import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../shared/l10n_labels.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  static Future<void> showQuickAdd(BuildContext context) {
    final l = context.l10n;
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(8, 0, 8, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 8),
                child: Text(l.quickAddTitle, style: Theme.of(context).textTheme.titleMedium),
              ),
              ListTile(
                leading: const Icon(Icons.person_add_alt_1_outlined),
                title: Text(l.addPerson),
                onTap: () {
                  Navigator.pop(sheetContext);
                  context.push('/people/new');
                },
              ),
              ListTile(
                leading: const Icon(Icons.event_outlined),
                title: Text(l.addEvent),
                onTap: () {
                  Navigator.pop(sheetContext);
                  context.push('/events/new');
                },
              ),
              ListTile(
                enabled: false,
                leading: const Icon(Icons.autorenew),
                title: Text(l.addCommitment),
                subtitle: Text(l.comingInFullVersion),
              ),
              ListTile(
                enabled: false,
                leading: const Icon(Icons.auto_stories_outlined),
                title: Text(l.addMemory),
                subtitle: Text(l.comingInFullVersion),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final showFab = navigationShell.currentIndex != 4;
    return Scaffold(
      body: navigationShell,
      floatingActionButton: showFab
          ? FloatingActionButton(
              key: const Key('quick-add'),
              tooltip: l.quickAddTitle,
              onPressed: () => showQuickAdd(context),
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (i) => navigationShell.goBranch(i, initialLocation: i == navigationShell.currentIndex),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home), label: l.navHome),
          NavigationDestination(icon: const Icon(Icons.people_outline), selectedIcon: const Icon(Icons.people), label: l.navPeople),
          NavigationDestination(icon: const Icon(Icons.event_note_outlined), selectedIcon: const Icon(Icons.event_note), label: l.navEvents),
          NavigationDestination(
              icon: const Icon(Icons.calendar_month_outlined), selectedIcon: const Icon(Icons.calendar_month), label: l.navCalendar),
          NavigationDestination(icon: const Icon(Icons.more_horiz), label: l.navMore),
        ],
      ),
    );
  }
}
