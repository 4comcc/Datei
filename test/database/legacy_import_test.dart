import 'dart:convert';

import 'package:datei/app/bootstrap.dart';
import 'package:datei/features/settings/settings_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers.dart';

void main() {
  final legacy = <String, Object>{
    'settings.language': 'ar',
    'settings.onboardingDone': true,
    'settings.themeMode': 'dark',
    'data.people': jsonEncode([
      {'id': 'p1', 'fullName': 'سارة', 'birthDate': '1996-11-24', 'categories': ['family', 'unknown'],
       'createdAt': '2026-01-01T00:00:00.000'},
    ]),
    'data.events': jsonEncode([
      {'id': 'e1', 'title': 'ذكرى', 'type': 'anniversary', 'date': '2018-11-19', 'repeatsYearly': true,
       'personIds': ['p1'], 'createdAt': '2026-01-01T00:00:00.000'},
    ]),
  };

  test('prototype data is imported once and old keys are removed', () async {
    SharedPreferences.setMockInitialValues(legacy);
    final prefs = await SharedPreferences.getInstance();
    final db = openTestDatabase();
    addTearDown(db.close);

    final boot = await bootstrap(db, prefs);
    expect(boot.settings[SettingKeys.language], 'ar');
    expect(boot.settings[SettingKeys.onboardingDone], 'true');
    expect(boot.settings[SettingKeys.themeMode], 'dark');

    final persons = await db.select(db.persons).get();
    expect(persons.single.fullName, 'سارة');
    expect(persons.single.birthDate, '1996-11-24');
    expect(await db.select(db.personCategoryRelations).get(), hasLength(1)); // unknown category dropped
    expect(await db.select(db.events).get(), hasLength(1));
    expect(await db.select(db.eventPersonRelations).get(), hasLength(1));
    expect(await db.select(db.recurrenceRules).get(), hasLength(1));

    expect(prefs.getKeys(), isEmpty);

    // Second launch: nothing to import, data unchanged.
    await bootstrap(db, prefs);
    expect(await db.select(db.persons).get(), hasLength(1));
    expect(await db.select(db.events).get(), hasLength(1));
  });

  test('corrupt legacy JSON does not block startup', () async {
    SharedPreferences.setMockInitialValues({'data.people': '{not json'});
    final prefs = await SharedPreferences.getInstance();
    final db = openTestDatabase();
    addTearDown(db.close);
    await bootstrap(db, prefs);
    expect(await db.select(db.persons).get(), isEmpty);
  });
}
