import '../models/task.dart';
import '../services/database_service.dart';

/// タスクリポジトリ
///
/// タスクのデータアクセスを抽象化
class TaskRepository {
  final DatabaseService _dbService = DatabaseService.instance;

  /// タスクを作成
  Future<Task> createTask({
    required String title,
    String? categoryId,
    RepeatType repeatType = RepeatType.none,
    String? repeatValue,
    DateTime? notificationTime,
  }) async {
    final now = DateTime.now();
    final task = Task(
      id: 'task_${now.millisecondsSinceEpoch}',
      title: title,
      categoryId: categoryId,
      repeatType: repeatType,
      repeatValue: repeatValue,
      notificationTime: notificationTime,
      createdAt: now,
      updatedAt: now,
    );

    await _dbService.insertTask(task);
    return task;
  }

  /// すべてのタスクを取得
  Future<List<Task>> getAllTasks() async {
    return await _dbService.getTasks();
  }

  /// 今日のタスクを取得
  Future<List<Task>> getTodayTasks() async {
    return await _dbService.getTodayTasks();
  }

  /// タスクを取得
  Future<Task?> getTask(String id) async {
    return await _dbService.getTaskById(id);
  }

  /// タスクを更新
  Future<void> updateTask(Task task) async {
    final updatedTask = task.copyWith(updatedAt: DateTime.now());
    await _dbService.updateTask(updatedTask);
  }

  /// タスクを削除
  Future<void> deleteTask(String id) async {
    await _dbService.deleteTask(id);
  }

  /// タスクを完了/未完了にする
  Future<Task> toggleTaskCompletion(Task task) async {
    final now = DateTime.now();
    final updatedTask = task.copyWith(
      isCompleted: !task.isCompleted,
      completedDate: !task.isCompleted ? now : null,
      progress: !task.isCompleted ? 100 : task.progress,
      updatedAt: now,
    );

    await _dbService.updateTask(updatedTask);

    // 履歴に記録
    if (updatedTask.isCompleted) {
      await _dbService.insertTaskHistory(updatedTask.id, now);
    }

    return updatedTask;
  }

  /// タスクの進捗を更新
  Future<Task> updateTaskProgress(Task task, int progress) async {
    final updatedTask = task.copyWith(
      progress: progress,
      updatedAt: DateTime.now(),
    );

    await _dbService.updateTask(updatedTask);
    return updatedTask;
  }

  /// 完了したタスク数を取得
  Future<int> getCompletedCount() async {
    return await _dbService.getCompletedTaskCount();
  }

  /// 今日完了したタスク数を取得
  Future<int> getTodayCompletedCount() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final history = await _dbService.getTaskHistory(
      startDate: startOfDay,
      endDate: endOfDay,
    );

    return history.length;
  }

  /// 今週完了したタスク数を取得
  Future<int> getWeekCompletedCount() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeekDay = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
    );
    final endOfWeek = startOfWeekDay.add(const Duration(days: 7));

    final history = await _dbService.getTaskHistory(
      startDate: startOfWeekDay,
      endDate: endOfWeek,
    );

    return history.length;
  }

  /// 連続達成日数を取得（簡易版）
  Future<int> getStreakDays() async {
    // TODO: 実装を詳細化（連続して毎日タスクを完了した日数を計算）
    return 5; // 仮の値
  }
}
