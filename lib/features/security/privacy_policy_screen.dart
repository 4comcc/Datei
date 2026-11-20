import 'package:material_ui/material_ui.dart';

import '../../core/time_engine/local_date.dart';
import '../../shared/l10n_labels.dart';

/// In-app privacy policy (ADR-067). Keep in sync with docs/PRIVACY_POLICY.md.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const lastUpdated = LocalDate(2026, 11, 20);

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final sections = [
      (l.privacyStoredTitle, l.privacyStoredBody),
      (l.privacyPhotosTitle, l.privacyPhotosBody),
      (l.privacyNotificationsTitle, l.privacyNotificationsBody),
      (l.privacyBackupTitle, l.privacyBackupBody),
      (l.privacySecurityTitle, l.privacySecurityBody),
      (l.privacyAccountsTitle, l.privacyAccountsBody),
      (l.privacyShareTitle, l.privacyShareBody),
      (l.privacyDeleteTitle, l.privacyDeleteBody),
      (l.privacyChangesTitle, l.privacyChangesBody),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l.privacyPolicy)),
      body: ListView(
        padding: const EdgeInsetsDirectional.fromSTEB(20, 8, 20, 32),
        children: [
          Text(l.privacyUpdated(context.formatDate(lastUpdated)), style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 12),
          Text(l.privacyIntro, style: theme.textTheme.bodyLarge),
          for (final (title, body) in sections) ...[
            const SizedBox(height: 20),
            Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(body, style: theme.textTheme.bodyMedium?.copyWith(height: 1.5)),
          ],
        ],
      ),
    );
  }
}
