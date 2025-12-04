import '../models/task.dart';
import '../models/task_completion.dart'; // ⚠️ 追加
import '../services/database_service.dart';

/// タスクリポジトリ
///
/// タスクのCRUD操作とビジネスロジックを管理
class TaskRepository {
  final DatabaseService _dbService = DatabaseService();

  /// 全タスクを取得
  Future<List<Task>> getAllTasks() async {
    return await _dbService.getTasks();
  }

  /// 今日のタスクを取得
  Future<List<Task>> getTodayTasks() async {
    return await _dbService.getTodayTasks();
  }

  /// タスクを作成
  Future<Task> createTask({
    required String title,
    String? categoryId,
    RepeatType repeatType = RepeatType.none,
    String? repeatValue,
    DateTime? notificationTime,
    DateTime? createdAt,
    DateTime? endDate,
  }) async {
    final now = DateTime.now();
    final task = Task(
      id: 'task_${now.millisecondsSinceEpoch}',
      title: title,
      categoryId: categoryId,
      repeatType: repeatType,
      repeatValue: repeatValue,
      notificationTime: notificationTime,
      createdAt: createdAt ?? now,
      updatedAt: now,
      endDate: endDate,
    );

    await _dbService.insertTask(task);
    return task;
  }

  /// タスクを更新
  Future<void> updateTask(Task task) async {
    await _dbService.updateTask(task);
  }

  /// タスクを削除
  Future<void> deleteTask(String id) async {
    await _dbService.deleteTask(id);
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

  /// 指定日の完了済みタスクIDを取得
  Future<List<String>> getCompletedTaskIdsOnDate(DateTime date) async {
    return await _dbService.getCompletedTaskIdsOnDate(date);
  }

  /// 指定日のタスク完了状態をトグル
  Future<void> toggleTaskCompletionOnDate(String taskId, DateTime date) async {
    final isCompleted = await _dbService.isTaskCompletedOnDate(taskId, date);

    if (isCompleted) {
      await _dbService.deleteDailyCompletion(taskId, date);
    } else {
      final completion = TaskCompletion(
        id: 'completion_${DateTime.now().millisecondsSinceEpoch}',
        taskId: taskId,
        completedDate: date,
        createdAt: DateTime.now(),
      );
      await _dbService.insertDailyCompletion(completion);
    }
  }

  /// 今日完了したタスクの数を取得
  Future<int> getTodayCompletedCount() async {
    final today = DateTime.now();
    final completedIds = await getCompletedTaskIdsOnDate(today);
    return completedIds.length;
  }

  /// 今週完了したタスクの数を取得
  Future<int> getWeekCompletedCount() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    int count = 0;

    for (int i = 0; i < 7; i++) {
      final date = startOfWeek.add(Duration(days: i));
      final completedIds = await getCompletedTaskIdsOnDate(date);
      count += completedIds.length;
    }

    return count;
  }

  /// 連続完了日数を取得
  Future<int> getStreakDays() async {
    int streak = 0;
    final today = DateTime.now();

    for (int i = 0; i < 365; i++) {
      final date = today.subtract(Duration(days: i));
      final completedIds = await getCompletedTaskIdsOnDate(date);

      if (completedIds.isEmpty) {
        break;
      }
      streak++;
    }

    return streak;
  }

  /// タスクが指定日に表示されるべきかチェック
  bool _isTaskVisibleOnDate(Task task, DateTime date) {
    final taskDate = task.createdAt;
    final taskDateOnly = DateTime(taskDate.year, taskDate.month, taskDate.day);

    if (date.isBefore(taskDateOnly)) return false;

    // 終了日チェック
    if (task.endDate != null) {
      final endDateOnly =
          DateTime(task.endDate!.year, task.endDate!.month, task.endDate!.day);
      if (date.isAfter(endDateOnly)) return false;
    }

    switch (task.repeatType) {
      case RepeatType.daily:
        return true;
      case RepeatType.weekly:
        return date.weekday == taskDate.weekday;
      case RepeatType.biweekly:
        final daysDifference = date.difference(taskDateOnly).inDays;
        return daysDifference % 14 == 0;
      case RepeatType.monthly:
        return date.day == taskDate.day;
      case RepeatType.none:
        return date.year == taskDate.year &&
            date.month == taskDate.month &&
            date.day == taskDate.day;
    }
  }
}
