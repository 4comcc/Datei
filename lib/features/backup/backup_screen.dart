import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/backup/backup_crypto.dart';
import '../../core/backup/backup_service.dart';
import '../../shared/l10n_labels.dart';
import 'backup_controller.dart';

class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  bool _busy = false;
  File? _safetyCopy;

  BackupController get _controller => ref.read(backupControllerProvider);

  @override
  void initState() {
    super.initState();
    _refreshSafetyCopy();
  }

  Future<void> _refreshSafetyCopy() async {
    try {
      final f = await _controller.latestSafetyCopy();
      if (mounted) setState(() => _safetyCopy = f);
    } catch (e) {
      debugPrint('Safety copy lookup failed: $e');
    }
  }

  void _toast(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<T?> _run<T>(Future<T> Function() action) async {
    setState(() => _busy = true);
    try {
      return await action();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _create() async {
    final l = context.l10n;
    final choice = await showDialog<_CreateChoice>(context: context, builder: (_) => const _CreateBackupDialog());
    if (choice == null || !mounted) return;
    try {
      final saved = await _run(() => _controller.createAndSave(password: choice.password));
      if (saved == true && mounted) _toast(l.backupSaved);
    } catch (e) {
      debugPrint('Backup failed: $e');
      if (mounted) _toast(l.backupFailed);
    }
  }

  Future<void> _restore() async {
    final l = context.l10n;
    Uint8List? bytes;
    try {
      bytes = await _controller.pickFile();
    } catch (e) {
      debugPrint('Pick failed: $e');
      if (mounted) _toast(l.backupReadFailed);
      return;
    }
    if (bytes == null || !mounted) return;
    await _verifyAndRestore(bytes);
  }

  Future<void> _undo() async {
    final l = context.l10n;
    final file = _safetyCopy;
    if (file == null) return;
    try {
      await _verifyAndRestore(await file.readAsBytes());
    } on FileSystemException {
      if (mounted) _toast(l.backupReadFailed);
    }
  }

  Future<void> _verifyAndRestore(Uint8List bytes) async {
    final l = context.l10n;
    final encrypted = _controller.isEncrypted(bytes);
    String? password;
    String? passwordError;
    LoadedBackup? loaded;
    while (loaded == null) {
      if (encrypted) {
        password = await showDialog<String>(
          context: context,
          builder: (_) => _PasswordDialog(error: passwordError),
        );
        if (password == null || !mounted) return;
      }
      try {
        loaded = await _run(() => _controller.load(bytes, password: password));
      } on BackupPasswordException {
        if (!encrypted || !mounted) return;
        passwordError = l.backupWrongPassword;
      } on BackupNewerVersionException {
        if (mounted) _toast(l.backupNewer);
        return;
      } on BackupFormatException {
        if (mounted) _toast(l.backupDamaged);
        return;
      } catch (e) {
        debugPrint('Backup load failed: $e');
        if (mounted) _toast(l.backupDamaged);
        return;
      }
      if (!mounted) return;
    }
    final backup = loaded;
    final ok = await showDialog<bool>(context: context, builder: (_) => _RestoreConfirmDialog(summary: backup.summary));
    if (ok != true || !mounted) return;
    try {
      await _run(() => _controller.restore(backup));
      if (mounted) _toast(l.backupRestored);
    } catch (e) {
      debugPrint('Restore failed: $e');
      if (mounted) _toast(l.backupRestoreFailed);
    }
    await _refreshSafetyCopy();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final safety = _safetyCopy;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.moduleBackup),
        bottom: _busy
            ? const PreferredSize(preferredSize: Size.fromHeight(4), child: LinearProgressIndicator())
            : null,
      ),
      body: AbsorbPointer(
        absorbing: _busy,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(l.backupHint, style: TextStyle(color: scheme.onSurfaceVariant)),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: [
                  ListTile(
                    key: const Key('backup-create'),
                    leading: const Icon(Icons.save_alt),
                    title: Text(l.backupCreate),
                    subtitle: Text(l.backupCreateHint),
                    onTap: _create,
                  ),
                  ListTile(
                    key: const Key('backup-restore'),
                    leading: const Icon(Icons.settings_backup_restore),
                    title: Text(l.backupRestore),
                    subtitle: Text(l.backupRestoreHint),
                    onTap: _restore,
                  ),
                  if (safety != null)
                    ListTile(
                      key: const Key('backup-undo'),
                      leading: const Icon(Icons.undo),
                      title: Text(l.backupUndo),
                      subtitle: Text(l.backupUndoHint(_formatModified(context, safety))),
                      onTap: _undo,
                    ),
                ],
              ),
            ),
            if (_busy)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(l.backupWorking, textAlign: TextAlign.center),
              ),
          ],
        ),
      ),
    );
  }

  String _formatModified(BuildContext context, File f) {
    try {
      return _formatDateTime(context, f.lastModifiedSync());
    } on FileSystemException {
      return '';
    }
  }
}

