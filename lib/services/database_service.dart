import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task.dart';
import '../models/task_category.dart';

/// データベースサービス
///
/// SQLiteを使ってデータを管理
class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();
  static Database? _database;

  DatabaseService._internal();

  /// データベースインスタンスの取得
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// データベースの初期化
  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'cleanup.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// データベースの作成
  Future<void> _onCreate(Database db, int version) async {
    // タスクテーブル
    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        category_id TEXT,
        is_completed INTEGER DEFAULT 0,
        completed_date TEXT,
        progress INTEGER DEFAULT 0,
        repeat_type TEXT NOT NULL,
        repeat_value TEXT,
        notification_time TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // カテゴリテーブル
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        icon TEXT,
        color TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // タスク履歴テーブル（将来の統計用）
    await db.execute('''
      CREATE TABLE task_history (
        id TEXT PRIMARY KEY,
        task_id TEXT NOT NULL,
        completed_date TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // デフォルトカテゴリを挿入
    for (final category in DefaultCategories.defaults) {
      await db.insert('categories', category.toMap());
    }
  }

  /// データベースのアップグレード
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // 将来のバージョンアップ時に使用
  }

  // ==================== タスク関連 ====================

  /// タスクを挿入
  Future<int> insertTask(Task task) async {
    final db = await database;
    return await db.insert(
      'tasks',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// すべてのタスクを取得
  Future<List<Task>> getTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  /// 今日のタスクを取得
  Future<List<Task>> getTodayTasks() async {
    final tasks = await getTasks();
    return tasks.where((task) => task.isToday()).toList();
  }

  /// IDでタスクを取得
  Future<Task?> getTaskById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return Task.fromMap(maps.first);
  }

  /// タスクを更新
  Future<int> updateTask(Task task) async {
    final db = await database;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  /// タスクを削除
  Future<int> deleteTask(String id) async {
    final db = await database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  /// 完了したタスクの数を取得
  Future<int> getCompletedTaskCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM tasks WHERE is_completed = 1',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ==================== カテゴリ関連 ====================

  /// カテゴリを挿入
  Future<int> insertCategory(TaskCategory category) async {
    final db = await database;
    return await db.insert(
      'categories',
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// すべてのカテゴリを取得
  Future<List<TaskCategory>> getCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      orderBy: 'created_at ASC',
    );

    return List.generate(maps.length, (i) => TaskCategory.fromMap(maps[i]));
  }

  /// IDでカテゴリを取得
  Future<TaskCategory?> getCategoryById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return TaskCategory.fromMap(maps.first);
  }

  /// カテゴリを更新
  Future<int> updateCategory(TaskCategory category) async {
    final db = await database;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  /// カテゴリを削除
  Future<int> deleteCategory(String id) async {
    final db = await database;
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== タスク履歴関連 ====================

  /// タスク履歴を挿入
  Future<int> insertTaskHistory(String taskId, DateTime completedDate) async {
    final db = await database;
    return await db.insert('task_history', {
      'id': '${taskId}_${completedDate.millisecondsSinceEpoch}',
      'task_id': taskId,
      'completed_date': completedDate.toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  /// 特定期間のタスク履歴を取得
  Future<List<Map<String, dynamic>>> getTaskHistory({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final db = await database;
    return await db.query(
      'task_history',
      where: 'completed_date BETWEEN ? AND ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'completed_date DESC',
    );
  }

  // ==================== データベース管理 ====================

  /// データベースを閉じる
  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  /// データベースをリセット（開発用）
  Future<void> reset() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'cleanup.db');
    await deleteDatabase(path);
    _database = null;
  }
}
