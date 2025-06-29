import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'habits.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE habits(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            habitName TEXT,
            totalDaysPerMonth INTEGER,
            plannedDays TEXT,
            isDone INTEGER,
            startDate TEXT,
            unplannedDays INTEGER
          )
        ''');
      },
    );
  }

  Future<int> insertHabit(Map<String, dynamic> habit) async {
    final db = await database;
    print(habit);
    return await db.insert('habits', habit,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updateHabit(int id, Map<String, dynamic> habit) async {
    final db = await database;
    return await db.update('habits', habit, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getHabits() async {
    final db = await database;
    return await db.query('habits');
  }

  Future<List<Map<String, dynamic>>> getHabitsByUser() async {
    final db = await database;
    return await db.query('habits');
  }

  Stream<List<Map<String, dynamic>>> watchHabitsByUser() async* {
    final db = await database;
    yield* Stream.periodic(Duration(seconds: 5), (_) async {
      return await db.query('habits');
    }).asyncMap((event) async => await event);
  }

  Future<int> deleteHabit(int id) async {
    final db = await database;
    return await db.delete('habits', where: 'id = ?', whereArgs: [id]);
  }
}
