import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/time_engine/local_date.dart';
import '../../../shared/l10n_labels.dart';
import '../../../shared/navigation.dart';
import '../../../shared/widgets/common.dart';
import '../../../shared/widgets/date_field.dart';
import '../../agenda/agenda.dart';
import '../../reminders/reminders_banner.dart';
import '../domain/commitment.dart';
import 'commitment_form_screen.dart';
import 'commitments_providers.dart';

class CommitmentDetailScreen extends ConsumerWidget {
  const CommitmentDetailScreen({super.key, required this.commitmentId});
  final String commitmentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final c = ref.watch(commitmentByIdProvider(commitmentId));
    if (c == null) return Scaffold(appBar: AppBar(), body: Center(child: Text(l.noResults)));
    final rules = ref.watch(commitmentRulesProvider);
    final today = ref.watch(todayProvider);
    final status = rules.statusOf(c, today);
    final (bg, fg) = status.colors(theme.colorScheme);
    final days = today.daysUntil(c.dueDate);
    final type = CommitmentType.fromId(c.typeId);
    final renewals = ref.watch(commitmentRenewalsProvider(c.id)).value ?? const <CommitmentRenewal>[];
    final timeBased = c.lifecycle == CommitmentLifecycle.active;

    String period(int? m) {
      if (m == null) return l.periodNone;
      if (m == 12) return l.repeatYearly;
      if (m == 1) return l.repeatMonthly;
      return m % 12 == 0 ? l.everyN(m ~/ 12, l.unitYears(m ~/ 12)) : l.everyN(m, l.unitMonths(m));
    }

    final rows = <(IconData, String, String, bool)>[
      if (c.renewalDate != null) (Icons.event_repeat, l.fieldRenewalDate, context.formatLongDate(c.renewalDate!), false),
      (Icons.event_busy_outlined, l.fieldExpiryDate, context.formatLongDate(c.expiryDate), false),
      if (c.startDate != null) (Icons.event_available_outlined, l.fieldStartDate, context.formatLongDate(c.startDate!), false),
      (Icons.autorenew, l.fieldRenewalPeriod, period(c.renewalMonths), false),
      if (c.amountMinor != null) (Icons.payments_outlined, l.fieldAmount, context.formatMoney(c.amountMinor!, c.currency), false),
      if (c.providerName != null) (Icons.business_outlined, l.fieldProvider, c.providerName!, false),
      if (c.referenceNumber != null) (Icons.tag, l.fieldReference, c.referenceNumber!, true),
      if (c.serviceUrl != null) (Icons.link, l.fieldServiceUrl, c.serviceUrl!, true),
    ];

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: l.edit,
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/commitments/${c.id}/edit'),
          ),
          IconButton(
            tooltip: l.delete,
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              if (await confirmDeleteCommitment(context, ref, c) && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.deletedSuccessfully)));
                context.popOrGo('/commitments');
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 32),
        children: [
          Row(
            children: [
              CircleAvatar(radius: 28, backgroundColor: theme.colorScheme.secondaryContainer, child: Icon(type.icon, size: 28)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.name, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
                    Text(type.label(l), style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            color: bg,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(status.label(l), style: theme.textTheme.titleMedium?.copyWith(color: fg, fontWeight: FontWeight.w700)),
                        if (timeBased)
                          Text(
                            '${context.formatLongDate(c.dueDate)} · ${days < 0 ? l.overdueBy(-days) : l.relativeDays(days)}',
                            style: TextStyle(color: fg),
                          ),
                      ],
                    ),
                  ),
                  if (timeBased)
                    FilledButton.icon(
                      key: const Key('renew'),
                      style: FilledButton.styleFrom(minimumSize: const Size(64, 44)),
                      onPressed: () => showRenewDialog(context, ref, c),
                      icon: const Icon(Icons.autorenew),
                      label: Text(l.renew),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          const RemindersOffBanner(),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  for (final (i, (icon, label, value, ltr)) in rows.indexed) ...[
                    if (i > 0) const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(icon, size: 20, color: theme.colorScheme.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(label, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
                              SelectableText(ltr ? '\u2066$value\u2069' : '\u2068$value\u2069', style: const TextStyle(fontSize: 15)),
                            ],
                          ),
                        ),
                        if (ltr)
                          IconButton(
                            tooltip: MaterialLocalizations.of(context).copyButtonLabel,
                            icon: const Icon(Icons.copy, size: 18),
                            onPressed: () async {
                              await Clipboard.setData(ClipboardData(text: value));
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.copied)));
                              }
                            },
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          SectionHeader(l.remindersLabel),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(c.reminderDays.isEmpty
                  ? l.reminderOff
                  : c.reminderDays.map(l.reminderDaysBefore).join(localeSeparator(context))),
            ),
          ),
          SectionHeader(l.renewalHistory),
          if (renewals.isEmpty)
            InlineEmpty(l.noRenewals)
          else
            Card(
              child: Column(
                children: [
                  for (final r in renewals)
                    ListTile(
                      leading: const Icon(Icons.history),
                      title: Text(l.renewalFromTo(context.formatDate(r.previousExpiry), context.formatDate(r.newExpiry))),
                      subtitle: Text([
                        l.renewedOn(context.formatDate(LocalDate.fromDateTime(r.renewedAt))),
                        if (r.amountMinor != null) context.formatMoney(r.amountMinor!, r.currency),
                        ?r.notes,
                      ].join(' · ')),
                    ),
                ],
              ),
            ),
          if (c.notes != null) ...[
            SectionHeader(l.fieldNotes),
            Card(child: Padding(padding: const EdgeInsets.all(16), child: Text(c.notes!))),
          ],
        ],
      ),
    );
  }
}

