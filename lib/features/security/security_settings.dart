import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/security/pin_hasher.dart';
import '../../shared/l10n_labels.dart';
import 'app_lock.dart';

/// Settings → Security & privacy.
class SecuritySettingsCard extends ConsumerWidget {
  const SecuritySettingsCard({super.key});

  void _toast(BuildContext context, String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  String _attemptMessage(BuildContext context, WidgetRef ref, PinAttempt r) => r == PinAttempt.lockedOut
      ? context.l10n.pinLockedOut(ref.read(appLockProvider.notifier).lockoutRemainingSeconds())
      : context.l10n.pinWrong;

  Future<void> _enable(BuildContext context, WidgetRef ref) async {
    final l = context.l10n;
    final pins = await showPinDialog(
      context,
      title: l.pinSetupTitle,
      labels: [l.pinNew, l.pinConfirm],
      note: l.pinForgotWarning,
      mustMatch: true,
    );
    if (pins == null) return;
    await ref.read(appLockProvider.notifier).enable(pins[0]);
    if (context.mounted) _toast(context, l.lockEnabledDone);
  }

  Future<void> _disable(BuildContext context, WidgetRef ref) async {
    final l = context.l10n;
    final pins = await showPinDialog(context, title: l.disableLockTitle, labels: [l.pinCurrent]);
    if (pins == null) return;
    final r = await ref.read(appLockProvider.notifier).disable(pins[0]);
    if (context.mounted) _toast(context, r == PinAttempt.ok ? l.lockDisabledDone : _attemptMessage(context, ref, r));
  }

  Future<void> _changePin(BuildContext context, WidgetRef ref) async {
    final l = context.l10n;
    final pins = await showPinDialog(
      context,
      title: l.changePin,
      labels: [l.pinCurrent, l.pinNew, l.pinConfirm],
      mustMatch: true,
    );
    if (pins == null) return;
    final r = await ref.read(appLockProvider.notifier).changePin(pins[0], pins[1]);
    if (context.mounted) _toast(context, r == PinAttempt.ok ? l.pinChangedDone : _attemptMessage(context, ref, r));
  }

  Future<void> _biometric(BuildContext context, WidgetRef ref, bool on) async {
    final l = context.l10n;
    final ok = await ref.read(appLockProvider.notifier).setBiometric(on, reason: l.biometricReason);
    if (!ok && context.mounted) _toast(context, l.biometricFailed);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final lock = ref.watch(appLockProvider);
    final controller = ref.read(appLockProvider.notifier);
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            key: const Key('app-lock'),
            secondary: const Icon(Icons.lock_outline),
            title: Text(l.appLock),
            subtitle: Text(l.appLockHint),
            value: lock.enabled,
            onChanged: !lock.loaded ? null : (on) => on ? _enable(context, ref) : _disable(context, ref),
          ),
          if (lock.enabled) ...[
            ListTile(
              key: const Key('change-pin'),
              leading: const Icon(Icons.pin_outlined),
              title: Text(l.changePin),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _changePin(context, ref),
            ),
            if (lock.biometricAvailable)
              SwitchListTile(
                key: const Key('biometric-lock'),
                secondary: const Icon(Icons.fingerprint),
                title: Text(l.useBiometrics),
                subtitle: Text(l.useBiometricsHint),
                value: lock.biometricEnabled,
                onChanged: (on) => _biometric(context, ref, on),
              ),
            ListTile(leading: const Icon(Icons.timer_outlined), title: Text(l.lockAfter)),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 12),
              child: SegmentedButton<int>(
                key: const Key('lock-after'),
                showSelectedIcon: false,
                segments: [
                  for (final s in AppLockController.lockAfterChoices)
                    ButtonSegment(value: s, label: Text(s == 0 ? l.lockImmediately : l.lockAfterMinutes(s ~/ 60))),
                ],
                selected: {lock.lockAfterSeconds},
                onSelectionChanged: (s) => controller.setLockAfter(s.first),
              ),
            ),
          ],
          ListTile(
            key: const Key('open-privacy'),
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(l.privacyPolicy),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/privacy'),
          ),
        ],
      ),
    );
  }
}

/// Asks for one or more PINs (4–8 digits). With [mustMatch], the last field must
/// equal the one before it. Returns the entered values, or null when cancelled.
Future<List<String>?> showPinDialog(
  BuildContext context, {
  required String title,
  required List<String> labels,
  String? note,
  bool mustMatch = false,
}) =>
    showDialog<List<String>>(
      context: context,
      builder: (_) => _PinDialog(title: title, labels: labels, note: note, mustMatch: mustMatch),
    );

class _PinDialog extends StatefulWidget {
  const _PinDialog({required this.title, required this.labels, this.note, required this.mustMatch});
  final String title;
  final List<String> labels;
  final String? note;
  final bool mustMatch;

  @override
  State<_PinDialog> createState() => _PinDialogState();
}

class _PinDialogState extends State<_PinDialog> {
  final _form = GlobalKey<FormState>();
  late final _controllers = [for (final _ in widget.labels) TextEditingController()];

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    Navigator.pop(context, [for (final c in _controllers) c.text]);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final last = _controllers.length - 1;
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _form,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.note != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(widget.note!, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                ),
              for (var i = 0; i < _controllers.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TextFormField(
                    key: Key('pin-field-$i'),
                    controller: _controllers[i],
                    autofocus: i == 0,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    textDirection: TextDirection.ltr,
                    maxLength: 8,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textInputAction: i == last ? TextInputAction.done : TextInputAction.next,
                    onFieldSubmitted: i == last ? (_) => _submit() : null,
                    decoration: InputDecoration(labelText: widget.labels[i], counterText: ''),
                    validator: (v) {
                      if (!PinHasher.isValidPin(v ?? '')) return l.pinFormatError;
                      if (widget.mustMatch && i == last && last > 0 && v != _controllers[last - 1].text) return l.pinMismatch;
                      return null;
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
        FilledButton(key: const Key('pin-dialog-ok'), onPressed: _submit, child: Text(l.save)),
      ],
    );
  }
}
