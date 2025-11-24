import '../models/task.dart';
import '../models/task_completion.dart';
import '../services/database_service.dart';

/// タスクリポジトリ
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

  /// タスクを完了/未完了にする（日付ごと）
  Future<void> toggleTaskCompletionOnDate(String taskId, DateTime date) async {
    final isCompleted = await _dbService.isTaskCompletedOnDate(taskId, date);

    if (isCompleted) {
      // 完了 → 未完了
      await _dbService.deleteDailyCompletion(taskId, date);
    } else {
      // 未完了 → 完了
      final completion = TaskCompletion(
        id: 'completion_${DateTime.now().millisecondsSinceEpoch}',
        taskId: taskId,
        completedDate: date,
        createdAt: DateTime.now(),
      );
      await _dbService.insertDailyCompletion(completion);

      // 履歴にも記録
      await _dbService.insertTaskHistory(taskId, DateTime.now());
    }
  }

  /// 指定日のタスクが完了しているか
  Future<bool> isTaskCompletedOnDate(String taskId, DateTime date) async {
    return await _dbService.isTaskCompletedOnDate(taskId, date);
  }

  /// 指定日の完了タスクIDリスト
  Future<List<String>> getCompletedTaskIdsOnDate(DateTime date) async {
    return await _dbService.getCompletedTaskIdsOnDate(date);
  }

  /// タスクの進捗を更新（非推奨 - 日次完了を使用）
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
    final today = DateTime.now();
    final completedIds = await _dbService.getCompletedTaskIdsOnDate(today);
    return completedIds.length;
  }

  /// 今週完了したタスク数を取得
  Future<int> getWeekCompletedCount() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    int count = 0;

    for (int i = 0; i < 7; i++) {
      final date =
          DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day + i);
      final completedIds = await _dbService.getCompletedTaskIdsOnDate(date);
      count += completedIds.length;
    }

    return count;
  }

  /// 連続達成日数を取得
  Future<int> getStreakDays() async {
    final today = DateTime.now();
    final allTasks = await getAllTasks();
    int streak = 0;

    for (int i = 0; i < 365; i++) {
      final date = today.subtract(Duration(days: i));
      final dateOnly = DateTime(date.year, date.month, date.day);

      // その日のタスク
      final tasksForDay = allTasks
          .where((task) => _isTaskVisibleOnDate(task, dateOnly))
          .toList();
      if (tasksForDay.isEmpty) continue;

      // その日の完了タスク
      final completedIds = await _dbService.getCompletedTaskIdsOnDate(dateOnly);

      // 全て完了しているか
      final allCompleted =
          tasksForDay.every((task) => completedIds.contains(task.id));

      if (!allCompleted) break;
      streak++;
    }

    return streak;
  }

  bool _isTaskVisibleOnDate(Task task, DateTime date) {
    final taskDate = task.createdAt;
    final taskDateOnly = DateTime(taskDate.year, taskDate.month, taskDate.day);

    if (date.isBefore(taskDateOnly)) return false;

    switch (task.repeatType) {
      case RepeatType.daily:
        return true;
      case RepeatType.weekly:
        return date.weekday == taskDate.weekday;
      case RepeatType.monthly:
        return date.day == taskDate.day;
      case RepeatType.none:
        return date.year == taskDate.year &&
            date.month == taskDate.month &&
            date.day == taskDate.day;
    }
  }
}
