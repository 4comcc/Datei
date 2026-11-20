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

  /// No description provided for @startupErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Datei couldn\'t start'**
  String get startupErrorTitle;

  /// No description provided for @startupErrorBody.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while opening your data on this device. Your data has not been deleted. Try again, and if it keeps happening, send the details below to the developer.'**
  String get startupErrorBody;

  /// No description provided for @startupTimeout.
  ///
  /// In en, this message translates to:
  /// **'Opening the database took too long.'**
  String get startupTimeout;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @copyDetails.
  ///
  /// In en, this message translates to:
  /// **'Copy details'**
  String get copyDetails;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copied;

  /// No description provided for @fieldGender.
  ///
  /// In en, this message translates to:
  /// **'Gender (optional)'**
  String get fieldGender;

  /// No description provided for @genderUnspecified.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get genderUnspecified;

  /// No description provided for @genderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get genderMale;

  /// No description provided for @genderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get genderFemale;

  /// No description provided for @fieldAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get fieldAddress;

  /// No description provided for @fieldOrganization.
  ///
  /// In en, this message translates to:
  /// **'Workplace'**
  String get fieldOrganization;

  /// No description provided for @birthYearUnknown.
  ///
  /// In en, this message translates to:
  /// **'I don\'t know the year'**
  String get birthYearUnknown;

  /// No description provided for @birthYearUnknownHint.
  ///
  /// In en, this message translates to:
  /// **'Only the day and month will be used. Age won\'t be shown.'**
  String get birthYearUnknownHint;

  /// No description provided for @manageCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get manageCategories;

  /// No description provided for @addCategory.
  ///
  /// In en, this message translates to:
  /// **'New category'**
  String get addCategory;

  /// No description provided for @categoryName.
  ///
  /// In en, this message translates to:
  /// **'Category name'**
  String get categoryName;

  /// No description provided for @editCategory.
  ///
  /// In en, this message translates to:
  /// **'Edit category'**
  String get editCategory;

  /// No description provided for @deleteCategoryConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete the category “{name}”? People in it are kept; only the category is removed.'**
  String deleteCategoryConfirm(String name);

  /// No description provided for @systemCategoriesNote.
  ///
  /// In en, this message translates to:
  /// **'Built-in categories can\'t be renamed or deleted.'**
  String get systemCategoriesNote;

  /// No description provided for @yourCategories.
  ///
  /// In en, this message translates to:
  /// **'Your categories'**
  String get yourCategories;

  /// No description provided for @builtInCategories.
  ///
  /// In en, this message translates to:
  /// **'Built-in'**
  String get builtInCategories;

  /// No description provided for @noCustomCategories.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t created any categories yet.'**
  String get noCustomCategories;

  /// No description provided for @sectionRelationships.
  ///
  /// In en, this message translates to:
  /// **'Relationships'**
  String get sectionRelationships;

  /// No description provided for @addRelationship.
  ///
  /// In en, this message translates to:
  /// **'Add relationship'**
  String get addRelationship;

  /// No description provided for @relationshipIs.
  ///
  /// In en, this message translates to:
  /// **'{name} is…'**
  String relationshipIs(String name);

  /// No description provided for @relationshipOf.
  ///
  /// In en, this message translates to:
  /// **'…of'**
  String get relationshipOf;

  /// No description provided for @relatedToMe.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get relatedToMe;

  /// No description provided for @customRelationshipLabel.
  ///
  /// In en, this message translates to:
  /// **'Relationship name'**
  String get customRelationshipLabel;

  /// No description provided for @noRelationships.
  ///
  /// In en, this message translates to:
  /// **'No relationships yet.'**
  String get noRelationships;

  /// No description provided for @relationOfPerson.
  ///
  /// In en, this message translates to:
  /// **'{relation} of {name}'**
  String relationOfPerson(String relation, String name);

  /// No description provided for @relationOfMe.
  ///
  /// In en, this message translates to:
  /// **'{relation} (to you)'**
  String relationOfMe(String relation);

  /// No description provided for @relationFather.
  ///
  /// In en, this message translates to:
  /// **'Father'**
  String get relationFather;

  /// No description provided for @relationMother.
  ///
  /// In en, this message translates to:
  /// **'Mother'**
  String get relationMother;

  /// No description provided for @relationSon.
  ///
  /// In en, this message translates to:
  /// **'Son'**
  String get relationSon;

  /// No description provided for @relationDaughter.
  ///
  /// In en, this message translates to:
  /// **'Daughter'**
  String get relationDaughter;

  /// No description provided for @relationBrother.
  ///
  /// In en, this message translates to:
  /// **'Brother'**
  String get relationBrother;

  /// No description provided for @relationSister.
  ///
  /// In en, this message translates to:
  /// **'Sister'**
  String get relationSister;

  /// No description provided for @relationSpouse.
  ///
  /// In en, this message translates to:
  /// **'Spouse'**
  String get relationSpouse;

  /// No description provided for @relationRelative.
  ///
  /// In en, this message translates to:
  /// **'Relative'**
  String get relationRelative;

  /// No description provided for @relationFriend.
  ///
  /// In en, this message translates to:
  /// **'Friend'**
  String get relationFriend;

  /// No description provided for @relationColleague.
  ///
  /// In en, this message translates to:
  /// **'Colleague'**
  String get relationColleague;

  /// No description provided for @relationCustom.
  ///
  /// In en, this message translates to:
  /// **'Other…'**
  String get relationCustom;

  /// No description provided for @removeRelationship.
  ///
  /// In en, this message translates to:
  /// **'Remove relationship'**
  String get removeRelationship;

  /// No description provided for @errorChoosePerson.
  ///
  /// In en, this message translates to:
  /// **'Choose a person'**
  String get errorChoosePerson;

  /// No description provided for @customFieldsTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom fields'**
  String get customFieldsTitle;

  /// No description provided for @customFieldsHint.
  ///
  /// In en, this message translates to:
  /// **'Add your own fields to every person, such as blood type or ID number.'**
  String get customFieldsHint;

  /// No description provided for @addCustomField.
  ///
  /// In en, this message translates to:
  /// **'New field'**
  String get addCustomField;

  /// No description provided for @editCustomField.
  ///
  /// In en, this message translates to:
  /// **'Edit field'**
  String get editCustomField;

  /// No description provided for @customFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Field name'**
  String get customFieldLabel;

  /// No description provided for @customFieldType.
  ///
  /// In en, this message translates to:
  /// **'Field type'**
  String get customFieldType;

  /// No description provided for @fieldTypeText.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get fieldTypeText;

  /// No description provided for @fieldTypeNumber.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get fieldTypeNumber;

  /// No description provided for @fieldTypeDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get fieldTypeDate;

  /// No description provided for @fieldTypeUrl.
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get fieldTypeUrl;

  /// No description provided for @noCustomFields.
  ///
  /// In en, this message translates to:
  /// **'No custom fields yet.'**
  String get noCustomFields;

  /// No description provided for @deleteCustomFieldConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete the field “{label}”? Its values will be removed from everyone.'**
  String deleteCustomFieldConfirm(String label);

  /// No description provided for @ageOnDate.
  ///
  /// In en, this message translates to:
  /// **'Age on a date'**
  String get ageOnDate;

  /// No description provided for @notBornYet.
  ///
  /// In en, this message translates to:
  /// **'Not born yet on this date.'**
  String get notBornYet;

  /// No description provided for @untilBirthday.
  ///
  /// In en, this message translates to:
  /// **'{months} months and {days} days to go'**
  String untilBirthday(int months, int days);

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @filtersActive.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Filters} =1{1 filter} other{{count} filters}}'**
  String filtersActive(int count);

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearFilters;

  /// No description provided for @showResults.
  ///
  /// In en, this message translates to:
  /// **'Show results'**
  String get showResults;

  /// No description provided for @ageRange.
  ///
  /// In en, this message translates to:
  /// **'Age range'**
  String get ageRange;

  /// No description provided for @minAge.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get minAge;

  /// No description provided for @maxAge.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get maxAge;

  /// No description provided for @birthMonth.
  ///
  /// In en, this message translates to:
  /// **'Birth month'**
  String get birthMonth;

  /// No description provided for @birthDayOfMonth.
  ///
  /// In en, this message translates to:
  /// **'Birth day'**
  String get birthDayOfMonth;

  /// No description provided for @birthYear.
  ///
  /// In en, this message translates to:
  /// **'Birth year'**
  String get birthYear;

  /// No description provided for @anyValue.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get anyValue;

  /// No description provided for @birthDateFilter.
  ///
  /// In en, this message translates to:
  /// **'Birth date'**
  String get birthDateFilter;

  /// No description provided for @withBirthDate.
  ///
  /// In en, this message translates to:
  /// **'Has a birth date'**
  String get withBirthDate;

  /// No description provided for @withoutBirthDate.
  ///
  /// In en, this message translates to:
  /// **'No birth date'**
  String get withoutBirthDate;

  /// No description provided for @birthdayWithin.
  ///
  /// In en, this message translates to:
  /// **'Birthday within'**
  String get birthdayWithin;

  /// No description provided for @withinDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String withinDays(int count);

  /// No description provided for @relationshipFilter.
  ///
  /// In en, this message translates to:
  /// **'Has relationship'**
  String get relationshipFilter;

  /// No description provided for @saveFilter.
  ///
  /// In en, this message translates to:
  /// **'Save filter'**
  String get saveFilter;

  /// No description provided for @filterName.
  ///
  /// In en, this message translates to:
  /// **'Filter name'**
  String get filterName;

  /// No description provided for @filterSaved.
  ///
  /// In en, this message translates to:
  /// **'Filter saved'**
  String get filterSaved;

  /// No description provided for @deleteSavedFilterConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete the saved filter “{name}”?'**
  String deleteSavedFilterConfirm(String name);

  /// No description provided for @errorInvalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get errorInvalidNumber;

  /// No description provided for @errorInvalidUrl.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid link starting with http:// or https://'**
  String get errorInvalidUrl;

  /// No description provided for @errorAgeRange.
  ///
  /// In en, this message translates to:
  /// **'“From” must not be greater than “To”'**
  String get errorAgeRange;

  /// No description provided for @resultsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No people} =1{1 person} other{{count} people}}'**
  String resultsCount(int count);

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @repeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get repeat;

  /// No description provided for @repeatNone.
  ///
  /// In en, this message translates to:
  /// **'Does not repeat'**
  String get repeatNone;

  /// No description provided for @repeatDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get repeatDaily;

  /// No description provided for @repeatWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get repeatWeekly;

  /// No description provided for @repeatMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get repeatMonthly;

  /// No description provided for @repeatYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get repeatYearly;

  /// No description provided for @everyLabel.
  ///
  /// In en, this message translates to:
  /// **'Every'**
  String get everyLabel;

  /// No description provided for @unitDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{day} other{days}}'**
  String unitDays(int count);

  /// No description provided for @unitWeeks.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{week} other{weeks}}'**
  String unitWeeks(int count);

  /// No description provided for @unitMonths.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{month} other{months}}'**
  String unitMonths(int count);

  /// No description provided for @unitYears.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{year} other{years}}'**
  String unitYears(int count);

  /// No description provided for @everyN.
  ///
  /// In en, this message translates to:
  /// **'Every {count} {unit}'**
  String everyN(int count, String unit);

  /// No description provided for @onWeekdays.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get onWeekdays;

  /// No description provided for @monthlyOnDay.
  ///
  /// In en, this message translates to:
  /// **'On day {day}'**
  String monthlyOnDay(int day);

  /// No description provided for @monthlyOnNth.
  ///
  /// In en, this message translates to:
  /// **'On the {position} {weekday}'**
  String monthlyOnNth(String position, String weekday);

  /// No description provided for @posFirst.
  ///
  /// In en, this message translates to:
  /// **'first'**
  String get posFirst;

  /// No description provided for @posSecond.
  ///
  /// In en, this message translates to:
  /// **'second'**
  String get posSecond;

  /// No description provided for @posThird.
  ///
  /// In en, this message translates to:
  /// **'third'**
  String get posThird;

  /// No description provided for @posFourth.
  ///
  /// In en, this message translates to:
  /// **'fourth'**
  String get posFourth;

  /// No description provided for @posLast.
  ///
  /// In en, this message translates to:
  /// **'last'**
  String get posLast;

  /// No description provided for @skipShortMonths.
  ///
  /// In en, this message translates to:
  /// **'Skip months without this day'**
  String get skipShortMonths;

  /// No description provided for @ends.
  ///
  /// In en, this message translates to:
  /// **'Ends'**
  String get ends;

  /// No description provided for @endsNever.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get endsNever;

  /// No description provided for @endsOnDate.
  ///
  /// In en, this message translates to:
  /// **'On a date'**
  String get endsOnDate;

  /// No description provided for @endsAfter.
  ///
  /// In en, this message translates to:
  /// **'After'**
  String get endsAfter;

  /// No description provided for @occurrencesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 time} other{{count} times}}'**
  String occurrencesCount(int count);

  /// No description provided for @untilDate.
  ///
  /// In en, this message translates to:
  /// **'until {date}'**
  String untilDate(String date);

  /// No description provided for @fieldEndDate.
  ///
  /// In en, this message translates to:
  /// **'End date (optional)'**
  String get fieldEndDate;

  /// No description provided for @fieldEndTime.
  ///
  /// In en, this message translates to:
  /// **'End time (optional)'**
  String get fieldEndTime;

  /// No description provided for @fieldPriority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get fieldPriority;

  /// No description provided for @priorityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get priorityLow;

  /// No description provided for @priorityNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get priorityNormal;

  /// No description provided for @priorityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get priorityHigh;

  /// No description provided for @priorityCritical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get priorityCritical;

  /// No description provided for @fieldStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get fieldStatus;

  /// No description provided for @statusPlanned.
  ///
  /// In en, this message translates to:
  /// **'Planned'**
  String get statusPlanned;

  /// No description provided for @statusDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get statusDone;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @errorEndBeforeStart.
  ///
  /// In en, this message translates to:
  /// **'End can\'t be before the start'**
  String get errorEndBeforeStart;

  /// No description provided for @errorInterval.
  ///
  /// In en, this message translates to:
  /// **'Enter a number from 1 to 999'**
  String get errorInterval;

  /// No description provided for @errorWeekdays.
  ///
  /// In en, this message translates to:
  /// **'Choose at least one day'**
  String get errorWeekdays;

  /// No description provided for @hijriInput.
  ///
  /// In en, this message translates to:
  /// **'Enter a Hijri date'**
  String get hijriInput;

  /// No description provided for @hijriDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get hijriDay;

  /// No description provided for @hijriMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get hijriMonth;

  /// No description provided for @hijriYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get hijriYear;

  /// No description provided for @hijriInvalid.
  ///
  /// In en, this message translates to:
  /// **'This Hijri date isn\'t valid or is outside 1356–1500 AH'**
  String get hijriInvalid;

  /// No description provided for @hijriConverted.
  ///
  /// In en, this message translates to:
  /// **'Gregorian: {date}'**
  String hijriConverted(String date);

  /// No description provided for @hijriFormat.
  ///
  /// In en, this message translates to:
  /// **'{day} {month} {year} AH'**
  String hijriFormat(int day, String month, int year);

  /// No description provided for @hijriMonth1.
  ///
  /// In en, this message translates to:
  /// **'Muharram'**
  String get hijriMonth1;

  /// No description provided for @hijriMonth2.
  ///
  /// In en, this message translates to:
  /// **'Safar'**
  String get hijriMonth2;

  /// No description provided for @hijriMonth3.
  ///
  /// In en, this message translates to:
  /// **'Rabi al-Awwal'**
  String get hijriMonth3;

  /// No description provided for @hijriMonth4.
  ///
  /// In en, this message translates to:
  /// **'Rabi al-Thani'**
  String get hijriMonth4;

  /// No description provided for @hijriMonth5.
  ///
  /// In en, this message translates to:
  /// **'Jumada al-Ula'**
  String get hijriMonth5;

  /// No description provided for @hijriMonth6.
  ///
  /// In en, this message translates to:
  /// **'Jumada al-Akhirah'**
  String get hijriMonth6;

  /// No description provided for @hijriMonth7.
  ///
  /// In en, this message translates to:
  /// **'Rajab'**
  String get hijriMonth7;

  /// No description provided for @hijriMonth8.
  ///
  /// In en, this message translates to:
  /// **'Shaban'**
  String get hijriMonth8;

  /// No description provided for @hijriMonth9.
  ///
  /// In en, this message translates to:
  /// **'Ramadan'**
  String get hijriMonth9;

  /// No description provided for @hijriMonth10.
  ///
  /// In en, this message translates to:
  /// **'Shawwal'**
  String get hijriMonth10;

  /// No description provided for @hijriMonth11.
  ///
  /// In en, this message translates to:
  /// **'Dhu al-Qadah'**
  String get hijriMonth11;

  /// No description provided for @hijriMonth12.
  ///
  /// In en, this message translates to:
  /// **'Dhu al-Hijjah'**
  String get hijriMonth12;

  /// No description provided for @editScopeTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit recurring event'**
  String get editScopeTitle;

  /// No description provided for @deleteScopeTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete recurring event'**
  String get deleteScopeTitle;

  /// No description provided for @scopeThis.
  ///
  /// In en, this message translates to:
  /// **'This event only'**
  String get scopeThis;

  /// No description provided for @scopeFollowing.
  ///
  /// In en, this message translates to:
  /// **'This and following events'**
  String get scopeFollowing;

  /// No description provided for @scopeAll.
  ///
  /// In en, this message translates to:
  /// **'All events in the series'**
  String get scopeAll;

  /// No description provided for @occurrenceOf.
  ///
  /// In en, this message translates to:
  /// **'Occurrence on {date}'**
  String occurrenceOf(String date);

  /// No description provided for @manageEventTypes.
  ///
  /// In en, this message translates to:
  /// **'Event types'**
  String get manageEventTypes;

  /// No description provided for @addEventType.
  ///
  /// In en, this message translates to:
  /// **'New type'**
  String get addEventType;

  /// No description provided for @editEventType.
  ///
  /// In en, this message translates to:
  /// **'Edit type'**
  String get editEventType;

  /// No description provided for @eventTypeName.
  ///
  /// In en, this message translates to:
  /// **'Type name'**
  String get eventTypeName;

  /// No description provided for @deleteEventTypeConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete the type “{name}”? Its events will move to “Other”.'**
  String deleteEventTypeConfirm(String name);

  /// No description provided for @yourEventTypes.
  ///
  /// In en, this message translates to:
  /// **'Your types'**
  String get yourEventTypes;

  /// No description provided for @noCustomEventTypes.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t created any event types yet.'**
  String get noCustomEventTypes;

  /// No description provided for @systemEventTypesNote.
  ///
  /// In en, this message translates to:
  /// **'Built-in types can\'t be renamed or deleted.'**
  String get systemEventTypesNote;

  /// No description provided for @viewMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get viewMonth;

  /// No description provided for @viewWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get viewWeek;

  /// No description provided for @viewDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get viewDay;

  /// No description provided for @goToDate.
  ///
  /// In en, this message translates to:
  /// **'Go to date'**
  String get goToDate;

  /// No description provided for @calendarFilter.
  ///
  /// In en, this message translates to:
  /// **'Show in calendar'**
  String get calendarFilter;

  /// No description provided for @birthdaysLabel.
  ///
  /// In en, this message translates to:
  /// **'Birthdays'**
  String get birthdaysLabel;

  /// No description provided for @searchCalendar.
  ///
  /// In en, this message translates to:
  /// **'Search calendar'**
  String get searchCalendar;

  /// No description provided for @searchCalendarHint.
  ///
  /// In en, this message translates to:
  /// **'Search events and birthdays…'**
  String get searchCalendarHint;

  /// No description provided for @searchCalendarScope.
  ///
  /// In en, this message translates to:
  /// **'Showing matches from a year ago to a year ahead'**
  String get searchCalendarScope;

  /// No description provided for @allDay.
  ///
  /// In en, this message translates to:
  /// **'All day'**
  String get allDay;

  /// No description provided for @previousPeriod.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previousPeriod;

  /// No description provided for @nextPeriod.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextPeriod;

  /// No description provided for @settingsCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get settingsCalendar;

  /// No description provided for @showHijri.
  ///
  /// In en, this message translates to:
  /// **'Show Hijri dates'**
  String get showHijri;

  /// No description provided for @hijriAdjustment.
  ///
  /// In en, this message translates to:
  /// **'Hijri adjustment'**
  String get hijriAdjustment;

  /// No description provided for @hijriNote.
  ///
  /// In en, this message translates to:
  /// **'Calculated with the Umm al-Qura calendar. Local moon sighting can differ by a day or two — adjust if needed. Gregorian dates are never changed.'**
  String get hijriNote;

  /// No description provided for @repeatsLabel.
  ///
  /// In en, this message translates to:
  /// **'Repeats'**
  String get repeatsLabel;

  /// No description provided for @hijriAdjustmentNone.
  ///
  /// In en, this message translates to:
  /// **'No adjustment'**
  String get hijriAdjustmentNone;

  /// No description provided for @hijriAdjustmentDays.
  ///
  /// In en, this message translates to:
  /// **'{value} day(s)'**
  String hijriAdjustmentDays(String value);

  /// No description provided for @unitTimes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{time} other{times}}'**
  String unitTimes(int count);

  /// No description provided for @commitmentTypeDomain.
  ///
  /// In en, this message translates to:
  /// **'Domain'**
  String get commitmentTypeDomain;

  /// No description provided for @commitmentTypeHosting.
  ///
  /// In en, this message translates to:
  /// **'Hosting'**
  String get commitmentTypeHosting;

  /// No description provided for @commitmentTypeSsl.
  ///
  /// In en, this message translates to:
  /// **'SSL certificate'**
  String get commitmentTypeSsl;

  /// No description provided for @commitmentTypeContract.
  ///
  /// In en, this message translates to:
  /// **'Contract'**
  String get commitmentTypeContract;

  /// No description provided for @commitmentTypeLicense.
  ///
  /// In en, this message translates to:
  /// **'License'**
  String get commitmentTypeLicense;

  /// No description provided for @commitmentTypeInsurance.
  ///
  /// In en, this message translates to:
  /// **'Insurance'**
  String get commitmentTypeInsurance;

  /// No description provided for @commitmentTypeWarranty.
  ///
  /// In en, this message translates to:
  /// **'Warranty'**
  String get commitmentTypeWarranty;

  /// No description provided for @commitmentTypeSubscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get commitmentTypeSubscription;

  /// No description provided for @commitmentTypeBill.
  ///
  /// In en, this message translates to:
  /// **'Bill'**
  String get commitmentTypeBill;

  /// No description provided for @commitmentTypePayment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get commitmentTypePayment;

  /// No description provided for @commitmentTypeInstallment.
  ///
  /// In en, this message translates to:
  /// **'Installment'**
  String get commitmentTypeInstallment;

  /// No description provided for @commitmentTypePassport.
  ///
  /// In en, this message translates to:
  /// **'Passport'**
  String get commitmentTypePassport;

  /// No description provided for @commitmentTypeNationalId.
  ///
  /// In en, this message translates to:
  /// **'ID card'**
  String get commitmentTypeNationalId;

  /// No description provided for @commitmentTypeVehicleLicense.
  ///
  /// In en, this message translates to:
  /// **'Vehicle license'**
  String get commitmentTypeVehicleLicense;

  /// No description provided for @commitmentTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get commitmentTypeOther;

  /// No description provided for @cstatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get cstatusActive;

  /// No description provided for @cstatusUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get cstatusUpcoming;

  /// No description provided for @cstatusDueSoon.
  ///
  /// In en, this message translates to:
  /// **'Due soon'**
  String get cstatusDueSoon;

  /// No description provided for @cstatusOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get cstatusOverdue;

  /// No description provided for @cstatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get cstatusCompleted;

  /// No description provided for @cstatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cstatusCancelled;

  /// No description provided for @commitments.
  ///
  /// In en, this message translates to:
  /// **'Commitments & renewals'**
  String get commitments;

  /// No description provided for @commitmentsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No commitments yet'**
  String get commitmentsEmptyTitle;

  /// No description provided for @commitmentsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Track renewals like domains, subscriptions, insurance, passports and IDs — Datei reminds you before they\'re due.'**
  String get commitmentsEmptyBody;

  /// No description provided for @editCommitment.
  ///
  /// In en, this message translates to:
  /// **'Edit commitment'**
  String get editCommitment;

  /// No description provided for @fieldName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get fieldName;

  /// No description provided for @fieldCommitmentType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get fieldCommitmentType;

  /// No description provided for @fieldProvider.
  ///
  /// In en, this message translates to:
  /// **'Provider or company'**
  String get fieldProvider;

  /// No description provided for @fieldStartDate.
  ///
  /// In en, this message translates to:
  /// **'Start date (optional)'**
  String get fieldStartDate;

  /// No description provided for @fieldExpiryDate.
  ///
  /// In en, this message translates to:
  /// **'Expiry or due date'**
  String get fieldExpiryDate;

  /// No description provided for @fieldRenewalDate.
  ///
  /// In en, this message translates to:
  /// **'Renew by (optional)'**
  String get fieldRenewalDate;

  /// No description provided for @fieldAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount (optional)'**
  String get fieldAmount;

  /// No description provided for @fieldCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get fieldCurrency;

  /// No description provided for @fieldRenewalPeriod.
  ///
  /// In en, this message translates to:
  /// **'Renewal period'**
  String get fieldRenewalPeriod;

  /// No description provided for @periodNone.
  ///
  /// In en, this message translates to:
  /// **'No fixed period'**
  String get periodNone;

  /// No description provided for @fieldReference.
  ///
  /// In en, this message translates to:
  /// **'Reference number (optional)'**
  String get fieldReference;

  /// No description provided for @fieldServiceUrl.
  ///
  /// In en, this message translates to:
  /// **'Service link (optional)'**
  String get fieldServiceUrl;

  /// No description provided for @fieldLifecycle.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get fieldLifecycle;

  /// No description provided for @remindersLabel.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get remindersLabel;

  /// No description provided for @reminderDaysBefore.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{On the day} =1{1 day before} other{{count} days before}}'**
  String reminderDaysBefore(int count);

  /// No description provided for @addCustomReminder.
  ///
  /// In en, this message translates to:
  /// **'Custom…'**
  String get addCustomReminder;

  /// No description provided for @customReminderDays.
  ///
  /// In en, this message translates to:
  /// **'Days before'**
  String get customReminderDays;

  /// No description provided for @renew.
  ///
  /// In en, this message translates to:
  /// **'Renew'**
  String get renew;

  /// No description provided for @renewTitle.
  ///
  /// In en, this message translates to:
  /// **'Renew'**
  String get renewTitle;

  /// No description provided for @newExpiryDate.
  ///
  /// In en, this message translates to:
  /// **'New expiry date'**
  String get newExpiryDate;

  /// No description provided for @renewalHistory.
  ///
  /// In en, this message translates to:
  /// **'Renewal history'**
  String get renewalHistory;

  /// No description provided for @noRenewals.
  ///
  /// In en, this message translates to:
  /// **'No renewals recorded yet.'**
  String get noRenewals;

  /// No description provided for @renewalFromTo.
  ///
  /// In en, this message translates to:
  /// **'{from} → {to}'**
  String renewalFromTo(String from, String to);

  /// No description provided for @renewedOn.
  ///
  /// In en, this message translates to:
  /// **'Renewed on {date}'**
  String renewedOn(String date);

  /// No description provided for @renewedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Renewed'**
  String get renewedSuccessfully;

  /// No description provided for @errorRenewDate.
  ///
  /// In en, this message translates to:
  /// **'Choose a date after the current expiry'**
  String get errorRenewDate;

  /// No description provided for @errorExpiryBeforeStart.
  ///
  /// In en, this message translates to:
  /// **'Expiry can\'t be before the start date'**
  String get errorExpiryBeforeStart;

  /// No description provided for @errorInvalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount like 250 or 99.50'**
  String get errorInvalidAmount;

  /// No description provided for @confirmDeleteCommitment.
  ///
  /// In en, this message translates to:
  /// **'Delete “{name}” and its renewal history?'**
  String confirmDeleteCommitment(String name);

  /// No description provided for @overdueBy.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Overdue by 1 day} other{Overdue by {count} days}}'**
  String overdueBy(int count);

  /// No description provided for @filterAllCommitments.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAllCommitments;

  /// No description provided for @sectionReminders.
  ///
  /// In en, this message translates to:
  /// **'Important reminders'**
  String get sectionReminders;

  /// No description provided for @emptyReminders.
  ///
  /// In en, this message translates to:
  /// **'Nothing due in the next 30 days.'**
  String get emptyReminders;

  /// No description provided for @todaySummaryOverdue.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 overdue} other{{count} overdue}}'**
  String todaySummaryOverdue(int count);

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @enableReminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get enableReminders;

  /// No description provided for @enableRemindersHint.
  ///
  /// In en, this message translates to:
  /// **'Get notified before birthdays, events and renewals.'**
  String get enableRemindersHint;

  /// No description provided for @remindersPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Notifications are blocked for Datei. Allow them in Android settings to get reminders.'**
  String get remindersPermissionDenied;

  /// No description provided for @defaultReminderTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder time for all-day items'**
  String get defaultReminderTime;

  /// No description provided for @birthdayReminders.
  ///
  /// In en, this message translates to:
  /// **'Birthday reminders'**
  String get birthdayReminders;

  /// No description provided for @reminderOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get reminderOff;

  /// No description provided for @preciseReminders.
  ///
  /// In en, this message translates to:
  /// **'Precise timing'**
  String get preciseReminders;

  /// No description provided for @preciseRemindersHint.
  ///
  /// In en, this message translates to:
  /// **'Reminders arrive on the exact minute. Without it, Android may delay them a little to save battery.'**
  String get preciseRemindersHint;

  /// No description provided for @testNotification.
  ///
  /// In en, this message translates to:
  /// **'Send a test notification'**
  String get testNotification;

  /// No description provided for @testNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'Notifications are working.'**
  String get testNotificationBody;

  /// No description provided for @remindersOffBanner.
  ///
  /// In en, this message translates to:
  /// **'Reminders are off, so you won\'t be notified before due dates.'**
  String get remindersOffBanner;

  /// No description provided for @turnOn.
  ///
  /// In en, this message translates to:
  /// **'Turn on'**
  String get turnOn;

  /// No description provided for @notifBirthdayTitle.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s birthday'**
  String notifBirthdayTitle(String name);

  /// No description provided for @notifBirthdayTurning.
  ///
  /// In en, this message translates to:
  /// **'{name} turns {age}'**
  String notifBirthdayTurning(String name, int age);

  /// No description provided for @notifCommitmentTitle.
  ///
  /// In en, this message translates to:
  /// **'{name} is due'**
  String notifCommitmentTitle(String name);

  /// No description provided for @notifWhen.
  ///
  /// In en, this message translates to:
  /// **'{relative} · {date}'**
  String notifWhen(String relative, String date);

  /// No description provided for @fieldReminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get fieldReminders;

  /// No description provided for @reminderAtTime.
  ///
  /// In en, this message translates to:
  /// **'At the time'**
  String get reminderAtTime;

  /// No description provided for @reminderMinutesBefore.
  ///
  /// In en, this message translates to:
  /// **'{count} min before'**
  String reminderMinutesBefore(int count);

  /// No description provided for @reminderHoursBefore.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 hour before} other{{count} hours before}}'**
  String reminderHoursBefore(int count);

  /// No description provided for @commitmentsLabel.
  ///
  /// In en, this message translates to:
  /// **'Renewals & commitments'**
  String get commitmentsLabel;

  /// No description provided for @addReminder.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addReminder;

  /// No description provided for @memories.
  ///
  /// In en, this message translates to:
  /// **'Memories'**
  String get memories;

  /// No description provided for @memoriesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No memories yet'**
  String get memoriesEmptyTitle;

  /// No description provided for @memoriesEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Save moments with their date, people and photos — even ones from years ago.'**
  String get memoriesEmptyBody;

  /// No description provided for @editMemory.
  ///
  /// In en, this message translates to:
  /// **'Edit memory'**
  String get editMemory;

  /// No description provided for @fieldMemoryText.
  ///
  /// In en, this message translates to:
  /// **'What happened?'**
  String get fieldMemoryText;

  /// No description provided for @fieldTags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get fieldTags;

  /// No description provided for @addTagHint.
  ///
  /// In en, this message translates to:
  /// **'Add a tag and press Enter'**
  String get addTagHint;

  /// No description provided for @fieldCategory.
  ///
  /// In en, this message translates to:
  /// **'Category (optional)'**
  String get fieldCategory;

  /// No description provided for @fieldLinkedEvent.
  ///
  /// In en, this message translates to:
  /// **'Linked event (optional)'**
  String get fieldLinkedEvent;

  /// No description provided for @noneOption.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get noneOption;

  /// No description provided for @photos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photos;

  /// No description provided for @addPhotos.
  ///
  /// In en, this message translates to:
  /// **'Add photos'**
  String get addPhotos;

  /// No description provided for @removePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get removePhoto;

  /// No description provided for @photoCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 photo} other{{count} photos}}'**
  String photoCount(int count);

  /// No description provided for @photosPickFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t add the photos. Try again.'**
  String get photosPickFailed;

  /// No description provided for @confirmDeleteMemory.
  ///
  /// In en, this message translates to:
  /// **'Delete “{title}” and its photos?'**
  String confirmDeleteMemory(String title);

  /// No description provided for @milestones.
  ///
  /// In en, this message translates to:
  /// **'Life milestones'**
  String get milestones;

  /// No description provided for @milestonesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No milestones yet'**
  String get milestonesEmptyTitle;

  /// No description provided for @milestonesEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Record turning points: graduations, first jobs, weddings, moving home, achievements.'**
  String get milestonesEmptyBody;

  /// No description provided for @addMilestone.
  ///
  /// In en, this message translates to:
  /// **'Add milestone'**
  String get addMilestone;

  /// No description provided for @editMilestone.
  ///
  /// In en, this message translates to:
  /// **'Edit milestone'**
  String get editMilestone;

  /// No description provided for @fieldMilestoneKind.
  ///
  /// In en, this message translates to:
  /// **'Kind'**
  String get fieldMilestoneKind;

  /// No description provided for @fieldPerson.
  ///
  /// In en, this message translates to:
  /// **'Person (optional)'**
  String get fieldPerson;

  /// No description provided for @fieldProject.
  ///
  /// In en, this message translates to:
  /// **'Project (optional)'**
  String get fieldProject;

  /// No description provided for @fieldDescription.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get fieldDescription;

  /// No description provided for @confirmDeleteMilestone.
  ///
  /// In en, this message translates to:
  /// **'Delete the milestone “{title}”?'**
  String confirmDeleteMilestone(String title);

  /// No description provided for @milestoneFirstSchoolDay.
  ///
  /// In en, this message translates to:
  /// **'First school day'**
  String get milestoneFirstSchoolDay;

  /// No description provided for @milestoneGraduation.
  ///
  /// In en, this message translates to:
  /// **'Graduation'**
  String get milestoneGraduation;

  /// No description provided for @milestoneFirstJob.
  ///
  /// In en, this message translates to:
  /// **'First job'**
  String get milestoneFirstJob;

  /// No description provided for @milestoneMarriage.
  ///
  /// In en, this message translates to:
  /// **'Marriage'**
  String get milestoneMarriage;

  /// No description provided for @milestoneNewHome.
  ///
  /// In en, this message translates to:
  /// **'New home'**
  String get milestoneNewHome;

  /// No description provided for @milestoneAchievement.
  ///
  /// In en, this message translates to:
  /// **'Achievement'**
  String get milestoneAchievement;

  /// No description provided for @milestoneProjectStart.
  ///
  /// In en, this message translates to:
  /// **'Project start'**
  String get milestoneProjectStart;

  /// No description provided for @milestoneGoalReached.
  ///
  /// In en, this message translates to:
  /// **'Goal reached'**
  String get milestoneGoalReached;

  /// No description provided for @milestoneCustom.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get milestoneCustom;

  /// No description provided for @projects.
  ///
  /// In en, this message translates to:
  /// **'Projects & goals'**
  String get projects;

  /// No description provided for @projectsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No projects yet'**
  String get projectsEmptyTitle;

  /// No description provided for @projectsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Keep goals and projects with their dates, people and related events.'**
  String get projectsEmptyBody;

  /// No description provided for @addProject.
  ///
  /// In en, this message translates to:
  /// **'Add project'**
  String get addProject;

  /// No description provided for @editProject.
  ///
  /// In en, this message translates to:
  /// **'Edit project'**
  String get editProject;

  /// No description provided for @fieldDueDate.
  ///
  /// In en, this message translates to:
  /// **'Due date (optional)'**
  String get fieldDueDate;

  /// No description provided for @errorDueBeforeStart.
  ///
  /// In en, this message translates to:
  /// **'The due date can\'t be before the start'**
  String get errorDueBeforeStart;

  /// No description provided for @fieldParticipants.
  ///
  /// In en, this message translates to:
  /// **'People involved'**
  String get fieldParticipants;

  /// No description provided for @fieldRelatedEvents.
  ///
  /// In en, this message translates to:
  /// **'Related events'**
  String get fieldRelatedEvents;

  /// No description provided for @projectPlanned.
  ///
  /// In en, this message translates to:
  /// **'Planned'**
  String get projectPlanned;

  /// No description provided for @projectActive.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get projectActive;

  /// No description provided for @projectOnHold.
  ///
  /// In en, this message translates to:
  /// **'On hold'**
  String get projectOnHold;

  /// No description provided for @projectDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get projectDone;

  /// No description provided for @projectCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get projectCancelled;

  /// No description provided for @projectOverdue.
  ///
  /// In en, this message translates to:
  /// **'Past due'**
  String get projectOverdue;

  /// No description provided for @confirmDeleteProject.
  ///
  /// In en, this message translates to:
  /// **'Delete the project “{name}”?'**
  String confirmDeleteProject(String name);

  /// No description provided for @timeline.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get timeline;

  /// No description provided for @timelineOf.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s timeline'**
  String timelineOf(String name);

  /// No description provided for @timelineEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing in this period yet.'**
  String get timelineEmpty;

  /// No description provided for @periodAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get periodAll;

  /// No description provided for @periodPastYear.
  ///
  /// In en, this message translates to:
  /// **'Past year'**
  String get periodPastYear;

  /// No description provided for @periodThisYear.
  ///
  /// In en, this message translates to:
  /// **'This year'**
  String get periodThisYear;

  /// No description provided for @periodUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get periodUpcoming;

  /// No description provided for @groupEvents.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get groupEvents;

  /// No description provided for @groupBirthdays.
  ///
  /// In en, this message translates to:
  /// **'Birthdays'**
  String get groupBirthdays;

  /// No description provided for @groupMemories.
  ///
  /// In en, this message translates to:
  /// **'Memories'**
  String get groupMemories;

  /// No description provided for @groupMilestones.
  ///
  /// In en, this message translates to:
  /// **'Milestones'**
  String get groupMilestones;

  /// No description provided for @groupProjects.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get groupProjects;

  /// No description provided for @timelineBorn.
  ///
  /// In en, this message translates to:
  /// **'{name} was born'**
  String timelineBorn(String name);

  /// No description provided for @timelineProjectStarted.
  ///
  /// In en, this message translates to:
  /// **'Started: {name}'**
  String timelineProjectStarted(String name);

  /// No description provided for @timelineProjectDue.
  ///
  /// In en, this message translates to:
  /// **'Due: {name}'**
  String timelineProjectDue(String name);

  /// No description provided for @todayMarker.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayMarker;

  /// No description provided for @viewTimeline.
  ///
  /// In en, this message translates to:
  /// **'View timeline'**
  String get viewTimeline;

  /// No description provided for @sectionMemories.
  ///
  /// In en, this message translates to:
  /// **'Memories'**
  String get sectionMemories;
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
