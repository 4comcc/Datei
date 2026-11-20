// Developer tool — NOT part of the app or the test suite.
// Builds a rich sample `.datei` backup (every kind of data, with photos) for
// trying the app by hand. Dates are relative to the day it is run.
//
// SAMPLE_PHOTOS=<dir with .jpg> SAMPLE_OUT=<dir> flutter test tool/sample_backup
import 'dart:io';

import 'package:datei/app/app_info.dart';
import 'package:datei/core/backup/backup_service.dart';
import 'package:datei/core/database/database_providers.dart';
import 'package:datei/core/recurrence_engine/recurrence.dart';
import 'package:datei/core/time_engine/local_date.dart';
import 'package:datei/features/commitments/domain/commitment.dart';
import 'package:datei/features/commitments/presentation/commitments_providers.dart';
import 'package:datei/features/events/domain/event.dart';
import 'package:datei/features/events/presentation/events_providers.dart';
import 'package:datei/features/memories/domain/memory.dart';
import 'package:datei/features/memories/presentation/memories_providers.dart';
import 'package:datei/features/milestones/domain/milestone.dart';
import 'package:datei/features/people/domain/custom_field.dart';
import 'package:datei/features/people/domain/people_filter.dart';
import 'package:datei/features/people/domain/person.dart';
import 'package:datei/features/people/domain/relationship.dart';
import 'package:datei/features/people/presentation/people_providers.dart';
import 'package:datei/features/projects/domain/project.dart';
import 'package:datei/features/search/domain/search.dart';
import 'package:datei/features/search/presentation/search_providers.dart';
import 'package:datei/features/settings/settings_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test/helpers.dart';

