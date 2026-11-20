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
    return 'إصدار تجريبي (الإصدار $version). البيانات محفوظة محليًا على هذا الجهاز.';
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

  @override
  String get commitmentTypeDomain => 'نطاق (دومين)';

  @override
  String get commitmentTypeHosting => 'استضافة';

  @override
  String get commitmentTypeSsl => 'شهادة SSL';

  @override
  String get commitmentTypeContract => 'عقد';

  @override
  String get commitmentTypeLicense => 'ترخيص';

  @override
  String get commitmentTypeInsurance => 'تأمين';

  @override
  String get commitmentTypeWarranty => 'ضمان';

  @override
  String get commitmentTypeSubscription => 'اشتراك';

  @override
  String get commitmentTypeBill => 'فاتورة';

  @override
  String get commitmentTypePayment => 'دفعة';

  @override
  String get commitmentTypeInstallment => 'قسط';

  @override
  String get commitmentTypePassport => 'جواز سفر';

  @override
  String get commitmentTypeNationalId => 'بطاقة الهوية';

  @override
  String get commitmentTypeVehicleLicense => 'رخصة مركبة';

  @override
  String get commitmentTypeOther => 'أخرى';

  @override
  String get cstatusActive => 'نشط';

  @override
  String get cstatusUpcoming => 'قادم';

  @override
  String get cstatusDueSoon => 'قريب الاستحقاق';

  @override
  String get cstatusOverdue => 'متأخر';

  @override
  String get cstatusCompleted => 'مكتمل';

  @override
  String get cstatusCancelled => 'ملغى';

  @override
  String get commitments => 'الالتزامات والتجديدات';

  @override
  String get commitmentsEmptyTitle => 'لا توجد التزامات بعد';

  @override
  String get commitmentsEmptyBody =>
      'تابع التجديدات مثل النطاقات والاشتراكات والتأمين وجوازات السفر والهويات، وسيذكّرك Datei قبل موعدها.';

  @override
  String get editCommitment => 'تعديل الالتزام';

  @override
  String get fieldName => 'الاسم';

  @override
  String get fieldCommitmentType => 'النوع';

  @override
  String get fieldProvider => 'الجهة أو الشركة';

  @override
  String get fieldStartDate => 'تاريخ البداية (اختياري)';

  @override
  String get fieldExpiryDate => 'تاريخ الانتهاء أو الاستحقاق';

  @override
  String get fieldRenewalDate => 'التجديد قبل (اختياري)';

  @override
  String get fieldAmount => 'المبلغ (اختياري)';

  @override
  String get fieldCurrency => 'العملة';

  @override
  String get fieldRenewalPeriod => 'مدة التجديد';

  @override
  String get periodNone => 'بدون مدة ثابتة';

  @override
  String get fieldReference => 'الرقم المرجعي (اختياري)';

  @override
  String get fieldServiceUrl => 'رابط الخدمة (اختياري)';

  @override
  String get fieldLifecycle => 'الحالة';

  @override
  String get remindersLabel => 'التذكيرات';

  @override
  String reminderDaysBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'قبل $count يوم',
      many: 'قبل $count يومًا',
      few: 'قبل $count أيام',
      two: 'قبل يومين',
      one: 'قبل يوم',
      zero: 'في اليوم نفسه',
    );
    return '$_temp0';
  }

  @override
  String get addCustomReminder => 'مدة أخرى…';

  @override
  String get customReminderDays => 'عدد الأيام قبل الموعد';

  @override
  String get renew => 'تجديد';

  @override
  String get renewTitle => 'تجديد الالتزام';

  @override
  String get newExpiryDate => 'تاريخ الانتهاء الجديد';

  @override
  String get renewalHistory => 'سجل التجديدات';

  @override
  String get noRenewals => 'لا توجد تجديدات مسجلة بعد.';

  @override
  String renewalFromTo(String from, String to) {
    return '$from ← $to';
  }

  @override
  String renewedOn(String date) {
    return 'جُدد في $date';
  }

  @override
  String get renewedSuccessfully => 'تم التجديد';

  @override
  String get errorRenewDate => 'اختر تاريخًا بعد تاريخ الانتهاء الحالي';

  @override
  String get errorExpiryBeforeStart => 'لا يمكن أن يكون الانتهاء قبل البداية';

  @override
  String get errorInvalidAmount => 'أدخل مبلغًا مثل 250 أو 99.50';

  @override
  String confirmDeleteCommitment(String name) {
    return 'هل تريد حذف «$name» وسجل تجديداته؟';
  }

  @override
  String overdueBy(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'متأخر $count يوم',
      many: 'متأخر $count يومًا',
      few: 'متأخر $count أيام',
      two: 'متأخر يومين',
      one: 'متأخر يومًا واحدًا',
    );
    return '$_temp0';
  }

  @override
  String get filterAllCommitments => 'الكل';

  @override
  String get sectionReminders => 'تذكيرات مهمة';

  @override
  String get emptyReminders => 'لا شيء مستحق خلال 30 يومًا.';

  @override
  String todaySummaryOverdue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count التزام متأخر',
      many: '$count التزامًا متأخرًا',
      few: '$count التزامات متأخرة',
      two: 'التزامان متأخران',
      one: 'التزام متأخر',
    );
    return '$_temp0';
  }

  @override
  String get settingsNotifications => 'الإشعارات';

  @override
  String get enableReminders => 'التذكيرات';

  @override
  String get enableRemindersHint =>
      'تلقَّ إشعارات قبل أعياد الميلاد والأحداث والتجديدات.';

  @override
  String get remindersPermissionDenied =>
      'الإشعارات محظورة لتطبيق Datei. اسمح بها من إعدادات أندرويد لتصلك التذكيرات.';

  @override
  String get defaultReminderTime => 'وقت التذكير للمواعيد بلا وقت';

  @override
  String get birthdayReminders => 'تذكير أعياد الميلاد';

  @override
  String get reminderOff => 'إيقاف';

  @override
  String get preciseReminders => 'توقيت دقيق';

  @override
  String get preciseRemindersHint =>
      'تصل التذكيرات في الدقيقة المحددة تمامًا. بدونها قد يؤخرها أندرويد قليلًا لتوفير البطارية.';

  @override
  String get testNotification => 'إرسال إشعار تجريبي';

  @override
  String get testNotificationBody => 'الإشعارات تعمل.';

  @override
  String get remindersOffBanner =>
      'التذكيرات متوقفة، فلن تصلك إشعارات قبل المواعيد.';

  @override
  String get turnOn => 'تشغيل';

  @override
  String notifBirthdayTitle(String name) {
    return 'عيد ميلاد $name';
  }

  @override
  String notifBirthdayTurning(String name, int age) {
    return '$name يبلغ $age';
  }

  @override
  String notifCommitmentTitle(String name) {
    return 'موعد استحقاق $name';
  }

  @override
  String notifWhen(String relative, String date) {
    return '$relative · $date';
  }

  @override
  String get fieldReminders => 'التذكيرات';

  @override
  String get reminderAtTime => 'في الموعد';

  @override
  String reminderMinutesBefore(int count) {
    return 'قبل $count دقيقة';
  }

  @override
  String reminderHoursBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'قبل $count ساعة',
      many: 'قبل $count ساعة',
      few: 'قبل $count ساعات',
      two: 'قبل ساعتين',
      one: 'قبل ساعة',
    );
    return '$_temp0';
  }

  @override
  String get commitmentsLabel => 'الالتزامات والتجديدات';

  @override
  String get addReminder => 'إضافة';

  @override
  String get memories => 'الذكريات';

  @override
  String get memoriesEmptyTitle => 'لا توجد ذكريات بعد';

  @override
  String get memoriesEmptyBody =>
      'احفظ اللحظات بتاريخها وأشخاصها وصورها، حتى لو كانت قبل سنوات.';

  @override
  String get editMemory => 'تعديل الذكرى';

  @override
  String get fieldMemoryText => 'ماذا حدث؟';

  @override
  String get fieldTags => 'الوسوم';

  @override
  String get addTagHint => 'أضف وسمًا ثم اضغط إدخال';

  @override
  String get fieldCategory => 'التصنيف (اختياري)';

  @override
  String get fieldLinkedEvent => 'الحدث المرتبط (اختياري)';

  @override
  String get noneOption => 'لا شيء';

  @override
  String get photos => 'الصور';

  @override
  String get addPhotos => 'إضافة صور';

  @override
  String get removePhoto => 'إزالة الصورة';

  @override
  String photoCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count صورة',
      many: '$count صورة',
      few: '$count صور',
      two: 'صورتان',
      one: 'صورة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get photosPickFailed => 'تعذّرت إضافة الصور. أعد المحاولة.';

  @override
  String confirmDeleteMemory(String title) {
    return 'هل تريد حذف «$title» وصورها؟';
  }

  @override
  String get milestones => 'محطات الحياة';

  @override
  String get milestonesEmptyTitle => 'لا توجد محطات بعد';

  @override
  String get milestonesEmptyBody =>
      'سجّل المحطات المهمة: التخرج، وأول وظيفة، والزواج، والانتقال إلى منزل جديد، والإنجازات.';

  @override
  String get addMilestone => 'إضافة محطة';

  @override
  String get editMilestone => 'تعديل المحطة';

  @override
  String get fieldMilestoneKind => 'النوع';

  @override
  String get fieldPerson => 'الشخص (اختياري)';

  @override
  String get fieldProject => 'المشروع (اختياري)';

  @override
  String get fieldDescription => 'الوصف (اختياري)';

  @override
  String confirmDeleteMilestone(String title) {
    return 'هل تريد حذف المحطة «$title»؟';
  }

  @override
  String get milestoneFirstSchoolDay => 'أول يوم دراسة';

  @override
  String get milestoneGraduation => 'التخرج';

  @override
  String get milestoneFirstJob => 'أول وظيفة';

  @override
  String get milestoneMarriage => 'الزواج';

  @override
  String get milestoneNewHome => 'منزل جديد';

  @override
  String get milestoneAchievement => 'إنجاز';

  @override
  String get milestoneProjectStart => 'بداية مشروع';

  @override
  String get milestoneGoalReached => 'تحقيق هدف';

  @override
  String get milestoneCustom => 'أخرى';

  @override
  String get projects => 'المشروعات والأهداف';

  @override
  String get projectsEmptyTitle => 'لا توجد مشروعات بعد';

  @override
  String get projectsEmptyBody =>
      'احتفظ بأهدافك ومشروعاتك بتواريخها وأشخاصها وأحداثها.';

  @override
  String get addProject => 'إضافة مشروع';

  @override
  String get editProject => 'تعديل المشروع';

  @override
  String get fieldDueDate => 'الموعد النهائي (اختياري)';

  @override
  String get errorDueBeforeStart =>
      'لا يمكن أن يكون الموعد النهائي قبل البداية';

  @override
  String get fieldParticipants => 'الأشخاص المشاركون';

  @override
  String get fieldRelatedEvents => 'الأحداث المرتبطة';

  @override
  String get projectPlanned => 'مخطط';

  @override
  String get projectActive => 'قيد التنفيذ';

  @override
  String get projectOnHold => 'متوقف مؤقتًا';

  @override
  String get projectDone => 'منجز';

  @override
  String get projectCancelled => 'ملغى';

  @override
  String get projectOverdue => 'تجاوز الموعد';

  @override
  String confirmDeleteProject(String name) {
    return 'هل تريد حذف المشروع «$name»؟';
  }

  @override
  String get timeline => 'الخط الزمني';

  @override
  String timelineOf(String name) {
    return 'الخط الزمني لـ $name';
  }

  @override
  String get timelineEmpty => 'لا يوجد شيء في هذه الفترة بعد.';

  @override
  String get periodAll => 'الكل';

  @override
  String get periodPastYear => 'السنة الماضية';

  @override
  String get periodThisYear => 'هذا العام';

  @override
  String get periodUpcoming => 'القادم';

  @override
  String get groupEvents => 'الأحداث';

  @override
  String get groupBirthdays => 'أعياد الميلاد';

  @override
  String get groupMemories => 'الذكريات';

  @override
  String get groupMilestones => 'المحطات';

  @override
  String get groupProjects => 'المشروعات';

  @override
  String timelineBorn(String name) {
    return 'وُلد $name';
  }

  @override
  String timelineProjectStarted(String name) {
    return 'بداية: $name';
  }

  @override
  String timelineProjectDue(String name) {
    return 'موعد إنجاز: $name';
  }

  @override
  String get todayMarker => 'اليوم';

  @override
  String get viewTimeline => 'عرض الخط الزمني';

  @override
  String get sectionMemories => 'الذكريات';

  @override
  String get search => 'البحث';

  @override
  String get searchHint => 'ابحث في الأشخاص والأحداث والالتزامات والذكريات…';

  @override
  String get searchStart =>
      'اكتب للبحث في كل محتوى Datei، أو أضف شروطًا للتصفية.';

  @override
  String get typePerson => 'الأشخاص';

  @override
  String get typeEvent => 'الأحداث';

  @override
  String get typeCommitment => 'الالتزامات';

  @override
  String get typeMemory => 'الذكريات';

  @override
  String get typeMilestone => 'المحطات';

  @override
  String get typeProject => 'المشروعات';

  @override
  String get advancedFilters => 'الشروط';

  @override
  String get matchAll => 'كل الشروط';

  @override
  String get matchAny => 'أي شرط';

  @override
  String get matchHint => 'الشرط الذي لا ينطبق على عنصر يُعدّ غير متحقق.';

  @override
  String get addCondition => 'إضافة شرط';

  @override
  String get condDateRange => 'الفترة الزمنية';

  @override
  String get condPerson => 'الشخص';

  @override
  String get condEventType => 'نوع الحدث';

  @override
  String get condCategory => 'التصنيف';

  @override
  String get condAge => 'العمر';

  @override
  String get condPriority => 'الأولوية';

  @override
  String get condTimeState => 'الوقت';

  @override
  String get condRecurring => 'المتكرر فقط';

  @override
  String get condTag => 'الوسم';

  @override
  String get timeUpcoming => 'قادم';

  @override
  String get timePast => 'سابق';

  @override
  String get timeOverdue => 'متأخر';

  @override
  String get dateFrom => 'من';

  @override
  String get dateTo => 'إلى';

  @override
  String get anyDate => 'أي تاريخ';

  @override
  String ageBetween(String min, String max) {
    return 'العمر $min–$max';
  }

  @override
  String get saveSearch => 'حفظ البحث';

  @override
  String get searchSaved => 'تم حفظ البحث';

  @override
  String deleteSavedSearchConfirm(String name) {
    return 'هل تريد حذف البحث المحفوظ «$name»؟';
  }

  @override
  String resultsFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count نتيجة',
      many: '$count نتيجة',
      few: '$count نتائج',
      two: 'نتيجتان',
      one: 'نتيجة واحدة',
      zero: 'لا نتائج',
    );
    return '$_temp0';
  }

  @override
  String get reports => 'التقارير';

  @override
  String get reportPeople => 'الأشخاص';

  @override
  String get reportByCategory => 'حسب التصنيف';

  @override
  String get reportUncategorized => 'بلا تصنيف';

  @override
  String get reportAges => 'توزيع الأعمار';

  @override
  String get reportUnknownAge => 'عمر غير معروف';

  @override
  String get reportBirthdaysByMonth => 'أعياد الميلاد حسب الشهر';

  @override
  String get reportEventsByType => 'الأحداث حسب النوع';

  @override
  String get reportUpcoming => 'القادم';

  @override
  String reportNextDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'الـ$count يوم القادمة',
      many: 'الـ$count يومًا القادمة',
      few: 'الأيام الـ$count القادمة',
      two: 'اليومان التاليان',
      one: 'اليوم التالي',
    );
    return '$_temp0';
  }

  @override
  String get reportCommitments => 'الالتزامات';

  @override
  String get reportMemoriesMilestones => 'الذكريات والمحطات';

  @override
  String get reportNoData => 'لا توجد بيانات بعد.';

  @override
  String ageBucket(int from, int to) {
    return '$from–$to';
  }

  @override
  String ageBucketPlus(int from) {
    return '$from+';
  }

  @override
  String get export => 'التصدير';

  @override
  String get exportHint =>
      'ملفات CSV تُفتح في Excel وجداول Google وNumbers مع ظهور العربية بشكل صحيح.';

  @override
  String get exportPeople => 'تصدير الأشخاص';

  @override
  String get exportEvents => 'تصدير الأحداث';

  @override
  String get exportCommitments => 'تصدير الالتزامات';

  @override
  String get exportMemories => 'تصدير الذكريات';

  @override
  String get exportFailed => 'تعذّر تصدير الملف. أعد المحاولة.';

  @override
  String get csvAge => 'العمر';

  @override
  String get csvRecurrence => 'التكرار';

  @override
  String get csvPhotos => 'الصور';

  @override
  String get csvStart => 'البداية';

  @override
  String get csvEnd => 'النهاية';

  @override
  String get csvPeriodMonths => 'مدة التجديد (بالأشهر)';

  @override
  String get securityTitle => 'الأمان والخصوصية';

  @override
  String get appLock => 'قفل التطبيق';

  @override
  String get appLockHint => 'طلب رمز PIN عند فتح التطبيق';

  @override
  String get changePin => 'تغيير الرمز';

  @override
  String get useBiometrics => 'الفتح بالبصمة';

  @override
  String get useBiometricsHint =>
      'يستخدم البصمة أو الوجه المسجّل على هذا الهاتف';

  @override
  String get lockAfter => 'إعادة القفل بعد مغادرة التطبيق';

  @override
  String get lockImmediately => 'فورًا';

  @override
  String get pinNew => 'الرمز الجديد';

  @override
  String get pinConfirm => 'تأكيد الرمز';

  @override
  String get pinCurrent => 'الرمز الحالي';

  @override
  String get pinFormatError => 'استخدم من 4 إلى 8 أرقام';

  @override
  String get pinMismatch => 'الرمزان غير متطابقين';

  @override
  String get pinWrong => 'رمز غير صحيح';

  @override
  String get pinSetupTitle => 'تعيين رمز PIN';

  @override
  String get pinForgotWarning =>
      'لا يمكن استرجاع الرمز إذا نسيته، وستضطر حينها إلى مسح بيانات التطبيق. احتفظ بنسخة احتياطية.';

  @override
  String get disableLockTitle => 'إيقاف قفل التطبيق';

  @override
  String get lockEnabledDone => 'تم تفعيل قفل التطبيق';

  @override
  String get lockDisabledDone => 'تم إيقاف قفل التطبيق';

  @override
  String get pinChangedDone => 'تم تغيير الرمز';

  @override
  String get biometricFailed => 'لم يتم التحقق من البصمة';

  @override
  String get lockedTitle => 'التطبيق مقفل';

  @override
  String get enterPin => 'أدخل الرمز';

  @override
  String get unlock => 'فتح';

  @override
  String get biometricReason => 'افتح تطبيق Datei';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get privacyIntro =>
      'صُمّم تطبيق Datei ليُبقي معلوماتك على هاتفك. توضح هذه السياسة ما يحفظه التطبيق وأين يحفظه وما الذي تتحكم فيه.';

  @override
  String get privacyStoredTitle => 'ما الذي يُحفظ';

  @override
  String get privacyStoredBody =>
      'الأشخاص والمناسبات والالتزامات والذكريات والإنجازات والمشاريع والصور والإعدادات التي تُدخلها تُحفظ فقط في المساحة الخاصة بالتطبيق على هذا الجهاز. لا يملك Datei خوادم خاصة به ولا يرسل هذه البيانات إلى أي جهة.';

  @override
  String get privacyPhotosTitle => 'الصور';

  @override
  String get privacyPhotosBody =>
      'تُضاف الصور فقط عندما تختارها بنفسك من منتقي الصور في النظام. ينسخ التطبيق الصور التي تختارها إلى مساحته الخاصة ولا يطّلع على بقية معرض الصور.';

  @override
  String get privacyNotificationsTitle => 'الإشعارات';

  @override
  String get privacyNotificationsBody =>
      'يجدول نظام أندرويد التذكيرات على الجهاز نفسه. يُنشأ نصّها على هاتفك ولا يُرسل إلى أي خادم.';

  @override
  String get privacyBackupTitle => 'النسخ الاحتياطي والتصدير';

  @override
  String get privacyBackupBody =>
      'لا يُنشأ ملف النسخة الاحتياطية أو ملف CSV إلا عندما تطلبه، ويُحفظ أو يُشارك حيث تختار أنت. احمِ النسخ الاحتياطية بكلمة مرور إذا حفظتها في خدمة سحابية. النسخ الاحتياطي التلقائي في أندرويد معطّل لهذا التطبيق.';

  @override
  String get privacySecurityTitle => 'قفل التطبيق';

  @override
  String get privacySecurityBody =>
      'عند تفعيل قفل التطبيق لا يُحفظ إلا ناتج تجزئة مُملّح للرمز داخل التخزين الآمن في الهاتف. يتولى أندرويد التحقق من البصمة أو الوجه، ولا يتلقى التطبيق بياناتك الحيوية مطلقًا.';

  @override
  String get privacyAccountsTitle => 'تسجيل الدخول';

  @override
  String get privacyAccountsBody =>
      'يعمل Datei حاليًا في وضع الضيف دون حساب. إذا أُضيف تسجيل الدخول عبر Google أو Facebook لاحقًا فستُحدَّث هذه السياسة أولًا لتوضيح ما يُشارك مع هذه الخدمات بالتحديد.';

  @override
  String get privacyShareTitle => 'المشاركة والإعلانات والتتبّع';

  @override
  String get privacyShareBody =>
      'لا يحتوي Datei على إعلانات أو أدوات تحليل أو تتبّع، ولا تُباع بياناتك أو تُشارك مع أحد.';

  @override
  String get privacyDeleteTitle => 'حذف بياناتك';

  @override
  String get privacyDeleteBody =>
      'يمكنك حذف كل البيانات من الإعدادات ← مسح جميع البيانات، أو بإلغاء تثبيت التطبيق. تبقى ملفات النسخ الاحتياطية التي حفظتها في مكان آخر حيث وضعتها إلى أن تحذفها بنفسك.';

  @override
  String get privacyChangesTitle => 'التغييرات والتواصل';

  @override
  String get privacyChangesBody =>
      'ستظهر أي تغييرات على هذه السياسة داخل التطبيق مع تاريخ جديد. للاستفسارات استخدم بيانات التواصل الموجودة في صفحة التطبيق على المتجر.';

  @override
  String get backupHint =>
      'يضم ملف النسخة الاحتياطية جميع بياناتك وصورك. احفظه في مكان آمن مثل Google Drive أو جهاز كمبيوتر لنقل بياناتك إلى هاتف جديد أو استعادتها عند فقدانها.';

  @override
  String get backupCreate => 'إنشاء نسخة احتياطية';

  @override
  String get backupCreateHint => 'حفظ ملف بامتداد datei';

  @override
  String get backupRestore => 'الاستعادة من نسخة احتياطية';

  @override
  String get backupRestoreHint => 'يستبدل البيانات الموجودة على هذا الجهاز';

  @override
  String get backupEncrypt => 'حماية بكلمة مرور';

  @override
  String get backupPassword => 'كلمة المرور';

  @override
  String get backupPasswordConfirm => 'تأكيد كلمة المرور';

  @override
  String get backupPasswordShort => 'استخدم 6 أحرف على الأقل';

  @override
  String get backupPasswordMismatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get backupPasswordWarning =>
      'إذا نسيت كلمة المرور فلن يمكن فتح النسخة الاحتياطية.';

  @override
  String get backupSaved => 'تم حفظ النسخة الاحتياطية';

  @override
  String get backupFailed => 'تعذّر إنشاء النسخة الاحتياطية. حاول مرة أخرى.';

  @override
  String get backupEnterPassword => 'هذه النسخة محمية. أدخل كلمة المرور.';

  @override
  String get backupWrongPassword => 'كلمة مرور غير صحيحة';

  @override
  String get backupDamaged =>
      'هذا الملف ليس نسخة احتياطية من Datei أو أنه تالف.';

  @override
  String get backupNewer =>
      'أُنشئت هذه النسخة بإصدار أحدث من Datei. حدّث التطبيق أولًا.';

  @override
  String get backupReadFailed => 'تعذّرت قراءة الملف.';

  @override
  String get backupRestoreConfirmTitle => 'استعادة هذه النسخة؟';

  @override
  String get backupPhotos => 'الصور';

  @override
  String get backupRestoreWarning =>
      'ستُستبدل جميع البيانات الحالية على هذا الجهاز. تُحفظ نسخة أمان منها أولًا لتتمكن من التراجع.';

  @override
  String get backupRestoreAction => 'استعادة';

  @override
  String get backupRestored => 'تمت استعادة النسخة الاحتياطية';

  @override
  String get backupRestoreFailed => 'فشلت الاستعادة، ولم تتغير بياناتك.';

  @override
  String get backupUndo => 'التراجع عن آخر استعادة';

  @override
  String get backupWorking => 'جارٍ التنفيذ…';

  @override
  String lockAfterMinutes(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes دقيقة',
      few: '$minutes دقائق',
      two: 'دقيقتان',
      one: 'دقيقة',
    );
    return '$_temp0';
  }

  @override
  String pinLockedOut(int seconds) {
    return 'محاولات كثيرة. أعد المحاولة بعد $seconds ث.';
  }

  @override
  String privacyUpdated(String date) {
    return 'آخر تحديث: $date';
  }

  @override
  String backupCreatedOn(String date, String version) {
    return 'أُنشئت في $date · الإصدار $version';
  }

  @override
  String backupUndoHint(String date) {
    return 'نسخة أمان من $date';
  }
}
