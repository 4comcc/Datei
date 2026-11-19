import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../shared/l10n_labels.dart';
import '../../shared/widgets/datei_logo.dart';
import '../settings/settings_controller.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  void _showSignInUnavailable(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(context.l10n.signInComingSoon), duration: const Duration(seconds: 5)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Center(child: DateiLogo(size: 104)),
              const SizedBox(height: 20),
              Text('Datei',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                    letterSpacing: 0.5,
                  )),
              const SizedBox(height: 4),
              Text(l.tagline,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.tertiary)),
              const SizedBox(height: 28),
              Text(l.welcomeTitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(l.welcomeBody,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              const Spacer(flex: 2),
              OutlinedButton.icon(
                onPressed: () => _showSignInUnavailable(context),
                icon: const Text('G', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                label: Text(l.signInGoogle),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => _showSignInUnavailable(context),
                icon: const Icon(Icons.facebook, color: Color(0xFF1877F2)),
                label: Text(l.signInFacebook),
              ),
              const SizedBox(height: 12),
              FilledButton(
                key: const Key('continue-guest'),
                onPressed: () => ref.read(settingsProvider.notifier).completeOnboarding(),
                child: Text(l.continueAsGuest),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
