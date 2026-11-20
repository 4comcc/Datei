import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../shared/l10n_labels.dart';
import '../../shared/widgets/datei_logo.dart';
import 'app_lock.dart';

/// Keeps the app (and its navigation state) mounted but hidden while locked.
class LockGate extends ConsumerStatefulWidget {
  const LockGate({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<LockGate> createState() => _LockGateState();
}

class _LockGateState extends ConsumerState<LockGate> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onPause: () => ref.read(appLockProvider.notifier).onBackground(),
      onResume: () => ref.read(appLockProvider.notifier).onForeground(),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lock = ref.watch(appLockProvider);
    return Stack(
      fit: StackFit.expand,
      children: [
        Offstage(offstage: lock.blocking, child: TickerMode(enabled: !lock.blocking, child: widget.child)),
        if (!lock.loaded)
          ColoredBox(color: Theme.of(context).colorScheme.surface)
        else if (lock.locked)
          const LockScreen(),
      ],
    );
  }
}

class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  static const _maxDigits = 8;
  String _pin = '';
  String? _error;
  bool _busy = false;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _startTickerIfLockedOut();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && ref.read(appLockProvider).biometricEnabled) _biometric();
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  int get _remaining => ref.read(appLockProvider.notifier).lockoutRemainingSeconds();

  void _startTickerIfLockedOut() {
    _ticker?.cancel();
    if (_remaining <= 0) return;
    _ticker = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      setState(() {});
      if (_remaining <= 0) t.cancel();
    });
  }

  void _digit(String d) {
    if (_busy || _pin.length >= _maxDigits || _remaining > 0) return;
    HapticFeedback.selectionClick();
    setState(() {
      _pin += d;
      _error = null;
    });
  }

  void _backspace() {
    if (_busy || _pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _submit() async {
    if (_busy || _pin.length < 4) return;
    final l = context.l10n;
    setState(() => _busy = true);
    final result = await ref.read(appLockProvider.notifier).unlockWithPin(_pin);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _pin = '';
      _error = switch (result) {
        PinAttempt.ok => null,
        PinAttempt.wrong => l.pinWrong,
        PinAttempt.lockedOut => null,
      };
    });
    if (result == PinAttempt.wrong) HapticFeedback.heavyImpact();
    if (result == PinAttempt.lockedOut) _startTickerIfLockedOut();
  }

  Future<void> _biometric() async {
    if (_busy) return;
    final l = context.l10n;
    setState(() => _busy = true);
    final ok = await ref.read(appLockProvider.notifier).unlockWithBiometrics(l.biometricReason);
    if (!mounted) return;
    setState(() => _busy = false);
    if (!ok) setState(() => _error = l.biometricFailed);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final lock = ref.watch(appLockProvider);
    final remaining = _remaining;
    final message = remaining > 0 ? l.pinLockedOut(remaining) : _error;

    return Material(
      key: const Key('lock-screen'),
      color: scheme.surface,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const DateiLogo(size: 64),
                  const SizedBox(height: 16),
                  Text(l.lockedTitle, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(l.enterPin, style: TextStyle(color: scheme.onSurfaceVariant)),
                  const SizedBox(height: 20),
                  Semantics(
                    label: l.enterPin,
                    value: '${_pin.length}',
                    child: SizedBox(
                      height: 16,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (var i = 0; i < (_pin.length < 4 ? 4 : _pin.length); i++)
                            Container(
                              width: 14,
                              height: 14,
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: i < _pin.length ? scheme.primary : null,
                                border: Border.all(color: scheme.primary, width: 1.5),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 40,
                    child: Center(
                      child: message == null
                          ? null
                          : Text(message,
                              key: const Key('lock-message'),
                              textAlign: TextAlign.center,
                              style: TextStyle(color: scheme.error)),
                    ),
                  ),
                  // Keypads keep 1-2-3 left to right in every language.
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Column(
                      children: [
                        for (final row in const [
                          ['1', '2', '3'],
                          ['4', '5', '6'],
                          ['7', '8', '9'],
                        ])
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [for (final d in row) _Key(key: Key('pin-key-$d'), label: d, onTap: () => _digit(d))],
                          ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _Key(
                              key: const Key('pin-back'),
                              semantics: l.delete,
                              icon: Icons.backspace_outlined,
                              onTap: _backspace,
                            ),
                            _Key(key: const Key('pin-key-0'), label: '0', onTap: () => _digit('0')),
                            _Key(
                              key: const Key('pin-ok'),
                              semantics: l.unlock,
                              icon: Icons.check,
                              filled: true,
                              onTap: _pin.length >= 4 && remaining == 0 ? _submit : null,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (lock.biometricEnabled) ...[
                    const SizedBox(height: 12),
                    TextButton.icon(
                      key: const Key('lock-biometric'),
                      onPressed: _busy ? null : _biometric,
                      icon: const Icon(Icons.fingerprint),
                      label: Text(l.useBiometrics),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({super.key, this.label, this.icon, this.semantics, this.filled = false, required this.onTap});
  final String? label;
  final IconData? icon;
  final String? semantics;
  final bool filled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = filled ? (onTap == null ? scheme.surfaceContainerHighest : scheme.primary) : scheme.surfaceContainerHigh;
    final fg = filled ? (onTap == null ? scheme.onSurfaceVariant : scheme.onPrimary) : scheme.onSurface;
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Semantics(
        button: true,
        label: semantics ?? label,
        excludeSemantics: true,
        child: Material(
          color: bg,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox.square(
              dimension: 72,
              child: Center(
                child: icon != null
                    ? Icon(icon, color: fg)
                    : Text(label!, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w500, color: fg)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
