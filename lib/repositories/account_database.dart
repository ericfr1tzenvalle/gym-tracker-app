import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class AccountDatabase {
  AccountDatabase(this.uid, this.db);
  final String uid;
  final Database db;
  Future<void> _pending = Future.value();

  static Future<AccountDatabase> open(String uid) async {
    final db = await openDatabase(
      path.join(await getDatabasesPath(), 'lilgym.db'),
      version: 2,
      onCreate: (db, _) async {
        await db.execute(
          'CREATE TABLE workouts (uid TEXT NOT NULL, id TEXT NOT NULL, name TEXT NOT NULL, PRIMARY KEY(uid,id))',
        );
        await db.execute(
          'CREATE TABLE planned_exercises (uid TEXT NOT NULL, workout_id TEXT NOT NULL, exercise_id TEXT NOT NULL, position INTEGER NOT NULL, planned_sets INTEGER NOT NULL, planned_repetitions INTEGER NOT NULL, planned_min INTEGER NOT NULL, PRIMARY KEY(uid,workout_id,exercise_id))',
        );
        await db.execute(
          'CREATE TABLE sessions (uid TEXT NOT NULL, id TEXT NOT NULL, workout_id TEXT NOT NULL, workout_name TEXT NOT NULL, started_at TEXT NOT NULL, completed_at TEXT, status TEXT NOT NULL, PRIMARY KEY(uid,id))',
        );
        await db.execute(
          'CREATE TABLE recorded_sets (uid TEXT NOT NULL, session_id TEXT NOT NULL, id TEXT NOT NULL, exercise_id TEXT NOT NULL, exercise_name TEXT NOT NULL, weight REAL NOT NULL, repetitions INTEGER NOT NULL, rpe INTEGER, PRIMARY KEY(uid,session_id,id))',
        );
        await db.execute(
          "CREATE UNIQUE INDEX one_active_session_per_account ON sessions(uid) WHERE status = 'active'",
        );
      },
      onUpgrade: (db, oldVersion, _) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE planned_exercises ADD COLUMN planned_min INTEGER NOT NULL DEFAULT 1',
          );
        }
      },
    );
    return AccountDatabase(uid, db);
  }

  Future<List<Map<String, Object?>>> rows(String table) =>
      db.query(table, where: 'uid = ?', whereArgs: [uid]);

  void enqueue(Future<void> Function(DatabaseExecutor db) action) {
    _pending = _pending.then((_) => db.transaction((txn) => action(txn)));
  }

  Future<void> flush() => _pending;
  Future<void> close() async {
    await flush();
    await db.close();
  }
}