String localeSeparator(BuildContext context) => context.localeName.startsWith('ar') ? '، ' : ', ';

Future<void> showRenewDialog(BuildContext context, WidgetRef ref, Commitment c) =>
    showDialog<void>(context: context, builder: (_) => _RenewDialog(commitment: c));

class _RenewDialog extends ConsumerStatefulWidget {
  const _RenewDialog({required this.commitment});
  final Commitment commitment;

  @override
  ConsumerState<_RenewDialog> createState() => _RenewDialogState();
}

class _RenewDialogState extends ConsumerState<_RenewDialog> {
  final _formKey = GlobalKey<FormState>();
  late LocalDate? _newExpiry = ref.read(commitmentRulesProvider).suggestedRenewal(widget.commitment);
  late final TextEditingController _amount = TextEditingController(
    text: widget.commitment.amountMinor == null ? null : CommitmentRules.formatAmountInput(widget.commitment.amountMinor!),
  );
  final _notes = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _amount.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    final amount = _amount.text.trim().isEmpty ? null : CommitmentRules.parseAmount(_amount.text);
    await ref.read(commitmentsRepositoryProvider).renew(
          widget.commitment.id,
          newExpiry: _newExpiry!,
          amountMinor: amount,
          currency: widget.commitment.currency,
          notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.renewedSuccessfully)));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AlertDialog(
      title: Text(l.renewTitle),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LocalDateFormField(
                label: l.newExpiryDate,
                initialValue: _newExpiry,
                clearable: false,
                firstDate: widget.commitment.expiryDate.addDays(1),
                onChanged: (v) => setState(() => _newExpiry = v),
                validator: (v) => (v == null || !v.isAfter(widget.commitment.expiryDate)) ? l.errorRenewDate : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amount,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: l.fieldAmount, suffixText: widget.commitment.currency),
                validator: (v) =>
                    (v != null && v.trim().isNotEmpty && CommitmentRules.parseAmount(v) == null) ? l.errorInvalidAmount : null,
              ),
              const SizedBox(height: 12),
              TextFormField(controller: _notes, decoration: InputDecoration(labelText: l.fieldNotes)),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
        FilledButton(
          key: const Key('renew-confirm'),
          style: FilledButton.styleFrom(minimumSize: const Size(64, 40)),
          onPressed: _busy ? null : _submit,
          child: Text(l.renew),
        ),
      ],
    );
  }
}
