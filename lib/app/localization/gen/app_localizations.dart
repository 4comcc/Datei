import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Datei'**
  String get appTitle;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Every Date Has a Story.'**
  String get tagline;

  /// No description provided for @chooseLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get chooseLanguageTitle;

  /// No description provided for @chooseLanguageHint.
  ///
  /// In en, this message translates to:
  /// **'You can change it anytime from Settings.'**
  String get chooseLanguageHint;

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Datei'**
  String get welcomeTitle;

  /// No description provided for @welcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Keep the people, events and dates that matter — organized in one calm place.'**
  String get welcomeBody;

  /// No description provided for @signInGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get signInGoogle;

  /// No description provided for @signInFacebook.
  ///
  /// In en, this message translates to:
  /// **'Continue with Facebook'**
  String get signInFacebook;

  /// No description provided for @continueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as guest'**
  String get continueAsGuest;

  /// No description provided for @signInComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Google and Facebook sign-in will be available in the full version. As a guest, everything works and your data stays on this device.'**
  String get signInComingSoon;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navPeople.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get navPeople;

  /// No description provided for @navEvents.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get navEvents;

  /// No description provided for @navCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get navCalendar;

  /// No description provided for @navMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get navMore;

  /// No description provided for @todaySummaryEvents.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No events today} =1{1 event today} other{{count} events today}}'**
  String todaySummaryEvents(int count);

  /// No description provided for @todaySummaryUpcoming.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Nothing in the next 30 days} =1{1 upcoming in 30 days} other{{count} upcoming in 30 days}}'**
  String todaySummaryUpcoming(int count);

  /// No description provided for @sectionToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get sectionToday;

  /// No description provided for @sectionBirthdays.
  ///
  /// In en, this message translates to:
  /// **'Upcoming birthdays'**
  String get sectionBirthdays;

  /// No description provided for @sectionUpcomingEvents.
  ///
  /// In en, this message translates to:
  /// **'Upcoming events'**
  String get sectionUpcomingEvents;

  /// No description provided for @sectionQuickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get sectionQuickActions;

  /// No description provided for @emptyToday.
  ///
  /// In en, this message translates to:
  /// **'Nothing scheduled for today.'**
  String get emptyToday;

  /// No description provided for @emptyBirthdays.
  ///
  /// In en, this message translates to:
  /// **'No birthdays in the next 30 days.'**
  String get emptyBirthdays;

  /// No description provided for @emptyUpcomingEvents.
  ///
  /// In en, this message translates to:
  /// **'No events in the next 30 days.'**
  String get emptyUpcomingEvents;

  /// No description provided for @addPerson.
  ///
  /// In en, this message translates to:
  /// **'Add person'**
  String get addPerson;

  /// No description provided for @addEvent.
  ///
  /// In en, this message translates to:
  /// **'Add event'**
  String get addEvent;

  /// No description provided for @editPerson.
  ///
  /// In en, this message translates to:
  /// **'Edit person'**
  String get editPerson;

  /// No description provided for @editEvent.
  ///
  /// In en, this message translates to:
  /// **'Edit event'**
  String get editEvent;

  /// No description provided for @quickAddTitle.
  ///
  /// In en, this message translates to:
  /// **'What would you like to add?'**
  String get quickAddTitle;

  /// No description provided for @comingInFullVersion.
  ///
  /// In en, this message translates to:
  /// **'Coming in the full version'**
  String get comingInFullVersion;

  /// No description provided for @addCommitment.
  ///
  /// In en, this message translates to:
  /// **'Add commitment'**
  String get addCommitment;

  /// No description provided for @addMemory.
  ///
  /// In en, this message translates to:
  /// **'Add memory'**
  String get addMemory;

  /// No description provided for @peopleEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No people yet'**
  String get peopleEmptyTitle;

  /// No description provided for @peopleEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add the people who matter to you and Datei will keep track of their ages and birthdays.'**
  String get peopleEmptyBody;

  /// No description provided for @eventsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No events yet'**
  String get eventsEmptyTitle;

  /// No description provided for @eventsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Record appointments, anniversaries, trips and achievements.'**
  String get eventsEmptyBody;

  /// No description provided for @searchPeopleHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name, occupation…'**
  String get searchPeopleHint;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No matching results.'**
  String get noResults;

  /// No description provided for @fieldFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fieldFullName;

  /// No description provided for @fieldDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Display name (optional)'**
  String get fieldDisplayName;

  /// No description provided for @fieldBirthDate.
  ///
  /// In en, this message translates to:
  /// **'Birth date'**
  String get fieldBirthDate;

  /// No description provided for @fieldPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get fieldPhone;

  /// No description provided for @fieldEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get fieldEmail;

  /// No description provided for @fieldOccupation.
  ///
  /// In en, this message translates to:
  /// **'Occupation'**
  String get fieldOccupation;

  /// No description provided for @fieldNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get fieldNotes;

  /// No description provided for @fieldCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get fieldCategories;

  /// No description provided for @fieldTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get fieldTitle;

  /// No description provided for @fieldEventType.
  ///
  /// In en, this message translates to:
  /// **'Event type'**
  String get fieldEventType;

  /// No description provided for @fieldDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get fieldDate;

  /// No description provided for @fieldTime.
  ///
  /// In en, this message translates to:
  /// **'Time (optional)'**
  String get fieldTime;

  /// No description provided for @fieldLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get fieldLocation;

  /// No description provided for @fieldLinkedPeople.
  ///
  /// In en, this message translates to:
  /// **'Linked people'**
  String get fieldLinkedPeople;

  /// No description provided for @fieldRepeatsYearly.
  ///
  /// In en, this message translates to:
  /// **'Repeats every year'**
  String get fieldRepeatsYearly;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @pickDate.
  ///
  /// In en, this message translates to:
  /// **'Pick a date'**
  String get pickDate;

  /// No description provided for @pickTime.
  ///
  /// In en, this message translates to:
  /// **'Pick a time'**
  String get pickTime;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @confirmDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete?'**
  String get confirmDeleteTitle;

  /// No description provided for @confirmDeletePerson.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}? Their links to events will be removed. This cannot be undone.'**
  String confirmDeletePerson(String name);

  /// No description provided for @confirmDeleteEvent.
  ///
  /// In en, this message translates to:
  /// **'Delete “{title}”? This cannot be undone.'**
  String confirmDeleteEvent(String title);

  /// No description provided for @errorRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get errorRequired;

  /// No description provided for @errorInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get errorInvalidEmail;

  /// No description provided for @errorFutureBirthDate.
  ///
  /// In en, this message translates to:
  /// **'Birth date can\'t be in the future'**
  String get errorFutureBirthDate;

  /// No description provided for @errorDateRequired.
  ///
  /// In en, this message translates to:
  /// **'Please pick a date'**
  String get errorDateRequired;

  /// No description provided for @savedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get savedSuccessfully;

  /// No description provided for @deletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get deletedSuccessfully;

  /// No description provided for @ageYears.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Under 1 year} =1{1 year old} other{{count} years old}}'**
  String ageYears(int count);

  /// No description provided for @ageBreakdown.
  ///
  /// In en, this message translates to:
  /// **'{years} y · {months} m · {days} d'**
  String ageBreakdown(int years, int months, int days);

  /// No description provided for @totalDaysLived.
  ///
  /// In en, this message translates to:
  /// **'{count} days lived'**
  String totalDaysLived(int count);

  /// No description provided for @turnsAge.
  ///
  /// In en, this message translates to:
  /// **'Turns {age}'**
  String turnsAge(int age);

  /// No description provided for @relativeDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Today} =1{Tomorrow} other{In {count} days}}'**
  String relativeDays(int count);

  /// No description provided for @birthdayOf.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s birthday'**
  String birthdayOf(String name);

  /// No description provided for @labelAge.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get labelAge;

  /// No description provided for @labelNextBirthday.
  ///
  /// In en, this message translates to:
  /// **'Next birthday'**
  String get labelNextBirthday;

  /// No description provided for @labelContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get labelContact;

  /// No description provided for @labelLinkedEvents.
  ///
  /// In en, this message translates to:
  /// **'Linked events'**
  String get labelLinkedEvents;

  /// No description provided for @noBirthDate.
  ///
  /// In en, this message translates to:
  /// **'No birth date'**
  String get noBirthDate;

  /// No description provided for @noLinkedEvents.
  ///
  /// In en, this message translates to:
  /// **'No linked events yet.'**
  String get noLinkedEvents;

  /// No description provided for @tabUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get tabUpcoming;

  /// No description provided for @tabPast.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get tabPast;

  /// No description provided for @yearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get yearly;

  /// No description provided for @calendarNoItems.
  ///
  /// In en, this message translates to:
  /// **'Nothing on this day.'**
  String get calendarNoItems;

  /// No description provided for @calendarToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get calendarToday;

  /// No description provided for @previousMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get previousMonth;

  /// No description provided for @nextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get nextMonth;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsTheme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @settingsAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccount;

  /// No description provided for @guestAccountStatus.
  ///
  /// In en, this message translates to:
  /// **'Guest — data is stored on this device only'**
  String get guestAccountStatus;

  /// No description provided for @moreModulesTitle.
  ///
  /// In en, this message translates to:
  /// **'Coming modules'**
  String get moreModulesTitle;

  /// No description provided for @moduleCommitments.
  ///
  /// In en, this message translates to:
  /// **'Commitments & renewals'**
  String get moduleCommitments;

  /// No description provided for @moduleMemories.
  ///
  /// In en, this message translates to:
  /// **'Memories & milestones'**
  String get moduleMemories;

  /// No description provided for @moduleTimeline.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get moduleTimeline;

  /// No description provided for @moduleReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get moduleReports;

  /// No description provided for @moduleBackup.
  ///
  /// In en, this message translates to:
  /// **'Backup & restore'**
  String get moduleBackup;

  /// No description provided for @settingsData.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get settingsData;

  /// No description provided for @resetData.
  ///
  /// In en, this message translates to:
  /// **'Erase all data'**
  String get resetData;

  /// No description provided for @resetDataConfirm.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes all people and events on this device. Continue?'**
  String get resetDataConfirm;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// No description provided for @prototypeNotice.
  ///
  /// In en, this message translates to:
  /// **'Early prototype (v{version}) for trying the experience. Data is stored locally on this device.'**
  String prototypeNotice(String version);

  /// No description provided for @categoryFamily.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get categoryFamily;

  /// No description provided for @categoryRelatives.
  ///
  /// In en, this message translates to:
  /// **'Relatives'**
  String get categoryRelatives;

  /// No description provided for @categoryFriends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get categoryFriends;

  /// No description provided for @categoryColleagues.
  ///
  /// In en, this message translates to:
  /// **'Colleagues'**
  String get categoryColleagues;

  /// No description provided for @categoryClients.
  ///
  /// In en, this message translates to:
  /// **'Clients'**
  String get categoryClients;

  /// No description provided for @categoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;

  /// No description provided for @eventTypeAnniversary.
  ///
  /// In en, this message translates to:
  /// **'Anniversary'**
  String get eventTypeAnniversary;

  /// No description provided for @eventTypeAppointment.
  ///
  /// In en, this message translates to:
  /// **'Appointment'**
  String get eventTypeAppointment;

  /// No description provided for @eventTypeTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get eventTypeTravel;

  /// No description provided for @eventTypeGraduation.
  ///
  /// In en, this message translates to:
  /// **'Graduation'**
  String get eventTypeGraduation;

  /// No description provided for @eventTypeAchievement.
  ///
  /// In en, this message translates to:
  /// **'Achievement'**
  String get eventTypeAchievement;

  /// No description provided for @eventTypeFamily.
  ///
  /// In en, this message translates to:
  /// **'Family event'**
  String get eventTypeFamily;

  /// No description provided for @eventTypeReligious.
  ///
  /// In en, this message translates to:
  /// **'Religious occasion'**
  String get eventTypeReligious;

  /// No description provided for @eventTypePersonal.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get eventTypePersonal;

  /// No description provided for @eventTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get eventTypeOther;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
