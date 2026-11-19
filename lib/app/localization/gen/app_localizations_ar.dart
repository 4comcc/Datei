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
}
