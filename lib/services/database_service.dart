import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task.dart';
import '../models/task_completion.dart';
import '../models/garbage_schedule.dart';

/// データベースサービス
class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();
  factory DatabaseService() => instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'owl_clean.db');

    return await openDatabase(
      path,
      version: 3, // バージョンを3に上げる
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // タスクテーブル
    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        category_id TEXT,
        is_completed INTEGER NOT NULL DEFAULT 0,
        completed_date TEXT,
        progress INTEGER NOT NULL DEFAULT 0,
        repeat_type TEXT NOT NULL,
        repeat_value TEXT,
        notification_time TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        end_date TEXT
      )
    ''');

    // タスク履歴テーブル
    await db.execute('''
      CREATE TABLE task_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        task_id TEXT NOT NULL,
        completed_at TEXT NOT NULL,
        FOREIGN KEY (task_id) REFERENCES tasks (id) ON DELETE CASCADE
      )
    ''');

    // タスク日次完了テーブル
    await db.execute('''
      CREATE TABLE task_daily_completions (
        id TEXT PRIMARY KEY,
        task_id TEXT NOT NULL,
        completed_date TEXT NOT NULL,
        created_at TEXT NOT NULL,
        UNIQUE(task_id, completed_date),
        FOREIGN KEY (task_id) REFERENCES tasks (id) ON DELETE CASCADE
      )
    ''');

    // ゴミ出しスケジュールテーブル
    await db.execute('''
      CREATE TABLE garbage_schedules (
        id TEXT PRIMARY KEY,
        garbage_type TEXT NOT NULL,
        day_of_week INTEGER NOT NULL,
        notification_time TEXT,
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // タスク日次完了テーブル
      await db.execute('''
        CREATE TABLE IF NOT EXISTS task_daily_completions (
          id TEXT PRIMARY KEY,
          task_id TEXT NOT NULL,
          completed_date TEXT NOT NULL,
          created_at TEXT NOT NULL,
          UNIQUE(task_id, completed_date),
          FOREIGN KEY (task_id) REFERENCES tasks (id) ON DELETE CASCADE
        )
      ''');

      // ゴミ出しスケジュールテーブル
      await db.execute('''
        CREATE TABLE IF NOT EXISTS garbage_schedules (
          id TEXT PRIMARY KEY,
          garbage_type TEXT NOT NULL,
          day_of_week INTEGER NOT NULL,
          notification_time TEXT,
          created_at TEXT NOT NULL
        )
      ''');
    }

    if (oldVersion < 3) {
      // end_dateカラムを追加
      await db.execute('ALTER TABLE tasks ADD COLUMN end_date TEXT');
    }
  }

  // ==================== タスク操作 ====================

  Future<void> insertTask(Task task) async {
    final db = await database;
    await db.insert('tasks', task.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Task>> getTasks() async {
    final db = await database;
    final maps = await db.query('tasks', orderBy: 'created_at DESC');
    return maps.map((map) => Task.fromMap(map)).toList();
  }

  Future<List<Task>> getTodayTasks() async {
    final tasks = await getTasks();
    return tasks.where((task) => task.isToday()).toList();
  }

  Future<Task?> getTaskById(String id) async {
    final db = await database;
    final maps = await db.query('tasks', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Task.fromMap(maps.first);
  }

  Future<void> updateTask(Task task) async {
    final db = await database;
    await db
        .update('tasks', task.toMap(), where: 'id = ?', whereArgs: [task.id]);
  }

  Future<void> deleteTask(String id) async {
    final db = await database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> getCompletedTaskCount() async {
    final db = await database;
    final result = await db
        .rawQuery('SELECT COUNT(*) as count FROM tasks WHERE is_completed = 1');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ==================== タスク履歴 ====================

  Future<void> insertTaskHistory(String taskId, DateTime completedAt) async {
    final db = await database;
    await db.insert('task_history', {
      'task_id': taskId,
      'completed_at': completedAt.toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getTaskHistory({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await database;
    String query = 'SELECT * FROM task_history';
    List<dynamic> whereArgs = [];

    if (startDate != null || endDate != null) {
      query += ' WHERE';
      if (startDate != null) {
        query += ' completed_at >= ?';
        whereArgs.add(startDate.toIso8601String());
      }
      if (endDate != null) {
        if (startDate != null) query += ' AND';
        query += ' completed_at < ?';
        whereArgs.add(endDate.toIso8601String());
      }
    }

    query += ' ORDER BY completed_at DESC';
    return await db.rawQuery(query, whereArgs.isEmpty ? null : whereArgs);
  }

  // ==================== 日次完了管理 ====================

  Future<void> insertDailyCompletion(TaskCompletion completion) async {
    final db = await database;
    await db.insert('task_daily_completions', completion.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteDailyCompletion(String taskId, DateTime date) async {
    final db = await database;
    final dateStr = date.toIso8601String().split('T')[0];
    await db.delete('task_daily_completions',
        where: 'task_id = ? AND completed_date = ?',
        whereArgs: [taskId, dateStr]);
  }

  Future<bool> isTaskCompletedOnDate(String taskId, DateTime date) async {
    final db = await database;
    final dateStr = date.toIso8601String().split('T')[0];
    final result = await db.query('task_daily_completions',
        where: 'task_id = ? AND completed_date = ?',
        whereArgs: [taskId, dateStr]);
    return result.isNotEmpty;
  }

  Future<List<String>> getCompletedTaskIdsOnDate(DateTime date) async {
    final db = await database;
    final dateStr = date.toIso8601String().split('T')[0];
    final result = await db.query('task_daily_completions',
        columns: ['task_id'],
        where: 'completed_date = ?',
        whereArgs: [dateStr]);
    return result.map((row) => row['task_id'] as String).toList();
  }

  Future<List<TaskCompletion>> getAllDailyCompletions() async {
    final db = await database;
    final maps = await db.query('task_daily_completions');
    return maps.map((map) => TaskCompletion.fromMap(map)).toList();
  }

  // ==================== ゴミ出しスケジュール ====================

  Future<void> insertGarbageSchedule(GarbageSchedule schedule) async {
    final db = await database;
    await db.insert('garbage_schedules', schedule.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<GarbageSchedule>> getGarbageSchedules() async {
    final db = await database;
    final maps =
        await db.query('garbage_schedules', orderBy: 'day_of_week ASC');
    return maps.map((map) => GarbageSchedule.fromMap(map)).toList();
  }

  Future<void> deleteGarbageSchedule(String id) async {
    final db = await database;
    await db.delete('garbage_schedules', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateGarbageSchedule(GarbageSchedule schedule) async {
    final db = await database;
    await db.update('garbage_schedules', schedule.toMap(),
        where: 'id = ?', whereArgs: [schedule.id]);
  }
}
