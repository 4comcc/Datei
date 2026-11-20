import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/localization/gen/app_localizations.dart';
import '../../../core/export/csv.dart';
import '../../../core/recurrence_engine/recurrence.dart';
import '../../../core/time_engine/time_engine.dart';
import '../../../shared/l10n_labels.dart';
import '../../commitments/domain/commitment.dart';
import '../../events/domain/event.dart';
import '../../memories/domain/memory.dart';
import '../../people/domain/person.dart';

/// Builds localized CSV exports. Dates are ISO (YYYY-MM-DD) so spreadsheets sort them.
class CsvExports {
  const CsvExports({
    required this.l,
    required this.today,
    required this.categoryLabels,
    required this.eventTypeLabels,
    required this.personNames,
    this.time = const TimeEngine(),
  });

  final AppLocalizations l;
  final LocalDate today;
  final Map<String, String> categoryLabels;
  final Map<String, String> eventTypeLabels;
  final Map<String, String> personNames;
  final TimeEngine time;

  String _names(List<String> ids) => ids.map((id) => personNames[id]).whereType<String>().join(' | ');

  String _repeat(RecurrenceRule? r) {
    if (r == null) return '';
    final n = r.interval;
    return switch (r.frequency) {
      RecurrenceFrequency.daily => n == 1 ? l.repeatDaily : l.everyN(n, l.unitDays(n)),
      RecurrenceFrequency.weekly => n == 1 ? l.repeatWeekly : l.everyN(n, l.unitWeeks(n)),
      RecurrenceFrequency.monthly => n == 1 ? l.repeatMonthly : l.everyN(n, l.unitMonths(n)),
      RecurrenceFrequency.yearly => n == 1 ? l.repeatYearly : l.everyN(n, l.unitYears(n)),
    };
  }

  String people(List<Person> people) {
    final csv = CsvBuilder([
      l.fieldFullName, l.fieldDisplayName, l.fieldBirthDate, l.csvAge, l.fieldCategories, l.fieldGender,
      l.fieldPhone, l.fieldEmail, l.fieldOccupation, l.fieldOrganization, l.fieldAddress, l.fieldNotes,
    ]);
    for (final p in people) {
      final withYear = p.birthDateWithYear;
      csv.add([
        p.fullName,
        p.displayName,
        p.birthDate == null ? '' : (p.birthYearKnown ? p.birthDate!.toIso() : '--${p.birthDate!.toIso().substring(5)}'),
        withYear == null ? '' : time.ageOn(withYear, today)?.years,
        p.categoryIds.map((c) => categoryLabels[c]).whereType<String>().join(' | '),
        p.gender == null ? '' : p.gender.label(l),
        p.phone, p.email, p.occupation, p.organization, p.address, p.notes,
      ]);
    }
    return csv.toString();
  }

  String events(List<DateiEvent> events) {
    final csv = CsvBuilder([
      l.fieldTitle, l.fieldEventType, l.csvStart, l.fieldTime, l.csvEnd, l.fieldEndTime, l.csvRecurrence,
      l.fieldLinkedPeople, l.fieldLocation, l.fieldPriority, l.fieldStatus, l.fieldNotes,
    ]);
    for (final e in events) {
      csv.add([
        e.title, eventTypeLabels[e.typeId], e.date.toIso(), e.time, e.endDate?.toIso(), e.endTime, _repeat(e.recurrence),
        _names(e.personIds), e.location, e.priority.label(l), e.status.label(l), e.notes,
      ]);
    }
    return csv.toString();
  }

  String commitments(List<Commitment> items, CommitmentRules rules) {
    final csv = CsvBuilder([
      l.fieldName, l.fieldCommitmentType, l.fieldProvider, l.fieldExpiryDate, l.fieldRenewalDate, l.fieldStatus,
      l.fieldAmount, l.fieldCurrency, l.csvPeriodMonths, l.fieldReference, l.fieldServiceUrl, l.fieldNotes,
    ]);
    for (final c in items) {
      csv.add([
        c.name, CommitmentType.fromId(c.typeId).label(l), c.providerName, c.expiryDate.toIso(), c.renewalDate?.toIso(),
        rules.statusOf(c, today).label(l), c.amountMinor == null ? '' : CommitmentRules.formatAmountInput(c.amountMinor!),
        c.currency, c.renewalMonths, c.referenceNumber, c.serviceUrl, c.notes,
      ]);
    }
    return csv.toString();
  }

  String memories(List<Memory> items) {
    final csv = CsvBuilder([l.fieldTitle, l.fieldDate, l.fieldLinkedPeople, l.fieldTags, l.fieldCategory, l.fieldMemoryText, l.csvPhotos]);
    for (final m in items) {
      csv.add([m.title, m.date.toIso(), _names(m.personIds), m.tags.join(' | '), m.category, m.body, m.photos.length]);
    }
    return csv.toString();
  }
}

/// Hands a file to the system share sheet (tests use a fake).
abstract interface class FileSharer {
  Future<void> share(File file, {required String mimeType, String? subject});
}

class SystemFileSharer implements FileSharer {
  const SystemFileSharer();
  @override
  Future<void> share(File file, {required String mimeType, String? subject}) =>
      SharePlus.instance.share(ShareParams(files: [XFile(file.path, mimeType: mimeType)], subject: subject));
}

final fileSharerProvider = Provider<FileSharer>((ref) => const SystemFileSharer());

/// Where export files are written before sharing (temporary directory).
final exportDirectoryProvider = Provider<Future<Directory> Function()>((ref) => getTemporaryDirectory);

Future<void> shareCsv(WidgetRef ref, {required String baseName, required String content, required LocalDate today}) async {
  final dir = await ref.read(exportDirectoryProvider)();
  final file = File('${dir.path}/datei-$baseName-${today.toIso()}.csv');
  await file.writeAsString(content, flush: true);
  await ref.read(fileSharerProvider).share(file, mimeType: 'text/csv', subject: file.uri.pathSegments.last);
}