void main() {
  test('build sample backup', () async {
    final photosDir = Platform.environment['SAMPLE_PHOTOS']!;
    final outDir = Platform.environment['SAMPLE_OUT']!;
    final (c, db) = await createTestContainer();
    final t = LocalDate.today();
    final created = DateTime.now();
    String md(LocalDate d) => d.toString().substring(5); // MM-DD
    LocalDate born(int age, int daysFromToday) {
      final next = t.addDays(daysFromToday);
      return LocalDate.parse('${t.year - age + (daysFromToday < 0 ? 0 : 0)}-${md(next)}');
    }

    // ---------- categories, custom fields, event types ----------
    final cats = c.read(categoriesRepositoryProvider);
    final neighbours = await cats.create('الجيران', color: 0xFF6D8B3A);
    final gym = await cats.create('النادي الرياضي', color: 0xFF3A6D8B);
    final fields = c.read(customFieldsRepositoryProvider);
    await fields.saveDefinition(const CustomFieldDefinition(id: 'blood', label: 'فصيلة الدم'));
    await fields.saveDefinition(const CustomFieldDefinition(id: 'emp', label: 'الرقم الوظيفي', type: CustomFieldType.number, sortOrder: 1));
    await fields.saveDefinition(const CustomFieldDefinition(id: 'wedding', label: 'تاريخ الزواج', type: CustomFieldType.date, sortOrder: 2));
    await fields.saveDefinition(const CustomFieldDefinition(id: 'site', label: 'الموقع الشخصي', type: CustomFieldType.url, sortOrder: 3));
    final sport = await c.read(eventTypesRepositoryProvider).create('رياضة', color: 0xFF2E7D6B);

    // ---------- people ----------
    String cat(String k) => 'sys:category:$k';
    final people = [
      Person(id: 'p_mother', fullName: 'فاطمة محمود عبد الله', displayName: 'أمي', birthDate: born(64, 0), gender: Gender.female,
          phone: '+20 100 555 0101', address: 'المعادي، القاهرة', categoryIds: [cat('family')],
          customFields: const {'blood': 'A+'}, notes: 'تحب الورد الأبيض والقهوة التركي.', createdAt: created),
      Person(id: 'p_father', fullName: 'محمود عبد الله حسن', displayName: 'أبي', birthDate: born(68, 45), gender: Gender.male,
          phone: '+20 100 555 0102', occupation: 'مهندس متقاعد', categoryIds: [cat('family')],
          customFields: {'blood': 'O+', 'wedding': '1988-06-12'}, createdAt: created),
      Person(id: 'p_sara', fullName: 'سارة محمود', birthDate: born(29, 1), gender: Gender.female, email: 'sara@example.com',
          occupation: 'طبيبة أسنان', organization: 'عيادة النيل', categoryIds: [cat('family')],
          customFields: const {'blood': 'B+'}, createdAt: created),
      Person(id: 'p_omar', fullName: 'عمر محمود', birthDate: born(24, 6), gender: Gender.male, occupation: 'مبرمج',
          organization: 'شركة تقنية', categoryIds: [cat('family'), gym.id], createdAt: created),
      Person(id: 'p_youssef', fullName: 'يوسف عمر', displayName: 'يويو', birthDate: born(5, 20), gender: Gender.male,
          categoryIds: [cat('family')], createdAt: created),
      Person(id: 'p_leap', fullName: 'منى حسن', birthDate: LocalDate.parse('2000-02-29'), gender: Gender.female,
          occupation: 'محاسبة', organization: 'بنك مصر', categoryIds: [cat('colleagues')],
          customFields: const {'emp': '10452'}, notes: 'مولودة في 29 فبراير — يُحتفل بعيدها في 28 فبراير.', createdAt: created),
      Person(id: 'p_khaled', fullName: 'خالد إبراهيم', birthDate: LocalDate.parse('$unknownBirthYearPlaceholder-${md(t.addDays(12))}'),
          birthYearKnown: false, gender: Gender.male, categoryIds: [cat('friends')], phone: '+966 50 123 4567', createdAt: created),
      Person(id: 'p_ahmed', fullName: 'أحمد سمير', birthDate: born(35, 75), gender: Gender.male, occupation: 'مدير مشروعات',
          organization: 'شركة تقنية', categoryIds: [cat('colleagues')], customFields: const {'emp': '20981'}, createdAt: created),
      Person(id: 'p_john', fullName: 'John Miller', displayName: 'John', birthDate: born(41, 150), gender: Gender.male,
          email: 'john.miller@example.com', organization: 'Miller & Co.', categoryIds: [cat('clients')],
          customFields: const {'site': 'https://example.com/john'}, createdAt: created),
      Person(id: 'p_layla', fullName: 'ليلى عبد الرحمن', birthDate: born(52, 200), gender: Gender.female,
          categoryIds: [cat('relatives')], address: 'الإسكندرية', createdAt: created),
      Person(id: 'p_hassan', fullName: 'الحاج حسن علي', birthDate: born(81, 300), gender: Gender.male,
          categoryIds: [cat('relatives')], notes: 'جدّ الأسرة.', createdAt: created),
      Person(id: 'p_nour', fullName: 'نور الهدى', birthDate: born(17, 3), gender: Gender.female, categoryIds: [neighbours.id], createdAt: created),
      Person(id: 'p_karim', fullName: 'كريم مصطفى', categoryIds: [gym.id], occupation: 'مدرب رياضي', createdAt: created),
      Person(id: 'p_dina', fullName: 'دينا فؤاد', birthDate: born(33, -10), gender: Gender.female, categoryIds: [cat('friends')],
          email: 'dina@example.com', createdAt: created),
      Person(id: 'p_other', fullName: 'مكتب الأستاذ وليد للمحاماة', categoryIds: [cat('other')], phone: '+20 2 2345 6789', createdAt: created),
    ];
    for (final p in people) {
      await c.read(peopleRepositoryProvider).save(p);
    }
    final rel = c.read(relationshipsRepositoryProvider);
    await rel.add(const Relationship(id: 'r1', personId: 'p_mother', type: RelationshipType.mother));
    await rel.add(const Relationship(id: 'r2', personId: 'p_father', type: RelationshipType.father));
    await rel.add(const Relationship(id: 'r3', personId: 'p_sara', type: RelationshipType.sister));
    await rel.add(const Relationship(id: 'r4', personId: 'p_omar', type: RelationshipType.brother));
    await rel.add(const Relationship(id: 'r5', personId: 'p_youssef', relatedPersonId: 'p_omar', type: RelationshipType.son));
    await rel.add(const Relationship(id: 'r6', personId: 'p_mother', relatedPersonId: 'p_father', type: RelationshipType.spouse));
    await rel.add(const Relationship(id: 'r7', personId: 'p_ahmed', relatedPersonId: 'p_leap', type: RelationshipType.colleague));
    await rel.add(const Relationship(id: 'r8', personId: 'p_khaled', type: RelationshipType.friend));
    await rel.add(const Relationship(id: 'r9', personId: 'p_hassan', type: RelationshipType.custom, customLabel: 'جدّي'));
    await c.read(savedPeopleFiltersRepositoryProvider).save(const SavedPeopleFilter(
        id: 'f1', name: 'أعياد ميلاد العائلة خلال شهر', filter: PeopleFilter(categoryIds: {'sys:category:family'}, birthdayWithinDays: 30)));
    await c.read(savedPeopleFiltersRepositoryProvider).save(const SavedPeopleFilter(
        id: 'f2', name: 'الزملاء فوق 30 سنة', filter: PeopleFilter(categoryIds: {'sys:category:colleagues'}, minAge: 30)));

    // ---------- events ----------
    String et(EventType e) => e.id;
    final events = [
      DateiEvent(id: 'e_dentist', title: 'موعد طبيب الأسنان', typeId: et(EventType.appointment), date: t, time: '17:30', endTime: '18:15',
          location: 'عيادة النيل', personIds: const ['p_sara'], priority: EventPriority.high, reminderMinutes: const [60, 15], createdAt: created),
      DateiEvent(id: 'e_wedding', title: 'ذكرى زواج أبي وأمي', typeId: et(EventType.anniversary), date: LocalDate.parse('1988-${md(t.addDays(9))}'),
          recurrence: const RecurrenceRule(frequency: RecurrenceFrequency.yearly), personIds: const ['p_mother', 'p_father'],
          reminderMinutes: const [1440 * 3], notes: 'حجز عشاء في المطعم المفضل.', createdAt: created),
      DateiEvent(id: 'e_english', title: 'درس اللغة الإنجليزية', typeId: et(EventType.personal), date: t.addDays(-30), time: '19:00', endTime: '20:30',
          recurrence: const RecurrenceRule(frequency: RecurrenceFrequency.weekly, weekdays: {1, 4}), location: 'المركز الثقافي',
          reminderMinutes: const [30], createdAt: created),
      DateiEvent(id: 'e_dinner', title: 'عشاء العائلة الشهري', typeId: et(EventType.family), date: t.addDays(-60), time: '20:00',
          recurrence: const RecurrenceRule(frequency: RecurrenceFrequency.monthly, weekdays: {5}, setPos: -1),
          personIds: const ['p_mother', 'p_father', 'p_sara', 'p_omar'], createdAt: created),
      DateiEvent(id: 'e_gym', title: 'تمرين في النادي', typeId: sport.id, date: t.addDays(-14), time: '07:00',
          recurrence: const RecurrenceRule(frequency: RecurrenceFrequency.weekly, weekdays: {6, 2}), personIds: const ['p_karim', 'p_omar'],
          createdAt: created),
      DateiEvent(id: 'e_meds', title: 'دواء الضغط لأبي', typeId: et(EventType.personal), date: t.addDays(-5), time: '09:00',
          recurrence: const RecurrenceRule(frequency: RecurrenceFrequency.daily, count: 30), personIds: const ['p_father'],
          priority: EventPriority.critical, reminderMinutes: const [0], createdAt: created),
      DateiEvent(id: 'e_rent', title: 'دفع الإيجار', typeId: et(EventType.other), date: LocalDate(t.year, t.month, 1).addMonths(-3),
          recurrence: const RecurrenceRule(frequency: RecurrenceFrequency.monthly, monthDay: 31), reminderMinutes: const [1440],
          notes: 'يتكرر في آخر يوم من كل شهر (31 أو أقرب يوم).', createdAt: created),
      DateiEvent(id: 'e_trip', title: 'رحلة الأقصر وأسوان', typeId: et(EventType.travel), date: t.addDays(18), endDate: t.addDays(23),
          location: 'الأقصر', personIds: const ['p_sara', 'p_omar'], reminderMinutes: const [1440 * 2], createdAt: created),
      DateiEvent(id: 'e_conf', title: 'مؤتمر التقنية في دبي', typeId: et(EventType.travel), date: t.addDays(-1), endDate: t.addDays(2),
          location: 'دبي', personIds: const ['p_ahmed'], priority: EventPriority.high, createdAt: created),
      DateiEvent(id: 'e_grad', title: 'حفل تخرج عمر', typeId: et(EventType.graduation), date: LocalDate(t.year - 1, 7, 15), time: '18:00',
          status: EventStatus.done, personIds: const ['p_omar'], location: 'جامعة القاهرة', createdAt: created),
      DateiEvent(id: 'e_cancel', title: 'اجتماع مع العميل (أُلغي)', typeId: et(EventType.appointment), date: t.addDays(4), time: '11:00',
          status: EventStatus.cancelled, personIds: const ['p_john'], createdAt: created),
      DateiEvent(id: 'e_meeting', title: 'Project kickoff', typeId: et(EventType.appointment), date: t.addDays(3), time: '10:00', endTime: '11:30',
          personIds: const ['p_john', 'p_ahmed'], priority: EventPriority.high, reminderMinutes: const [120], createdAt: created),
      DateiEvent(id: 'e_eid', title: 'زيارة الجدّ في العيد', typeId: et(EventType.religious), date: t.addDays(40), personIds: const ['p_hassan'],
          priority: EventPriority.low, createdAt: created),
      DateiEvent(id: 'e_award', title: 'استلام جائزة الموظف المثالي', typeId: et(EventType.achievement), date: t.addDays(-90), status: EventStatus.done,
          createdAt: created),
    ];
    final evRepo = c.read(eventsRepositoryProvider);
    for (final e in events) {
      await evRepo.save(e);
    }
    // Exceptions on the weekly class: one cancelled, one moved.
    final nextMonday = t.addDays((DateTime.monday - t.toDateTime().weekday + 7) % 7 == 0 ? 7 : (DateTime.monday - t.toDateTime().weekday + 7) % 7);
    await evRepo.cancelOccurrence('e_english', nextMonday);
    await evRepo.overrideOccurrence('e_english', nextMonday.addDays(3),
        const OccurrenceOverride(time: '18:00', location: 'أونلاين (Zoom)', notes: 'تم تغيير الموعد هذا الأسبوع'));

    // ---------- commitments ----------
    String ct(CommitmentType k) => k.id;
    final cm = c.read(commitmentsRepositoryProvider);
    final commitments = [
      Commitment(id: 'c_passport', name: 'جواز السفر', typeId: ct(CommitmentType.passport), expiryDate: t.addDays(-6),
          referenceNumber: 'A12345678', reminderDays: const [90, 30, 7], notes: 'منتهي — يجب التجديد.', createdAt: created),
      Commitment(id: 'c_domain', name: 'datei.app', typeId: ct(CommitmentType.domain), providerName: 'Namecheap', expiryDate: t.addDays(5),
          renewalMonths: 12, amountMinor: 1499, currency: 'USD', serviceUrl: 'https://www.namecheap.com', reminderDays: const [30, 7, 1], createdAt: created),
      Commitment(id: 'c_insurance', name: 'تأمين السيارة', typeId: ct(CommitmentType.insurance), providerName: 'مصر للتأمين', expiryDate: t.addDays(21 - 365),
          renewalMonths: 12, amountMinor: 850000, currency: 'EGP', reminderDays: const [30, 14, 3], createdAt: created),
      Commitment(id: 'c_car', name: 'رخصة السيارة', typeId: ct(CommitmentType.vehicleLicense), expiryDate: t.addDays(180),
          renewalDate: t.addDays(165), referenceNumber: 'ق ب ط 1234', reminderDays: const [30, 7], createdAt: created),
      Commitment(id: 'c_hosting', name: 'استضافة الموقع', typeId: ct(CommitmentType.hosting), providerName: 'Hetzner', startDate: t.addDays(-300),
          expiryDate: t.addDays(65 - 365), renewalMonths: 12, amountMinor: 4800, currency: 'EUR', createdAt: created),
      Commitment(id: 'c_internet', name: 'فاتورة الإنترنت', typeId: ct(CommitmentType.bill), providerName: 'WE', expiryDate: t.addDays(10),
          renewalMonths: 1, amountMinor: 45000, currency: 'EGP', reminderDays: const [3, 0], createdAt: created),
      Commitment(id: 'c_netflix', name: 'اشتراك Netflix', typeId: ct(CommitmentType.subscription), expiryDate: t.addDays(-40),
          renewalMonths: 1, amountMinor: 26500, currency: 'EGP', lifecycle: CommitmentLifecycle.cancelled, createdAt: created),
      Commitment(id: 'c_car_loan', name: 'قسط السيارة الأخير', typeId: ct(CommitmentType.installment), expiryDate: t.addDays(-20),
          amountMinor: 1200000, currency: 'EGP', lifecycle: CommitmentLifecycle.completed, createdAt: created),
      Commitment(id: 'c_iqama', name: 'الهوية الوطنية', typeId: ct(CommitmentType.nationalId), expiryDate: t.addDays(900),
          referenceNumber: '2950101XXXXXXX', reminderDays: const [60], createdAt: created),
      Commitment(id: 'c_warranty', name: 'ضمان الثلاجة', typeId: ct(CommitmentType.warranty), providerName: 'توشيبا العربي',
          startDate: t.addDays(-700), expiryDate: t.addDays(30), createdAt: created),
      Commitment(id: 'c_rent', name: 'عقد إيجار الشقة', typeId: ct(CommitmentType.contract), startDate: LocalDate(t.year - 1, 1, 1),
          expiryDate: LocalDate(t.year, 12, 31), renewalMonths: 12, amountMinor: 900000, currency: 'SAR', reminderDays: const [60, 30], createdAt: created),
    ];
    for (final x in commitments) {
      await cm.save(x);
    }
    await cm.renew('c_insurance', newExpiry: t.addDays(21), amountMinor: 780000, currency: 'EGP', notes: 'تجديد العام الماضي');
    await cm.renew('c_hosting', newExpiry: t.addDays(65), amountMinor: 4800, currency: 'EUR');

    // ---------- memories with photos ----------
    final store = c.read(attachmentStoreProvider);
    Future<List<MemoryPhoto>> photos(List<String> names) async => [
          for (final n in names)
            await () async {
              final f = await store.importFile('$photosDir/$n.jpg');
              return MemoryPhoto(id: 'ph_${n}_${f.relativePath.hashCode}', relativePath: f.relativePath, mimeType: f.mimeType, sizeBytes: f.sizeBytes);
            }(),
        ];
    final mem = c.read(memoriesRepositoryProvider);
    await mem.save(Memory(id: 'm_luxor', title: 'رحلة الأقصر مع العائلة', date: LocalDate(t.year - 3, 2, 14),
        body: 'زرنا معبد الكرنك ووادي الملوك، وركبنا المنطاد عند الشروق. كان يومًا لا يُنسى.',
        personIds: const ['p_mother', 'p_father', 'p_sara'], tags: const ['سفر', 'عائلة'], category: 'رحلات',
        photos: await photos(['luxor', 'desert', 'sunset']), createdAt: created));
    await mem.save(Memory(id: 'm_sea', title: 'صيف الساحل الشمالي', date: LocalDate(t.year - 1, 8, 3),
        body: 'أسبوع على البحر مع الأصدقاء.', personIds: const ['p_khaled', 'p_dina'], tags: const ['سفر', 'أصدقاء', 'صيف'],
        category: 'رحلات', photos: await photos(['sea']), createdAt: created));
    await mem.save(Memory(id: 'm_grad', title: 'تخرج عمر', date: LocalDate(t.year - 1, 7, 15), eventId: 'e_grad',
        body: 'فخورون جدًا بعمر!', personIds: const ['p_omar', 'p_mother', 'p_father'], tags: const ['عائلة', 'إنجاز'],
        photos: await photos(['city']), createdAt: created));
    await mem.save(Memory(id: 'm_snow', title: 'First snow in Istanbul', date: LocalDate(t.year - 2, 1, 20),
        body: 'A memory written in English to test mixed languages.', tags: const ['travel'], photos: await photos(['snow', 'night']),
        createdAt: created));
    await mem.save(Memory(id: 'm_garden', title: 'حديقة جدّي', date: t.addDays(-25), personIds: const ['p_hassan', 'p_youssef'],
        tags: const ['عائلة'], photos: await photos(['garden']), createdAt: created));
    await mem.save(Memory(id: 'm_text', title: 'أول يوم في العمل الجديد', date: LocalDate(t.year - 2, 9, 1),
        body: 'ذكرى نصية بدون صور.', personIds: const ['p_ahmed'], tags: const ['عمل'], category: 'عمل', createdAt: created));

    // ---------- projects & milestones ----------
    final pr = c.read(projectsRepositoryProvider);
    await pr.save(Project(id: 'pr_book', name: 'تأليف كتاب عن تاريخ العائلة', description: 'جمع الصور والقصص من الأجداد.',
        startDate: t.addDays(-200), dueDate: t.addDays(120), status: ProjectStatus.active, priority: EventPriority.high,
        personIds: const ['p_hassan', 'p_layla'], eventIds: const ['e_eid'], createdAt: created));
    await pr.save(Project(id: 'pr_app', name: 'إطلاق تطبيق العميل', startDate: t.addDays(-60), dueDate: t.addDays(-3),
        status: ProjectStatus.active, priority: EventPriority.critical, personIds: const ['p_john', 'p_ahmed'],
        eventIds: const ['e_meeting'], notes: 'متأخر عن الموعد — يظهر عليه «فات الموعد».', createdAt: created));
    await pr.save(Project(id: 'pr_marathon', name: 'الاستعداد لماراثون 10 كم', startDate: t.addDays(-30), dueDate: t.addDays(90),
        status: ProjectStatus.planned, personIds: const ['p_karim'], eventIds: const ['e_gym'], createdAt: created));
    await pr.save(Project(id: 'pr_kitchen', name: 'تجديد المطبخ', status: ProjectStatus.onHold, priority: EventPriority.low, createdAt: created));
    await pr.save(Project(id: 'pr_arabic', name: 'تعلّم الخط العربي', startDate: LocalDate(t.year - 1, 1, 1), dueDate: LocalDate(t.year - 1, 12, 1),
        status: ProjectStatus.done, createdAt: created));
    await pr.save(Project(id: 'pr_shop', name: 'فتح متجر إلكتروني', status: ProjectStatus.cancelled, createdAt: created));

    final ms = c.read(milestonesRepositoryProvider);
    final milestones = [
      Milestone(id: 'ms1', title: 'أول يوم مدرسة ليوسف', date: LocalDate(t.year, 9, 21), kind: MilestoneKind.firstSchoolDay, personId: 'p_youssef', createdAt: created),
      Milestone(id: 'ms2', title: 'تخرج سارة من كلية طب الأسنان', date: LocalDate(t.year - 6, 7, 1), kind: MilestoneKind.graduation, personId: 'p_sara', createdAt: created),
      Milestone(id: 'ms3', title: 'أول وظيفة لعمر', date: LocalDate(t.year - 1, 10, 1), kind: MilestoneKind.firstJob, personId: 'p_omar', createdAt: created),
      Milestone(id: 'ms4', title: 'زواج أبي وأمي', date: LocalDate.parse('1988-${md(t.addDays(9))}'), kind: MilestoneKind.marriage, personId: 'p_father', eventId: 'e_wedding', createdAt: created),
      Milestone(id: 'ms5', title: 'الانتقال إلى الشقة الجديدة', date: LocalDate(t.year - 1, 1, 1), kind: MilestoneKind.newHome, createdAt: created),
      Milestone(id: 'ms6', title: 'جائزة الموظف المثالي', date: t.addDays(-90), kind: MilestoneKind.achievement, eventId: 'e_award', createdAt: created),
      Milestone(id: 'ms7', title: 'بداية كتابة الكتاب', date: t.addDays(-200), kind: MilestoneKind.projectStart, projectId: 'pr_book', createdAt: created),
      Milestone(id: 'ms8', title: 'إنهاء دورة الخط العربي', date: LocalDate(t.year - 1, 12, 1), kind: MilestoneKind.goalReached, projectId: 'pr_arabic', createdAt: created),
      Milestone(id: 'ms9', title: 'أول 5 كم بدون توقف', date: t.addDays(-7), kind: MilestoneKind.custom, description: 'خطوة نحو الماراثون',
          personId: 'p_karim', projectId: 'pr_marathon', createdAt: created),
    ];
    for (final m in milestones) {
      await ms.save(m);
    }

    // ---------- saved searches & settings ----------
    await c.read(savedSearchesRepositoryProvider).save(const SavedSearch(id: 's1', name: 'القادم والمتكرر',
        query: SearchQuery(conditions: [TimeStateCondition(TimeState.upcoming), RecurringCondition()])));
    await c.read(savedSearchesRepositoryProvider).save(const SavedSearch(id: 's2', name: 'ذكريات السفر',
        query: SearchQuery(types: {SearchEntityType.memory}, conditions: [TagCondition('سفر')])));
    final settings = c.read(settingsRepositoryProvider);
    await settings.set(SettingKeys.language, 'ar');
    await settings.set(SettingKeys.onboardingDone, 'true');
    await settings.set(SettingKeys.showHijri, 'true');
    await settings.set(SettingKeys.birthdayReminderDays, '1');
    await settings.set(SettingKeys.reminderTime, '09:00');

    // ---------- write ----------
    final service = BackupService(db, store, appVersion: appVersion);
    final stamp = t.toString();
    await File('$outDir/Datei-sample-$stamp.datei').writeAsBytes(await service.create());
    await File('$outDir/Datei-sample-$stamp-password-datei2026.datei').writeAsBytes(await service.create(password: 'datei2026'));
    final check = await service.load(await File('$outDir/Datei-sample-$stamp.datei').readAsBytes());
    // ignore: avoid_print
    print('counts: ${check.summary.counts}  files: ${check.summary.fileCount}');
    c.dispose();
    await db.close();
  }, timeout: const Timeout(Duration(minutes: 2)));
}
