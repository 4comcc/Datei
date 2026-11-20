import 'dart:ui' as ui;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:uuid/uuid.dart';

import '../../../core/time_engine/local_date.dart';
import '../../../shared/l10n_labels.dart';
import '../../../shared/navigation.dart';
import '../../../shared/widgets/date_field.dart';
import '../../people/presentation/category_dialogs.dart';
import '../../settings/settings_controller.dart';
import '../domain/commitment.dart';
import 'commitments_providers.dart';
import 'reminder_days_field.dart';

const commonCurrencies = ['EGP', 'SAR', 'AED', 'KWD', 'QAR', 'BHD', 'OMR', 'JOD', 'USD', 'EUR', 'GBP'];

String _currencyForDevice() {
  final country = ui.PlatformDispatcher.instance.locale.countryCode;
  return switch (country) {
    'EG' => 'EGP',
    'SA' => 'SAR',
    'AE' => 'AED',
    'KW' => 'KWD',
    'QA' => 'QAR',
    'BH' => 'BHD',
    'OM' => 'OMR',
    'JO' => 'JOD',
    'GB' => 'GBP',
    'DE' || 'FR' || 'IT' || 'ES' || 'NL' => 'EUR',
    _ => 'USD',
  };
}

class CommitmentFormScreen extends ConsumerStatefulWidget {
  const CommitmentFormScreen({super.key, this.commitmentId});
  final String? commitmentId;

  @override
  ConsumerState<CommitmentFormScreen> createState() => _CommitmentFormScreenState();
}

