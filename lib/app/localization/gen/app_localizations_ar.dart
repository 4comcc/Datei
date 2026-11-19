// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'Datei';

  @override
  String get tagline => 'لكل تاريخٍ حكاية.';

  @override
  String get chooseLanguageTitle => 'اختر لغتك';

  @override
  String get chooseLanguageHint => 'يمكنك تغييرها في أي وقت من الإعدادات.';

  @override
  String get continueAction => 'متابعة';

  @override
  String get welcomeTitle => 'مرحبًا بك في Datei';

  @override
  String get welcomeBody =>
      'احتفظ بالأشخاص والأحداث والتواريخ المهمة في مكان واحد منظم وهادئ.';

  @override
  String get signInGoogle => 'المتابعة باستخدام Google';

  @override
  String get signInFacebook => 'المتابعة باستخدام Facebook';

  @override
  String get continueAsGuest => 'المتابعة كضيف';

  @override
  String get signInComingSoon =>
      'سيتوفر تسجيل الدخول عبر Google وFacebook في النسخة الكاملة. كضيف، تعمل جميع الوظائف وتبقى بياناتك على هذا الجهاز.';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navPeople => 'الأشخاص';

  @override
  String get navEvents => 'الأحداث';

  @override
  String get navCalendar => 'التقويم';

  @override
  String get navMore => 'المزيد';

  @override
  String todaySummaryEvents(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count حدث اليوم',
      many: '$count حدثًا اليوم',
      few: '$count أحداث اليوم',
      two: 'حدثان اليوم',
      one: 'حدث واحد اليوم',
      zero: 'لا أحداث اليوم',
    );
    return '$_temp0';
  }

  @override
  String todaySummaryUpcoming(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count موعد خلال 30 يومًا',
      many: '$count موعدًا خلال 30 يومًا',
      few: '$count مواعيد خلال 30 يومًا',
      two: 'موعدان خلال 30 يومًا',
      one: 'موعد واحد خلال 30 يومًا',
      zero: 'لا شيء خلال 30 يومًا',
    );
    return '$_temp0';
  }

  @override
  String get sectionToday => 'اليوم';

  @override
  String get sectionBirthdays => 'أعياد الميلاد القادمة';

  @override
  String get sectionUpcomingEvents => 'الأحداث القادمة';

  @override
  String get sectionQuickActions => 'إجراءات سريعة';

  @override
  String get emptyToday => 'لا يوجد شيء مجدول لليوم.';

  @override
  String get emptyBirthdays => 'لا توجد أعياد ميلاد خلال 30 يومًا.';

  @override
  String get emptyUpcomingEvents => 'لا توجد أحداث خلال 30 يومًا.';

  @override
  String get addPerson => 'إضافة شخص';

  @override
  String get addEvent => 'إضافة حدث';

  @override
  String get editPerson => 'تعديل الشخص';

  @override
  String get editEvent => 'تعديل الحدث';

  @override
  String get quickAddTitle => 'ماذا تريد أن تضيف؟';

  @override
  String get comingInFullVersion => 'قريبًا في النسخة الكاملة';

  @override
  String get addCommitment => 'إضافة التزام';

  @override
  String get addMemory => 'إضافة ذكرى';

  @override
  String get peopleEmptyTitle => 'لا يوجد أشخاص بعد';

  @override
  String get peopleEmptyBody =>
      'أضف الأشخاص المهمين لك وسيتابع Datei أعمارهم وأعياد ميلادهم.';

  @override
  String get eventsEmptyTitle => 'لا توجد أحداث بعد';

  @override
  String get eventsEmptyBody => 'سجّل المواعيد والمناسبات والرحلات والإنجازات.';

  @override
  String get searchPeopleHint => 'ابحث بالاسم أو المهنة…';

  @override
  String get filterAll => 'الكل';

  @override
  String get noResults => 'لا توجد نتائج مطابقة.';

  @override
  String get fieldFullName => 'الاسم الكامل';

  @override
  String get fieldDisplayName => 'اسم العرض (اختياري)';

  @override
  String get fieldBirthDate => 'تاريخ الميلاد';

  @override
  String get fieldPhone => 'الهاتف';

  @override
  String get fieldEmail => 'البريد الإلكتروني';

  @override
  String get fieldOccupation => 'المهنة';

  @override
  String get fieldNotes => 'ملاحظات';

  @override
  String get fieldCategories => 'التصنيفات';

  @override
  String get fieldTitle => 'العنوان';

  @override
  String get fieldEventType => 'نوع الحدث';

  @override
  String get fieldDate => 'التاريخ';

  @override
  String get fieldTime => 'الوقت (اختياري)';

  @override
  String get fieldLocation => 'المكان';

  @override
  String get fieldLinkedPeople => 'الأشخاص المرتبطون';

  @override
  String get fieldRepeatsYearly => 'يتكرر كل عام';

  @override
  String get notSet => 'غير محدد';

  @override
  String get pickDate => 'اختر تاريخًا';

  @override
  String get pickTime => 'اختر وقتًا';

  @override
  String get clear => 'مسح';

  @override
  String get save => 'حفظ';

  @override
  String get cancel => 'إلغاء';

  @override
  String get delete => 'حذف';

  @override
  String get edit => 'تعديل';

  @override
  String get confirmDeleteTitle => 'تأكيد الحذف';

  @override
  String confirmDeletePerson(String name) {
    return 'هل تريد حذف $name؟ ستُزال ارتباطاته بالأحداث، ولا يمكن التراجع عن ذلك.';
  }

  @override
  String confirmDeleteEvent(String title) {
    return 'هل تريد حذف «$title»؟ لا يمكن التراجع عن ذلك.';
  }

  @override
  String get errorRequired => 'هذا الحقل مطلوب';

  @override
  String get errorInvalidEmail => 'أدخل بريدًا إلكترونيًا صحيحًا';

  @override
  String get errorFutureBirthDate =>
      'لا يمكن أن يكون تاريخ الميلاد في المستقبل';

  @override
  String get errorDateRequired => 'يرجى اختيار تاريخ';

  @override
  String get savedSuccessfully => 'تم الحفظ';

  @override
  String get deletedSuccessfully => 'تم الحذف';

  @override
  String ageYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count سنة',
      many: '$count سنة',
      few: '$count سنوات',
      two: 'سنتان',
      one: 'سنة واحدة',
      zero: 'أقل من سنة',
    );
    return '$_temp0';
  }

  @override
  String ageBreakdown(int years, int months, int days) {
    return '$years سنة · $months شهر · $days يوم';
  }

  @override
  String totalDaysLived(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'عاش $countString يومًا';
  }

  @override
  String turnsAge(int age) {
    return 'سيبلغ $age';
  }

  @override
  String relativeDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'بعد $count يوم',
      many: 'بعد $count يومًا',
      few: 'بعد $count أيام',
      two: 'بعد يومين',
      one: 'غدًا',
      zero: 'اليوم',
    );
    return '$_temp0';
  }

  @override
  String birthdayOf(String name) {
    return 'عيد ميلاد $name';
  }

  @override
  String get labelAge => 'العمر';

  @override
  String get labelNextBirthday => 'عيد الميلاد القادم';

  @override
  String get labelContact => 'التواصل';

  @override
  String get labelLinkedEvents => 'الأحداث المرتبطة';

  @override
  String get noBirthDate => 'لا يوجد تاريخ ميلاد';

  @override
  String get noLinkedEvents => 'لا توجد أحداث مرتبطة بعد.';

  @override
  String get tabUpcoming => 'القادمة';

  @override
  String get tabPast => 'السابقة';

  @override
  String get yearly => 'سنوي';

  @override
  String get calendarNoItems => 'لا يوجد شيء في هذا اليوم.';

  @override
  String get calendarToday => 'اليوم';

  @override
  String get previousMonth => 'الشهر السابق';

  @override
  String get nextMonth => 'الشهر التالي';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get settingsTheme => 'المظهر';

  @override
  String get themeSystem => 'حسب النظام';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get settingsAccount => 'الحساب';

  @override
  String get guestAccountStatus => 'ضيف — البيانات محفوظة على هذا الجهاز فقط';

  @override
  String get moreModulesTitle => 'وحدات قادمة';

  @override
  String get moduleCommitments => 'الالتزامات والتجديدات';

  @override
  String get moduleMemories => 'الذكريات ومحطات الحياة';

  @override
  String get moduleTimeline => 'الخط الزمني';

  @override
  String get moduleReports => 'التقارير';

  @override
  String get moduleBackup => 'النسخ الاحتياطي والاستعادة';

  @override
  String get settingsData => 'البيانات';

  @override
  String get resetData => 'مسح جميع البيانات';

  @override
  String get resetDataConfirm =>
      'سيؤدي هذا إلى حذف جميع الأشخاص والأحداث على هذا الجهاز نهائيًا. هل تريد المتابعة؟';

  @override
  String get aboutTitle => 'حول التطبيق';

  @override
  String prototypeNotice(String version) {
    return 'نموذج أولي مبكر (الإصدار $version) لتجربة التطبيق. البيانات محفوظة محليًا على هذا الجهاز.';
  }

  @override
  String get categoryFamily => 'العائلة';

  @override
  String get categoryRelatives => 'الأقارب';

  @override
  String get categoryFriends => 'الأصدقاء';

  @override
  String get categoryColleagues => 'الزملاء';

  @override
  String get categoryClients => 'العملاء';

  @override
  String get categoryOther => 'أخرى';

  @override
  String get eventTypeAnniversary => 'ذكرى سنوية';

  @override
  String get eventTypeAppointment => 'موعد';

  @override
  String get eventTypeTravel => 'سفر';

  @override
  String get eventTypeGraduation => 'تخرج';

  @override
  String get eventTypeAchievement => 'إنجاز';

  @override
  String get eventTypeFamily => 'مناسبة عائلية';

  @override
  String get eventTypeReligious => 'مناسبة دينية';

  @override
  String get eventTypePersonal => 'شخصي';

  @override
  String get eventTypeOther => 'أخرى';

  @override
  String get startupErrorTitle => 'تعذّر تشغيل Datei';

  @override
  String get startupErrorBody =>
      'حدث خطأ أثناء فتح بياناتك على هذا الجهاز، ولم تُحذف أي بيانات. أعد المحاولة، وإذا تكرر الخطأ أرسل التفاصيل أدناه إلى المطوّر.';

  @override
  String get startupTimeout =>
      'استغرق فتح قاعدة البيانات وقتًا أطول من اللازم.';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get copyDetails => 'نسخ التفاصيل';

  @override
  String get copied => 'تم النسخ';

  @override
  String get fieldGender => 'الجنس (اختياري)';

  @override
  String get genderUnspecified => 'غير محدد';

  @override
  String get genderMale => 'ذكر';

  @override
  String get genderFemale => 'أنثى';

  @override
  String get fieldAddress => 'العنوان';

  @override
  String get fieldOrganization => 'جهة العمل';

  @override
  String get birthYearUnknown => 'لا أعرف سنة الميلاد';

  @override
  String get birthYearUnknownHint =>
      'سيُستخدم اليوم والشهر فقط، ولن يظهر العمر.';

  @override
  String get manageCategories => 'التصنيفات';

  @override
  String get addCategory => 'تصنيف جديد';

  @override
  String get categoryName => 'اسم التصنيف';

  @override
  String get editCategory => 'تعديل التصنيف';

  @override
  String deleteCategoryConfirm(String name) {
    return 'هل تريد حذف التصنيف «$name»؟ لن يُحذف الأشخاص، بل التصنيف فقط.';
  }

  @override
  String get systemCategoriesNote =>
      'لا يمكن تعديل التصنيفات الأساسية أو حذفها.';

  @override
  String get yourCategories => 'تصنيفاتك';

  @override
  String get builtInCategories => 'الأساسية';

  @override
  String get noCustomCategories => 'لم تنشئ أي تصنيف بعد.';

  @override
  String get sectionRelationships => 'العلاقات';

  @override
  String get addRelationship => 'إضافة علاقة';

  @override
  String relationshipIs(String name) {
    return '$name هو/هي…';
  }

  @override
  String get relationshipOf => '…لـ';

  @override
  String get relatedToMe => 'أنا';

  @override
  String get customRelationshipLabel => 'اسم العلاقة';

  @override
  String get noRelationships => 'لا توجد علاقات بعد.';

  @override
  String relationOfPerson(String relation, String name) {
    return '$relation $name';
  }

  @override
  String relationOfMe(String relation) {
    return '$relation (بالنسبة لك)';
  }

  @override
  String get relationFather => 'أب';

  @override
  String get relationMother => 'أم';

  @override
  String get relationSon => 'ابن';

  @override
  String get relationDaughter => 'ابنة';

  @override
  String get relationBrother => 'أخ';

  @override
  String get relationSister => 'أخت';

  @override
  String get relationSpouse => 'زوج/زوجة';

  @override
  String get relationRelative => 'قريب';

  @override
  String get relationFriend => 'صديق';

  @override
  String get relationColleague => 'زميل';

  @override
  String get relationCustom => 'أخرى…';

  @override
  String get removeRelationship => 'إزالة العلاقة';

  @override
  String get errorChoosePerson => 'اختر شخصًا';

  @override
  String get customFieldsTitle => 'الحقول المخصصة';

  @override
  String get customFieldsHint =>
      'أضف حقولًا خاصة بك لكل شخص، مثل فصيلة الدم أو رقم الهوية.';

  @override
  String get addCustomField => 'حقل جديد';

  @override
  String get editCustomField => 'تعديل الحقل';

  @override
  String get customFieldLabel => 'اسم الحقل';

  @override
  String get customFieldType => 'نوع الحقل';

  @override
  String get fieldTypeText => 'نص';

  @override
  String get fieldTypeNumber => 'رقم';

  @override
  String get fieldTypeDate => 'تاريخ';

  @override
  String get fieldTypeUrl => 'رابط';

  @override
  String get noCustomFields => 'لا توجد حقول مخصصة بعد.';

  @override
  String deleteCustomFieldConfirm(String label) {
    return 'هل تريد حذف الحقل «$label»؟ ستُحذف قيمه من جميع الأشخاص.';
  }

  @override
  String get ageOnDate => 'العمر في تاريخ معيّن';

  @override
  String get notBornYet => 'لم يكن قد وُلد في هذا التاريخ.';

  @override
  String untilBirthday(int months, int days) {
    return 'باقٍ $months شهر و$days يوم';
  }

  @override
  String get filters => 'التصفية';

  @override
  String filtersActive(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count شرط',
      many: '$count شرطًا',
      few: '$count شروط',
      two: 'شرطان',
      one: 'شرط واحد',
      zero: 'التصفية',
    );
    return '$_temp0';
  }

  @override
  String get clearFilters => 'مسح الكل';

  @override
  String get showResults => 'عرض النتائج';

  @override
  String get ageRange => 'نطاق العمر';

  @override
  String get minAge => 'من';

  @override
  String get maxAge => 'إلى';

  @override
  String get birthMonth => 'شهر الميلاد';

  @override
  String get birthDayOfMonth => 'يوم الميلاد';

  @override
  String get birthYear => 'سنة الميلاد';

  @override
  String get anyValue => 'الكل';

  @override
  String get birthDateFilter => 'تاريخ الميلاد';

  @override
  String get withBirthDate => 'له تاريخ ميلاد';

  @override
  String get withoutBirthDate => 'بلا تاريخ ميلاد';

  @override
  String get birthdayWithin => 'عيد الميلاد خلال';

  @override
  String withinDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count يوم',
      many: '$count يومًا',
      few: '$count أيام',
      two: 'يومين',
      one: 'يوم واحد',
    );
    return '$_temp0';
  }

  @override
  String get relationshipFilter => 'لديه علاقة';

  @override
  String get saveFilter => 'حفظ الفلتر';

  @override
  String get filterName => 'اسم الفلتر';

  @override
  String get filterSaved => 'تم حفظ الفلتر';

  @override
  String deleteSavedFilterConfirm(String name) {
    return 'هل تريد حذف الفلتر المحفوظ «$name»؟';
  }

  @override
  String get errorInvalidNumber => 'أدخل رقمًا صحيحًا';

  @override
  String get errorInvalidUrl =>
      'أدخل رابطًا صحيحًا يبدأ بـ http:// أو https://';

  @override
  String get errorAgeRange => 'يجب ألا تكون قيمة «من» أكبر من «إلى»';

  @override
  String resultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count شخص',
      many: '$count شخصًا',
      few: '$count أشخاص',
      two: 'شخصان',
      one: 'شخص واحد',
      zero: 'لا أحد',
    );
    return '$_temp0';
  }

  @override
  String get add => 'إضافة';

  @override
  String get repeat => 'التكرار';

  @override
  String get repeatNone => 'لا يتكرر';

  @override
  String get repeatDaily => 'يومي';

  @override
  String get repeatWeekly => 'أسبوعي';

  @override
  String get repeatMonthly => 'شهري';

  @override
  String get repeatYearly => 'سنوي';

  @override
  String get everyLabel => 'كل';

  @override
  String unitDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'يوم',
      many: 'يومًا',
      few: 'أيام',
      two: 'يومين',
      one: 'يوم',
    );
    return '$_temp0';
  }

  @override
  String unitWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'أسبوع',
      many: 'أسبوعًا',
      few: 'أسابيع',
      two: 'أسبوعين',
      one: 'أسبوع',
    );
    return '$_temp0';
  }

  @override
  String unitMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'شهر',
      many: 'شهرًا',
      few: 'أشهر',
      two: 'شهرين',
      one: 'شهر',
    );
    return '$_temp0';
  }

  @override
  String unitYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'سنة',
      many: 'سنة',
      few: 'سنوات',
      two: 'سنتين',
      one: 'سنة',
    );
    return '$_temp0';
  }

  @override
  String everyN(int count, String unit) {
    return 'كل $count $unit';
  }

  @override
  String get onWeekdays => 'في أيام';

  @override
  String monthlyOnDay(int day) {
    return 'في اليوم $day';
  }

  @override
  String monthlyOnNth(String position, String weekday) {
    return 'في $weekday $position';
  }

  @override
  String get posFirst => 'الأول';

  @override
  String get posSecond => 'الثاني';

  @override
  String get posThird => 'الثالث';

  @override
  String get posFourth => 'الرابع';

  @override
  String get posLast => 'الأخير';

  @override
  String get skipShortMonths => 'تخطَّ الأشهر التي ليس فيها هذا اليوم';

  @override
  String get ends => 'ينتهي';

  @override
  String get endsNever => 'أبدًا';

  @override
  String get endsOnDate => 'في تاريخ';

  @override
  String get endsAfter => 'بعد';

  @override
  String occurrencesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مرة',
      many: '$count مرة',
      few: '$count مرات',
      two: 'مرتين',
      one: 'مرة واحدة',
    );
    return '$_temp0';
  }

  @override
  String untilDate(String date) {
    return 'حتى $date';
  }

  @override
  String get fieldEndDate => 'تاريخ النهاية (اختياري)';

  @override
  String get fieldEndTime => 'وقت النهاية (اختياري)';

  @override
  String get fieldPriority => 'الأولوية';

  @override
  String get priorityLow => 'منخفضة';

  @override
  String get priorityNormal => 'عادية';

  @override
  String get priorityHigh => 'عالية';

  @override
  String get priorityCritical => 'حرجة';

  @override
  String get fieldStatus => 'الحالة';

  @override
  String get statusPlanned => 'مخطط';

  @override
  String get statusDone => 'تم';

  @override
  String get statusCancelled => 'ملغى';

  @override
  String get errorEndBeforeStart => 'لا يمكن أن تكون النهاية قبل البداية';

  @override
  String get errorInterval => 'أدخل رقمًا من 1 إلى 999';

  @override
  String get errorWeekdays => 'اختر يومًا واحدًا على الأقل';

  @override
  String get hijriInput => 'إدخال تاريخ هجري';

  @override
  String get hijriDay => 'اليوم';

  @override
  String get hijriMonth => 'الشهر';

  @override
  String get hijriYear => 'السنة';

  @override
  String get hijriInvalid =>
      'هذا التاريخ الهجري غير صحيح أو خارج نطاق 1356–1500 هـ';

  @override
  String hijriConverted(String date) {
    return 'بالميلادي: $date';
  }

  @override
  String hijriFormat(int day, String month, int year) {
    return '$day $month $year هـ';
  }

  @override
  String get hijriMonth1 => 'محرم';

  @override
  String get hijriMonth2 => 'صفر';

  @override
  String get hijriMonth3 => 'ربيع الأول';

  @override
  String get hijriMonth4 => 'ربيع الآخر';

  @override
  String get hijriMonth5 => 'جمادى الأولى';

  @override
  String get hijriMonth6 => 'جمادى الآخرة';

  @override
  String get hijriMonth7 => 'رجب';

  @override
  String get hijriMonth8 => 'شعبان';

  @override
  String get hijriMonth9 => 'رمضان';

  @override
  String get hijriMonth10 => 'شوال';

  @override
  String get hijriMonth11 => 'ذو القعدة';

  @override
  String get hijriMonth12 => 'ذو الحجة';

  @override
  String get editScopeTitle => 'تعديل حدث متكرر';

  @override
  String get deleteScopeTitle => 'حذف حدث متكرر';

  @override
  String get scopeThis => 'هذا الموعد فقط';

  @override
  String get scopeFollowing => 'هذا الموعد وما بعده';

  @override
  String get scopeAll => 'كل مواعيد السلسلة';

  @override
  String occurrenceOf(String date) {
    return 'موعد يوم $date';
  }

  @override
  String get manageEventTypes => 'أنواع الأحداث';

  @override
  String get addEventType => 'نوع جديد';

  @override
  String get editEventType => 'تعديل النوع';

  @override
  String get eventTypeName => 'اسم النوع';

  @override
  String deleteEventTypeConfirm(String name) {
    return 'هل تريد حذف النوع «$name»؟ ستنتقل أحداثه إلى «أخرى».';
  }

  @override
  String get yourEventTypes => 'أنواعك';

  @override
  String get noCustomEventTypes => 'لم تنشئ أي نوع أحداث بعد.';

  @override
  String get systemEventTypesNote => 'لا يمكن تعديل الأنواع الأساسية أو حذفها.';

  @override
  String get viewMonth => 'شهر';

  @override
  String get viewWeek => 'أسبوع';

  @override
  String get viewDay => 'يوم';

  @override
  String get goToDate => 'الانتقال إلى تاريخ';

  @override
  String get calendarFilter => 'العرض في التقويم';

  @override
  String get birthdaysLabel => 'أعياد الميلاد';

  @override
  String get searchCalendar => 'البحث في التقويم';

  @override
  String get searchCalendarHint => 'ابحث في الأحداث وأعياد الميلاد…';

  @override
  String get searchCalendarScope => 'تُعرض النتائج من قبل سنة إلى بعد سنة';

  @override
  String get allDay => 'طوال اليوم';

  @override
  String get previousPeriod => 'السابق';

  @override
  String get nextPeriod => 'التالي';

  @override
  String get settingsCalendar => 'التقويم';

  @override
  String get showHijri => 'عرض التاريخ الهجري';

  @override
  String get hijriAdjustment => 'تعديل التاريخ الهجري';

  @override
  String get hijriNote =>
      'يُحسب وفق تقويم أم القرى، وقد تختلف رؤية الهلال المحلية بيوم أو يومين، فعدّل عند الحاجة. لا تتغير التواريخ الميلادية أبدًا.';

  @override
  String get repeatsLabel => 'متكرر';

  @override
  String get hijriAdjustmentNone => 'بدون تعديل';

  @override
  String hijriAdjustmentDays(String value) {
    return '$value يوم';
  }

  @override
  String unitTimes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'مرة',
      many: 'مرة',
      few: 'مرات',
      two: 'مرتين',
      one: 'مرة',
    );
    return '$_temp0';
  }
}
