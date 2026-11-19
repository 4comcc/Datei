import 'package:datei/core/database/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('opens in memory and seeds system rows idempotently', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    expect(await db.select(db.personCategories).get(), hasLength(6));
    expect(await db.select(db.eventTypes).get(), hasLength(9));
  });
}