class _CommitmentFormScreenState extends ConsumerState<CommitmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _provider;
  late final TextEditingController _amount;
  late final TextEditingController _reference;
  late final TextEditingController _url;
  late final TextEditingController _notes;
  late String _typeId;
  LocalDate? _start;
  LocalDate? _expiry;
  LocalDate? _renewBy;
  late String _currency;
  int? _renewalMonths;
  late CommitmentLifecycle _lifecycle;
  late List<int> _reminderDays;
  Commitment? _existing;
  bool _saving = false;

  static final _urlPattern = RegExp(r'^https?://\S+\.\S+$');

  @override
  void initState() {
    super.initState();
    _existing = widget.commitmentId == null ? null : ref.read(commitmentByIdProvider(widget.commitmentId!));
    final c = _existing;
    _name = TextEditingController(text: c?.name);
    _provider = TextEditingController(text: c?.providerName);
    _amount = TextEditingController(text: c?.amountMinor == null ? null : CommitmentRules.formatAmountInput(c!.amountMinor!));
    _reference = TextEditingController(text: c?.referenceNumber);
    _url = TextEditingController(text: c?.serviceUrl);
    _notes = TextEditingController(text: c?.notes);
    _typeId = c?.typeId ?? CommitmentType.subscription.id;
    _start = c?.startDate;
    _expiry = c?.expiryDate;
    _renewBy = c?.renewalDate;
    _currency = c?.currency ?? ref.read(initialSettingsProvider)[SettingKeys.lastCurrency] ?? _currencyForDevice();
    _renewalMonths = c == null ? 12 : c.renewalMonths;
    _lifecycle = c?.lifecycle ?? CommitmentLifecycle.active;
    _reminderDays = [...(c?.reminderDays ?? defaultCommitmentReminderDays)];
  }

  @override
  void dispose() {
    for (final x in [_name, _provider, _amount, _reference, _url, _notes]) {
      x.dispose();
    }
    super.dispose();
  }

  String? _trim(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final amount = _trim(_amount) == null ? null : CommitmentRules.parseAmount(_amount.text);
    final c = Commitment(
      id: _existing?.id ?? const Uuid().v4(),
      name: _name.text.trim(),
      typeId: _typeId,
      providerName: _trim(_provider),
      startDate: _start,
      expiryDate: _expiry!,
      renewalDate: _renewBy,
      amountMinor: amount,
      currency: amount == null ? null : _currency,
      renewalMonths: _renewalMonths,
      referenceNumber: _trim(_reference),
      serviceUrl: _trim(_url),
      notes: _trim(_notes),
      lifecycle: _lifecycle,
      reminderDays: _reminderDays,
      createdAt: _existing?.createdAt ?? DateTime.now(),
    );
    try {
      await ref.read(commitmentsRepositoryProvider).save(c);
      if (amount != null) await ref.read(settingsRepositoryProvider).set(SettingKeys.lastCurrency, _currency);
    } catch (_) {
      if (mounted) setState(() => _saving = false);
      rethrow;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.savedSuccessfully)));
    if (_existing == null) {
      context.pushReplacement('/commitments/${c.id}');
    } else {
      context.popOrGo('/commitments');
    }
  }

  String _periodLabel(int? months) {
    final l = context.l10n;
    if (months == null) return l.periodNone;
    if (months == 12) return l.repeatYearly;
    if (months == 1) return l.repeatMonthly;
    if (months % 12 == 0) return l.everyN(months ~/ 12, l.unitYears(months ~/ 12));
    return l.everyN(months, l.unitMonths(months));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    const gap = SizedBox(height: 14);
    return Scaffold(
      appBar: AppBar(
        title: Text(_existing == null ? l.addCommitment : l.editCommitment),
        actions: [TextButton(key: const Key('commitment-save-top'), onPressed: _saving ? null : _save, child: Text(l.save))],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              key: const Key('commitment-name'),
              controller: _name,
              decoration: InputDecoration(labelText: l.fieldName, prefixIcon: const Icon(Icons.title)),
              validator: (v) => (v == null || v.trim().isEmpty) ? l.errorRequired : null,
            ),
            gap,
            DropdownButtonFormField<String>(
              initialValue: _typeId,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: l.fieldCommitmentType,
                prefixIcon: Icon(CommitmentType.fromId(_typeId).icon),
              ),
              items: [for (final t in CommitmentType.values) DropdownMenuItem(value: t.id, child: Text(t.label(l)))],
              onChanged: (v) => setState(() => _typeId = v ?? _typeId),
            ),
            gap,
            TextFormField(
              controller: _provider,
              decoration: InputDecoration(labelText: l.fieldProvider, prefixIcon: const Icon(Icons.business_outlined)),
            ),
            gap,
            LocalDateFormField(
              key: const Key('commitment-expiry'),
              label: l.fieldExpiryDate,
              initialValue: _expiry,
              clearable: false,
              onChanged: (v) => setState(() => _expiry = v),
              validator: (v) {
                if (v == null) return l.errorDateRequired;
                if (_start != null && v.isBefore(_start!)) return l.errorExpiryBeforeStart;
                return null;
              },
            ),
            gap,
            LocalDateFormField(
              label: l.fieldRenewalDate,
              initialValue: _renewBy,
              onChanged: (v) => setState(() => _renewBy = v),
            ),
            gap,
            LocalDateFormField(
              label: l.fieldStartDate,
              initialValue: _start,
              onChanged: (v) => setState(() => _start = v),
            ),
            gap,
            DropdownButtonFormField<int?>(
              initialValue: _renewalMonths,
              isExpanded: true,
              decoration: InputDecoration(labelText: l.fieldRenewalPeriod, prefixIcon: const Icon(Icons.autorenew)),
              items: [
                for (final m in const <int?>[null, 1, 3, 6, 12, 24, 36, 60])
                  DropdownMenuItem(value: m, child: Text(_periodLabel(m))),
              ],
              onChanged: (v) => setState(() => _renewalMonths = v),
            ),
            gap,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    key: const Key('commitment-amount'),
                    controller: _amount,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(labelText: l.fieldAmount, prefixIcon: const Icon(Icons.payments_outlined)),
                    validator: (v) =>
                        (v != null && v.trim().isNotEmpty && CommitmentRules.parseAmount(v) == null) ? l.errorInvalidAmount : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    initialValue: commonCurrencies.contains(_currency) ? _currency : 'USD',
                    isExpanded: true,
                    decoration: InputDecoration(labelText: l.fieldCurrency),
                    items: [for (final c in commonCurrencies) DropdownMenuItem(value: c, child: Text(c))],
                    onChanged: (v) => setState(() => _currency = v ?? _currency),
                  ),
                ),
              ],
            ),
            gap,
            ReminderDaysField(
              days: _reminderDays,
              onChanged: (d) => setState(() => _reminderDays = d),
            ),
            gap,
            TextFormField(
              controller: _reference,
              textDirection: TextDirection.ltr,
              decoration: InputDecoration(labelText: l.fieldReference, prefixIcon: const Icon(Icons.tag)),
            ),
            gap,
            TextFormField(
              controller: _url,
              keyboardType: TextInputType.url,
              textDirection: TextDirection.ltr,
              decoration: InputDecoration(labelText: l.fieldServiceUrl, prefixIcon: const Icon(Icons.link)),
              validator: (v) => (v != null && v.trim().isNotEmpty && !_urlPattern.hasMatch(v.trim())) ? l.errorInvalidUrl : null,
            ),
            gap,
            if (_existing != null) ...[
              DropdownButtonFormField<CommitmentLifecycle>(
                initialValue: _lifecycle,
                decoration: InputDecoration(labelText: l.fieldLifecycle),
                items: [
                  DropdownMenuItem(value: CommitmentLifecycle.active, child: Text(l.cstatusActive)),
                  DropdownMenuItem(value: CommitmentLifecycle.completed, child: Text(l.cstatusCompleted)),
                  DropdownMenuItem(value: CommitmentLifecycle.cancelled, child: Text(l.cstatusCancelled)),
                ],
                onChanged: (v) => setState(() => _lifecycle = v ?? _lifecycle),
              ),
              gap,
            ],
            TextFormField(
              controller: _notes,
              minLines: 3,
              maxLines: 6,
              decoration: InputDecoration(labelText: l.fieldNotes, alignLabelWithHint: true),
            ),
            const SizedBox(height: 24),
            FilledButton(key: const Key('commitment-save'), onPressed: _saving ? null : _save, child: Text(l.save)),
          ],
        ),
      ),
    );
  }
}

/// Deletes after confirmation; returns whether deleted.
Future<bool> confirmDeleteCommitment(BuildContext context, WidgetRef ref, Commitment c) async {
  final l = context.l10n;
  if (!await confirmDialog(context, title: l.confirmDeleteTitle, message: l.confirmDeleteCommitment(c.name))) return false;
  await ref.read(commitmentsRepositoryProvider).delete(c.id);
  return true;
}
