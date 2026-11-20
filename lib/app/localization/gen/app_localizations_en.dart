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

  @override
  String get startupErrorTitle => 'Datei couldn\'t start';

  @override
  String get startupErrorBody =>
      'Something went wrong while opening your data on this device. Your data has not been deleted. Try again, and if it keeps happening, send the details below to the developer.';

  @override
  String get startupTimeout => 'Opening the database took too long.';

  @override
  String get retry => 'Try again';

  @override
  String get copyDetails => 'Copy details';

  @override
  String get copied => 'Copied';

  @override
  String get fieldGender => 'Gender (optional)';

  @override
  String get genderUnspecified => 'Not specified';

  @override
  String get genderMale => 'Male';

  @override
  String get genderFemale => 'Female';

  @override
  String get fieldAddress => 'Address';

  @override
  String get fieldOrganization => 'Workplace';

  @override
  String get birthYearUnknown => 'I don\'t know the year';

  @override
  String get birthYearUnknownHint =>
      'Only the day and month will be used. Age won\'t be shown.';

  @override
  String get manageCategories => 'Categories';

  @override
  String get addCategory => 'New category';

  @override
  String get categoryName => 'Category name';

  @override
  String get editCategory => 'Edit category';

  @override
  String deleteCategoryConfirm(String name) {
    return 'Delete the category “$name”? People in it are kept; only the category is removed.';
  }

  @override
  String get systemCategoriesNote =>
      'Built-in categories can\'t be renamed or deleted.';

  @override
  String get yourCategories => 'Your categories';

  @override
  String get builtInCategories => 'Built-in';

  @override
  String get noCustomCategories => 'You haven\'t created any categories yet.';

  @override
  String get sectionRelationships => 'Relationships';

  @override
  String get addRelationship => 'Add relationship';

  @override
  String relationshipIs(String name) {
    return '$name is…';
  }

  @override
  String get relationshipOf => '…of';

  @override
  String get relatedToMe => 'Me';

  @override
  String get customRelationshipLabel => 'Relationship name';

  @override
  String get noRelationships => 'No relationships yet.';

  @override
  String relationOfPerson(String relation, String name) {
    return '$relation of $name';
  }

  @override
  String relationOfMe(String relation) {
    return '$relation (to you)';
  }

  @override
  String get relationFather => 'Father';

  @override
  String get relationMother => 'Mother';

  @override
  String get relationSon => 'Son';

  @override
  String get relationDaughter => 'Daughter';

  @override
  String get relationBrother => 'Brother';

  @override
  String get relationSister => 'Sister';

  @override
  String get relationSpouse => 'Spouse';

  @override
  String get relationRelative => 'Relative';

  @override
  String get relationFriend => 'Friend';

  @override
  String get relationColleague => 'Colleague';

  @override
  String get relationCustom => 'Other…';

  @override
  String get removeRelationship => 'Remove relationship';

  @override
  String get errorChoosePerson => 'Choose a person';

  @override
  String get customFieldsTitle => 'Custom fields';

  @override
  String get customFieldsHint =>
      'Add your own fields to every person, such as blood type or ID number.';

  @override
  String get addCustomField => 'New field';

  @override
  String get editCustomField => 'Edit field';

  @override
  String get customFieldLabel => 'Field name';

  @override
  String get customFieldType => 'Field type';

  @override
  String get fieldTypeText => 'Text';

  @override
  String get fieldTypeNumber => 'Number';

  @override
  String get fieldTypeDate => 'Date';

  @override
  String get fieldTypeUrl => 'Link';

  @override
  String get noCustomFields => 'No custom fields yet.';

  @override
  String deleteCustomFieldConfirm(String label) {
    return 'Delete the field “$label”? Its values will be removed from everyone.';
  }

  @override
  String get ageOnDate => 'Age on a date';

  @override
  String get notBornYet => 'Not born yet on this date.';

  @override
  String untilBirthday(int months, int days) {
    return '$months months and $days days to go';
  }

  @override
  String get filters => 'Filters';

  @override
  String filtersActive(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count filters',
      one: '1 filter',
      zero: 'Filters',
    );
    return '$_temp0';
  }

  @override
  String get clearFilters => 'Clear all';

  @override
  String get showResults => 'Show results';

  @override
  String get ageRange => 'Age range';

  @override
  String get minAge => 'From';

  @override
  String get maxAge => 'To';

  @override
  String get birthMonth => 'Birth month';

  @override
  String get birthDayOfMonth => 'Birth day';

  @override
  String get birthYear => 'Birth year';

  @override
  String get anyValue => 'Any';

  @override
  String get birthDateFilter => 'Birth date';

  @override
  String get withBirthDate => 'Has a birth date';

  @override
  String get withoutBirthDate => 'No birth date';

  @override
  String get birthdayWithin => 'Birthday within';

  @override
  String withinDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get relationshipFilter => 'Has relationship';

  @override
  String get saveFilter => 'Save filter';

  @override
  String get filterName => 'Filter name';

  @override
  String get filterSaved => 'Filter saved';

  @override
  String deleteSavedFilterConfirm(String name) {
    return 'Delete the saved filter “$name”?';
  }

  @override
  String get errorInvalidNumber => 'Enter a valid number';

  @override
  String get errorInvalidUrl =>
      'Enter a valid link starting with http:// or https://';

  @override
  String get errorAgeRange => '“From” must not be greater than “To”';

  @override
  String resultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count people',
      one: '1 person',
      zero: 'No people',
    );
    return '$_temp0';
  }

  @override
  String get add => 'Add';

  @override
  String get repeat => 'Repeat';

  @override
  String get repeatNone => 'Does not repeat';

  @override
  String get repeatDaily => 'Daily';

  @override
  String get repeatWeekly => 'Weekly';

  @override
  String get repeatMonthly => 'Monthly';

  @override
  String get repeatYearly => 'Yearly';

  @override
  String get everyLabel => 'Every';

  @override
  String unitDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'days',
      one: 'day',
    );
    return '$_temp0';
  }

  @override
  String unitWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'weeks',
      one: 'week',
    );
    return '$_temp0';
  }

  @override
  String unitMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'months',
      one: 'month',
    );
    return '$_temp0';
  }

  @override
  String unitYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'years',
      one: 'year',
    );
    return '$_temp0';
  }

  @override
  String everyN(int count, String unit) {
    return 'Every $count $unit';
  }

  @override
  String get onWeekdays => 'On';

  @override
  String monthlyOnDay(int day) {
    return 'On day $day';
  }

  @override
  String monthlyOnNth(String position, String weekday) {
    return 'On the $position $weekday';
  }

  @override
  String get posFirst => 'first';

  @override
  String get posSecond => 'second';

  @override
  String get posThird => 'third';

  @override
  String get posFourth => 'fourth';

  @override
  String get posLast => 'last';

  @override
  String get skipShortMonths => 'Skip months without this day';

  @override
  String get ends => 'Ends';

  @override
  String get endsNever => 'Never';

  @override
  String get endsOnDate => 'On a date';

  @override
  String get endsAfter => 'After';

  @override
  String occurrencesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count times',
      one: '1 time',
    );
    return '$_temp0';
  }

  @override
  String untilDate(String date) {
    return 'until $date';
  }

  @override
  String get fieldEndDate => 'End date (optional)';

  @override
  String get fieldEndTime => 'End time (optional)';

  @override
  String get fieldPriority => 'Priority';

  @override
  String get priorityLow => 'Low';

  @override
  String get priorityNormal => 'Normal';

  @override
  String get priorityHigh => 'High';

  @override
  String get priorityCritical => 'Critical';

  @override
  String get fieldStatus => 'Status';

  @override
  String get statusPlanned => 'Planned';

  @override
  String get statusDone => 'Done';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get errorEndBeforeStart => 'End can\'t be before the start';

  @override
  String get errorInterval => 'Enter a number from 1 to 999';

  @override
  String get errorWeekdays => 'Choose at least one day';

  @override
  String get hijriInput => 'Enter a Hijri date';

  @override
  String get hijriDay => 'Day';

  @override
  String get hijriMonth => 'Month';

  @override
  String get hijriYear => 'Year';

  @override
  String get hijriInvalid =>
      'This Hijri date isn\'t valid or is outside 1356–1500 AH';

  @override
  String hijriConverted(String date) {
    return 'Gregorian: $date';
  }

  @override
  String hijriFormat(int day, String month, int year) {
    return '$day $month $year AH';
  }

  @override
  String get hijriMonth1 => 'Muharram';

  @override
  String get hijriMonth2 => 'Safar';

  @override
  String get hijriMonth3 => 'Rabi al-Awwal';

  @override
  String get hijriMonth4 => 'Rabi al-Thani';

  @override
  String get hijriMonth5 => 'Jumada al-Ula';

  @override
  String get hijriMonth6 => 'Jumada al-Akhirah';

  @override
  String get hijriMonth7 => 'Rajab';

  @override
  String get hijriMonth8 => 'Shaban';

  @override
  String get hijriMonth9 => 'Ramadan';

  @override
  String get hijriMonth10 => 'Shawwal';

  @override
  String get hijriMonth11 => 'Dhu al-Qadah';

  @override
  String get hijriMonth12 => 'Dhu al-Hijjah';

  @override
  String get editScopeTitle => 'Edit recurring event';

  @override
  String get deleteScopeTitle => 'Delete recurring event';

  @override
  String get scopeThis => 'This event only';

  @override
  String get scopeFollowing => 'This and following events';

  @override
  String get scopeAll => 'All events in the series';

  @override
  String occurrenceOf(String date) {
    return 'Occurrence on $date';
  }

  @override
  String get manageEventTypes => 'Event types';

  @override
  String get addEventType => 'New type';

  @override
  String get editEventType => 'Edit type';

  @override
  String get eventTypeName => 'Type name';

  @override
  String deleteEventTypeConfirm(String name) {
    return 'Delete the type “$name”? Its events will move to “Other”.';
  }

  @override
  String get yourEventTypes => 'Your types';

  @override
  String get noCustomEventTypes => 'You haven\'t created any event types yet.';

  @override
  String get systemEventTypesNote =>
      'Built-in types can\'t be renamed or deleted.';

  @override
  String get viewMonth => 'Month';

  @override
  String get viewWeek => 'Week';

  @override
  String get viewDay => 'Day';

  @override
  String get goToDate => 'Go to date';

  @override
  String get calendarFilter => 'Show in calendar';

  @override
  String get birthdaysLabel => 'Birthdays';

  @override
  String get searchCalendar => 'Search calendar';

  @override
  String get searchCalendarHint => 'Search events and birthdays…';

  @override
  String get searchCalendarScope =>
      'Showing matches from a year ago to a year ahead';

  @override
  String get allDay => 'All day';

  @override
  String get previousPeriod => 'Previous';

  @override
  String get nextPeriod => 'Next';

  @override
  String get settingsCalendar => 'Calendar';

  @override
  String get showHijri => 'Show Hijri dates';

  @override
  String get hijriAdjustment => 'Hijri adjustment';

  @override
  String get hijriNote =>
      'Calculated with the Umm al-Qura calendar. Local moon sighting can differ by a day or two — adjust if needed. Gregorian dates are never changed.';

  @override
  String get repeatsLabel => 'Repeats';

  @override
  String get hijriAdjustmentNone => 'No adjustment';

  @override
  String hijriAdjustmentDays(String value) {
    return '$value day(s)';
  }

  @override
  String unitTimes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'times',
      one: 'time',
    );
    return '$_temp0';
  }

  @override
  String get commitmentTypeDomain => 'Domain';

  @override
  String get commitmentTypeHosting => 'Hosting';

  @override
  String get commitmentTypeSsl => 'SSL certificate';

  @override
  String get commitmentTypeContract => 'Contract';

  @override
  String get commitmentTypeLicense => 'License';

  @override
  String get commitmentTypeInsurance => 'Insurance';

  @override
  String get commitmentTypeWarranty => 'Warranty';

  @override
  String get commitmentTypeSubscription => 'Subscription';

  @override
  String get commitmentTypeBill => 'Bill';

  @override
  String get commitmentTypePayment => 'Payment';

  @override
  String get commitmentTypeInstallment => 'Installment';

  @override
  String get commitmentTypePassport => 'Passport';

  @override
  String get commitmentTypeNationalId => 'ID card';

  @override
  String get commitmentTypeVehicleLicense => 'Vehicle license';

  @override
  String get commitmentTypeOther => 'Other';

  @override
  String get cstatusActive => 'Active';

  @override
  String get cstatusUpcoming => 'Upcoming';

  @override
  String get cstatusDueSoon => 'Due soon';

  @override
  String get cstatusOverdue => 'Overdue';

  @override
  String get cstatusCompleted => 'Completed';

  @override
  String get cstatusCancelled => 'Cancelled';

  @override
  String get commitments => 'Commitments & renewals';

  @override
  String get commitmentsEmptyTitle => 'No commitments yet';

  @override
  String get commitmentsEmptyBody =>
      'Track renewals like domains, subscriptions, insurance, passports and IDs — Datei reminds you before they\'re due.';

  @override
  String get editCommitment => 'Edit commitment';

  @override
  String get fieldName => 'Name';

  @override
  String get fieldCommitmentType => 'Type';

  @override
  String get fieldProvider => 'Provider or company';

  @override
  String get fieldStartDate => 'Start date (optional)';

  @override
  String get fieldExpiryDate => 'Expiry or due date';

  @override
  String get fieldRenewalDate => 'Renew by (optional)';

  @override
  String get fieldAmount => 'Amount (optional)';

  @override
  String get fieldCurrency => 'Currency';

  @override
  String get fieldRenewalPeriod => 'Renewal period';

  @override
  String get periodNone => 'No fixed period';

  @override
  String get fieldReference => 'Reference number (optional)';

  @override
  String get fieldServiceUrl => 'Service link (optional)';

  @override
  String get fieldLifecycle => 'Status';

  @override
  String get remindersLabel => 'Reminders';

  @override
  String reminderDaysBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days before',
      one: '1 day before',
      zero: 'On the day',
    );
    return '$_temp0';
  }

  @override
  String get addCustomReminder => 'Custom…';

  @override
  String get customReminderDays => 'Days before';

  @override
  String get renew => 'Renew';

  @override
  String get renewTitle => 'Renew';

  @override
  String get newExpiryDate => 'New expiry date';

  @override
  String get renewalHistory => 'Renewal history';

  @override
  String get noRenewals => 'No renewals recorded yet.';

  @override
  String renewalFromTo(String from, String to) {
    return '$from → $to';
  }

  @override
  String renewedOn(String date) {
    return 'Renewed on $date';
  }

  @override
  String get renewedSuccessfully => 'Renewed';

  @override
  String get errorRenewDate => 'Choose a date after the current expiry';

  @override
  String get errorExpiryBeforeStart => 'Expiry can\'t be before the start date';

  @override
  String get errorInvalidAmount => 'Enter an amount like 250 or 99.50';

  @override
  String confirmDeleteCommitment(String name) {
    return 'Delete “$name” and its renewal history?';
  }

  @override
  String overdueBy(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Overdue by $count days',
      one: 'Overdue by 1 day',
    );
    return '$_temp0';
  }

  @override
  String get filterAllCommitments => 'All';

  @override
  String get sectionReminders => 'Important reminders';

  @override
  String get emptyReminders => 'Nothing due in the next 30 days.';

  @override
  String todaySummaryOverdue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count overdue',
      one: '1 overdue',
    );
    return '$_temp0';
  }

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get enableReminders => 'Reminders';

  @override
  String get enableRemindersHint =>
      'Get notified before birthdays, events and renewals.';

  @override
  String get remindersPermissionDenied =>
      'Notifications are blocked for Datei. Allow them in Android settings to get reminders.';

  @override
  String get defaultReminderTime => 'Reminder time for all-day items';

  @override
  String get birthdayReminders => 'Birthday reminders';

  @override
  String get reminderOff => 'Off';

  @override
  String get preciseReminders => 'Precise timing';

  @override
  String get preciseRemindersHint =>
      'Reminders arrive on the exact minute. Without it, Android may delay them a little to save battery.';

  @override
  String get testNotification => 'Send a test notification';

  @override
  String get testNotificationBody => 'Notifications are working.';

  @override
  String get remindersOffBanner =>
      'Reminders are off, so you won\'t be notified before due dates.';

  @override
  String get turnOn => 'Turn on';

  @override
  String notifBirthdayTitle(String name) {
    return '$name\'s birthday';
  }

  @override
  String notifBirthdayTurning(String name, int age) {
    return '$name turns $age';
  }

  @override
  String notifCommitmentTitle(String name) {
    return '$name is due';
  }

  @override
  String notifWhen(String relative, String date) {
    return '$relative · $date';
  }

  @override
  String get fieldReminders => 'Reminders';

  @override
  String get reminderAtTime => 'At the time';

  @override
  String reminderMinutesBefore(int count) {
    return '$count min before';
  }

  @override
  String reminderHoursBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours before',
      one: '1 hour before',
    );
    return '$_temp0';
  }

  @override
  String get commitmentsLabel => 'Renewals & commitments';

  @override
  String get addReminder => 'Add';
}