String _formatDateTime(BuildContext context, DateTime t) =>
    DateFormat.yMMMd(context.l10n.localeName).add_jm().format(t);

class _CreateChoice {
  const _CreateChoice(this.password);
  final String? password;
}

class _CreateBackupDialog extends StatefulWidget {
  const _CreateBackupDialog();

  @override
  State<_CreateBackupDialog> createState() => _CreateBackupDialogState();
}

class _CreateBackupDialogState extends State<_CreateBackupDialog> {
  final _form = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _encrypt = false;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _submit() {
    if (_encrypt && !_form.currentState!.validate()) return;
    Navigator.pop(context, _CreateChoice(_encrypt ? _password.text : null));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AlertDialog(
      title: Text(l.backupCreate),
      content: Form(
        key: _form,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SwitchListTile(
                key: const Key('backup-encrypt'),
                contentPadding: EdgeInsets.zero,
                title: Text(l.backupEncrypt),
                value: _encrypt,
                onChanged: (v) => setState(() => _encrypt = v),
              ),
              if (_encrypt) ...[
                TextFormField(
                  key: const Key('backup-password'),
                  controller: _password,
                  obscureText: true,
                  decoration: InputDecoration(labelText: l.backupPassword),
                  validator: (v) => (v ?? '').length < BackupController.minPasswordLength ? l.backupPasswordShort : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  key: const Key('backup-password-confirm'),
                  controller: _confirm,
                  obscureText: true,
                  decoration: InputDecoration(labelText: l.backupPasswordConfirm),
                  validator: (v) => v != _password.text ? l.backupPasswordMismatch : null,
                ),
                const SizedBox(height: 12),
                Text(l.backupPasswordWarning, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
        FilledButton(key: const Key('backup-create-go'), onPressed: _submit, child: Text(l.backupCreate)),
      ],
    );
  }
}

class _PasswordDialog extends StatefulWidget {
  const _PasswordDialog({this.error});
  final String? error;

  @override
  State<_PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<_PasswordDialog> {
  final _password = TextEditingController();

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (_password.text.isNotEmpty) Navigator.pop(context, _password.text);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AlertDialog(
      title: Text(l.backupPassword),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.backupEnterPassword),
          const SizedBox(height: 12),
          TextField(
            key: const Key('restore-password'),
            controller: _password,
            autofocus: true,
            obscureText: true,
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(labelText: l.backupPassword, errorText: widget.error),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
        FilledButton(key: const Key('restore-password-go'), onPressed: _submit, child: Text(l.continueAction)),
      ],
    );
  }
}

class _RestoreConfirmDialog extends StatelessWidget {
  const _RestoreConfirmDialog({required this.summary});
  final BackupSummary summary;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final rows = [
      (Icons.people_outline, l.navPeople, summary.count('persons')),
      (Icons.event_note_outlined, l.navEvents, summary.count('events')),
      (Icons.autorenew, l.commitments, summary.count('commitments')),
      (Icons.auto_stories_outlined, l.memories, summary.count('memories')),
      (Icons.photo_outlined, l.backupPhotos, summary.fileCount),
    ];
    return AlertDialog(
      title: Text(l.backupRestoreConfirmTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l.backupCreatedOn(_formatDateTime(context, summary.createdAt), '\u2066${summary.appVersion}\u2069'),
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            for (final (icon, label, count) in rows)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(icon, size: 20, color: scheme.primary),
                    const SizedBox(width: 12),
                    Expanded(child: Text(label)),
                    Text('$count', key: Key('restore-count-$label')),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            Text(l.backupRestoreWarning, style: TextStyle(color: scheme.error)),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l.cancel)),
        FilledButton(
          key: const Key('restore-confirm'),
          onPressed: () => Navigator.pop(context, true),
          child: Text(l.backupRestoreAction),
        ),
      ],
    );
  }
}
