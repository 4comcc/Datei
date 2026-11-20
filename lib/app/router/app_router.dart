import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/time_engine/local_date.dart';
import '../../features/calendar/calendar_screen.dart';
import '../../features/commitments/presentation/commitment_detail_screen.dart';
import '../../features/commitments/presentation/commitment_form_screen.dart';
import '../../features/commitments/presentation/commitments_screen.dart';
import '../../features/events/presentation/event_form_screen.dart';
import '../../features/events/presentation/event_types_screen.dart';
import '../../features/events/presentation/events_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/more/more_screen.dart';
import '../../features/onboarding/language_screen.dart';
import '../../features/onboarding/welcome_screen.dart';
import '../../features/people/presentation/categories_screen.dart';
import '../../features/people/presentation/custom_fields_screen.dart';
import '../../features/people/presentation/people_screen.dart';
import '../../features/people/presentation/person_detail_screen.dart';
import '../../features/people/presentation/person_form_screen.dart';
import '../../features/settings/settings_controller.dart';
import 'app_shell.dart';

final _rootKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  // Re-evaluate redirects whenever onboarding-relevant settings change.
  final refresh = ValueNotifier<int>(0);
  ref.listen(settingsProvider, (prev, next) {
    if (prev?.languageCode != next.languageCode || prev?.onboardingDone != next.onboardingDone) {
      refresh.value++;
    }
  });
  ref.onDispose(refresh.dispose);

  LocalDate? parseDate(String? s) {
    if (s == null) return null;
    try {
      return LocalDate.parse(s);
    } on FormatException {
      return null;
    }
  }

  final router = GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/home',
    refreshListenable: refresh,
    redirect: (context, state) {
      final settings = ref.read(settingsProvider);
      final loc = state.matchedLocation;
      if (settings.languageCode == null) return loc == '/language' ? null : '/language';
      if (!settings.onboardingDone) return loc == '/welcome' ? null : '/welcome';
      if (loc == '/language' || loc == '/welcome') return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/language', builder: (_, _) => const LanguageScreen()),
      GoRoute(path: '/welcome', builder: (_, _) => const WelcomeScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: '/home', builder: (_, _) => const HomeScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/people', builder: (_, _) => const PeopleScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/events', builder: (_, _) => const EventsScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/calendar', builder: (_, _) => const CalendarScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/more', builder: (_, _) => const MoreScreen())]),
        ],
      ),
      GoRoute(
        path: '/people/new',
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const PersonFormScreen(),
      ),
      GoRoute(
        path: '/people/:id',
        parentNavigatorKey: _rootKey,
        builder: (_, state) => PersonDetailScreen(personId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/people/:id/edit',
        parentNavigatorKey: _rootKey,
        builder: (_, state) => PersonFormScreen(personId: state.pathParameters['id']),
      ),
      GoRoute(
        path: '/settings/categories',
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const CategoriesScreen(),
      ),
      GoRoute(
        path: '/settings/custom-fields',
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const CustomFieldsScreen(),
      ),
      GoRoute(
        path: '/commitments',
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const CommitmentsScreen(),
      ),
      GoRoute(
        path: '/commitments/new',
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const CommitmentFormScreen(),
      ),
      GoRoute(
        path: '/commitments/:id',
        parentNavigatorKey: _rootKey,
        builder: (_, state) => CommitmentDetailScreen(commitmentId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/commitments/:id/edit',
        parentNavigatorKey: _rootKey,
        builder: (_, state) => CommitmentFormScreen(commitmentId: state.pathParameters['id']),
      ),
      GoRoute(
        path: '/settings/event-types',
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const EventTypesScreen(),
      ),
      GoRoute(
        path: '/events/new',
        parentNavigatorKey: _rootKey,
        builder: (_, state) => EventFormScreen(
          initialDate: parseDate(state.uri.queryParameters['date']),
          initialPersonId: state.uri.queryParameters['person'],
        ),
      ),
      GoRoute(
        path: '/events/:id/edit',
        parentNavigatorKey: _rootKey,
        builder: (_, state) => EventFormScreen(
          eventId: state.pathParameters['id'],
          occurrenceDate: parseDate(state.uri.queryParameters['occurrence']),
        ),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
