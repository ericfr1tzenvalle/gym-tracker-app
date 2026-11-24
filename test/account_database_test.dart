import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker_app/repositories/account_database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  test('workouts and sessions are isolated by uid', () async {
    final accountA = await AccountDatabase.open('test-account-a');
    final accountB = await AccountDatabase.open('test-account-b');
    accountA.enqueue((db) async {
      await db.delete('sessions', where: 'uid = ?', whereArgs: [accountA.uid]);
      await db.delete('workouts', where: 'uid = ?', whereArgs: [accountA.uid]);
      await db.insert('workouts', {
        'uid': accountA.uid,
        'id': '1',
        'name': 'A',
      });
      await db.insert('sessions', {
        'uid': accountA.uid,
        'id': '1',
        'workout_id': '1',
        'workout_name': 'A',
        'started_at': DateTime.now().toIso8601String(),
        'status': 'active',
      });
    });
    await accountA.flush();
    expect(await accountB.rows('workouts'), isEmpty);
    expect(await accountB.rows('sessions'), isEmpty);
    expect((await accountA.rows('workouts')).single['name'], 'A');
    accountA.enqueue((db) async {
      await db.delete('sessions', where: 'uid = ?', whereArgs: [accountA.uid]);
      await db.delete('workouts', where: 'uid = ?', whereArgs: [accountA.uid]);
    });
    await accountA.close();
  });
}
