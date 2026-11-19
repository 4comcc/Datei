import 'dart:ui' as ui;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/localization/gen/app_localizations.dart';
import '../../shared/widgets/datei_logo.dart';
import '../settings/settings_controller.dart';

/// First-run language picker. Device language is pre-selected, but the user decides.
class LanguageScreen extends ConsumerStatefulWidget {
  const LanguageScreen({super.key});

  @override
  ConsumerState<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends ConsumerState<LanguageScreen> {
  late String _selected;

  @override
  void initState() {
    super.initState();
    final device = ui.PlatformDispatcher.instance.locale.languageCode;
    _selected = device == 'ar' ? 'ar' : 'en';
  }

  @override
  Widget build(BuildContext context) {
    // Preview the screen in the language being selected.
    final l = lookupAppLocalizations(Locale(_selected));
    final theme = Theme.of(context);
    return Directionality(
      textDirection: _selected == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                const Center(child: DateiLogo(size: 88)),
                const SizedBox(height: 28),
                Text(l.chooseLanguageTitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(l.chooseLanguageHint,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                const SizedBox(height: 32),
                _LanguageOption(
                  key: const Key('lang-ar'),
                  label: 'العربية',
                  sub: 'Arabic',
                  selected: _selected == 'ar',
                  onTap: () => setState(() => _selected = 'ar'),
                ),
                const SizedBox(height: 12),
                _LanguageOption(
                  key: const Key('lang-en'),
                  label: 'English',
                  sub: 'الإنجليزية',
                  selected: _selected == 'en',
                  onTap: () => setState(() => _selected = 'en'),
                ),
                const Spacer(flex: 2),
                FilledButton(
                  key: const Key('lang-continue'),
                  onPressed: () => ref.read(settingsProvider.notifier).setLanguage(_selected),
                  child: Text(l.continueAction),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({super.key, required this.label, required this.sub, required this.selected, required this.onTap});
  final String label;
  final String sub;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: selected ? scheme.primaryContainer : scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: selected ? scheme.primary : scheme.outlineVariant, width: selected ? 2 : 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    Text(sub, style: TextStyle(color: scheme.onSurfaceVariant)),
                  ],
                ),
              ),
              Icon(selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: selected ? scheme.primary : scheme.outline),
            ],
          ),
        ),
      ),
    );
  }
}
