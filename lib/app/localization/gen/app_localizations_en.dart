// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Datei';

  @override
  String get tagline => 'Every Date Has a Story.';

  @override
  String get chooseLanguageTitle => 'Choose your language';

  @override
  String get chooseLanguageHint => 'You can change it anytime from Settings.';

  @override
  String get continueAction => 'Continue';

  @override
  String get welcomeTitle => 'Welcome to Datei';

  @override
  String get welcomeBody =>
      'Keep the people, events and dates that matter — organized in one calm place.';

  @override
  String get signInGoogle => 'Continue with Google';

  @override
  String get signInFacebook => 'Continue with Facebook';

  @override
  String get continueAsGuest => 'Continue as guest';

  @override
  String get signInComingSoon =>
      'Google and Facebook sign-in will be available in the full version. As a guest, everything works and your data stays on this device.';

  @override
  String get navHome => 'Home';

  @override
  String get navPeople => 'People';

  @override
  String get navEvents => 'Events';

  @override
  String get navCalendar => 'Calendar';

  @override
  String get navMore => 'More';

  @override
  String todaySummaryEvents(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count events today',
      one: '1 event today',
      zero: 'No events today',
    );
    return '$_temp0';
  }

  @override
  String todaySummaryUpcoming(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count upcoming in 30 days',
      one: '1 upcoming in 30 days',
      zero: 'Nothing in the next 30 days',
    );
    return '$_temp0';
  }

  @override
  String get sectionToday => 'Today';

  @override
  String get sectionBirthdays => 'Upcoming birthdays';

  @override
  String get sectionUpcomingEvents => 'Upcoming events';

  @override
  String get sectionQuickActions => 'Quick actions';

  @override
  String get emptyToday => 'Nothing scheduled for today.';

  @override
  String get emptyBirthdays => 'No birthdays in the next 30 days.';

  @override
  String get emptyUpcomingEvents => 'No events in the next 30 days.';

  @override
  String get addPerson => 'Add person';

  @override
  String get addEvent => 'Add event';

  @override
  String get editPerson => 'Edit person';

  @override
  String get editEvent => 'Edit event';

  @override
  String get quickAddTitle => 'What would you like to add?';

  @override
  String get comingInFullVersion => 'Coming in the full version';

  @override
  String get addCommitment => 'Add commitment';

  @override
  String get addMemory => 'Add memory';

  @override
  String get peopleEmptyTitle => 'No people yet';

  @override
  String get peopleEmptyBody =>
      'Add the people who matter to you and Datei will keep track of their ages and birthdays.';

  @override
  String get eventsEmptyTitle => 'No events yet';

  @override
  String get eventsEmptyBody =>
      'Record appointments, anniversaries, trips and achievements.';

  @override
  String get searchPeopleHint => 'Search by name, occupation…';

  @override
  String get filterAll => 'All';

  @override
  String get noResults => 'No matching results.';

  @override
  String get fieldFullName => 'Full name';

  @override
  String get fieldDisplayName => 'Display name (optional)';

  @override
  String get fieldBirthDate => 'Birth date';

  @override
  String get fieldPhone => 'Phone';

  @override
  String get fieldEmail => 'Email';

  @override
  String get fieldOccupation => 'Occupation';

  @override
  String get fieldNotes => 'Notes';

  @override
  String get fieldCategories => 'Categories';

  @override
  String get fieldTitle => 'Title';

  @override
  String get fieldEventType => 'Event type';

  @override
  String get fieldDate => 'Date';

  @override
  String get fieldTime => 'Time (optional)';

  @override
  String get fieldLocation => 'Location';

  @override
  String get fieldLinkedPeople => 'Linked people';

  @override
  String get fieldRepeatsYearly => 'Repeats every year';

  @override
  String get notSet => 'Not set';

  @override
  String get pickDate => 'Pick a date';

  @override
  String get pickTime => 'Pick a time';

  @override
  String get clear => 'Clear';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get confirmDeleteTitle => 'Delete?';

  @override
  String confirmDeletePerson(String name) {
    return 'Delete $name? Their links to events will be removed. This cannot be undone.';
  }

  @override
  String confirmDeleteEvent(String title) {
    return 'Delete “$title”? This cannot be undone.';
  }

  @override
  String get errorRequired => 'This field is required';

  @override
  String get errorInvalidEmail => 'Enter a valid email address';

  @override
  String get errorFutureBirthDate => 'Birth date can\'t be in the future';

  @override
  String get errorDateRequired => 'Please pick a date';

  @override
  String get savedSuccessfully => 'Saved';

  @override
  String get deletedSuccessfully => 'Deleted';

  @override
  String ageYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count years old',
      one: '1 year old',
      zero: 'Under 1 year',
    );
    return '$_temp0';
  }

  @override
  String ageBreakdown(int years, int months, int days) {
    return '$years y · $months m · $days d';
  }

  @override
  String totalDaysLived(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString days lived';
  }

  @override
  String turnsAge(int age) {
    return 'Turns $age';
  }

  @override
  String relativeDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'In $count days',
      one: 'Tomorrow',
      zero: 'Today',
    );
    return '$_temp0';
  }

  @override
  String birthdayOf(String name) {
    return '$name\'s birthday';
  }

  @override
  String get labelAge => 'Age';

  @override
  String get labelNextBirthday => 'Next birthday';

  @override
  String get labelContact => 'Contact';

  @override
  String get labelLinkedEvents => 'Linked events';

  @override
  String get noBirthDate => 'No birth date';

  @override
  String get noLinkedEvents => 'No linked events yet.';

  @override
  String get tabUpcoming => 'Upcoming';

  @override
  String get tabPast => 'Past';

  @override
  String get yearly => 'Yearly';

  @override
  String get calendarNoItems => 'Nothing on this day.';

  @override
  String get calendarToday => 'Today';

  @override
  String get previousMonth => 'Previous month';

  @override
  String get nextMonth => 'Next month';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsTheme => 'Appearance';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get settingsAccount => 'Account';

  @override
  String get guestAccountStatus => 'Guest — data is stored on this device only';

  @override
  String get moreModulesTitle => 'Coming modules';

  @override
  String get moduleCommitments => 'Commitments & renewals';

  @override
  String get moduleMemories => 'Memories & milestones';

  @override
  String get moduleTimeline => 'Timeline';

  @override
  String get moduleReports => 'Reports';

  @override
  String get moduleBackup => 'Backup & restore';

  @override
  String get settingsData => 'Data';

  @override
  String get resetData => 'Erase all data';

  @override
  String get resetDataConfirm =>
      'This permanently deletes all people and events on this device. Continue?';

  @override
  String get aboutTitle => 'About';

  @override
  String prototypeNotice(String version) {
    return 'Early prototype (v$version) for trying the experience. Data is stored locally on this device.';
  }

  @override
  String get categoryFamily => 'Family';

  @override
  String get categoryRelatives => 'Relatives';

  @override
  String get categoryFriends => 'Friends';

  @override
  String get categoryColleagues => 'Colleagues';

  @override
  String get categoryClients => 'Clients';

  @override
  String get categoryOther => 'Other';

  @override
  String get eventTypeAnniversary => 'Anniversary';

  @override
  String get eventTypeAppointment => 'Appointment';

  @override
  String get eventTypeTravel => 'Travel';

  @override
  String get eventTypeGraduation => 'Graduation';

  @override
  String get eventTypeAchievement => 'Achievement';

  @override
  String get eventTypeFamily => 'Family event';

  @override
  String get eventTypeReligious => 'Religious occasion';

  @override
  String get eventTypePersonal => 'Personal';

  @override
  String get eventTypeOther => 'Other';
}
