import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../repositories/task_repository.dart';

/// カレンダーViewModel
class CalendarViewModel extends ChangeNotifier {
  final TaskRepository _repository = TaskRepository();

  List<Task> _tasks = [];
  Map<String, Set<String>> _dailyCompletions = {};
  bool _isLoading = false;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;

  /// 初期化
  Future<void> initialize() async {
    await loadTasks();
  }

  /// タスクを読み込み
  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();

    try {
      _tasks = await _repository.getAllTasks();
      notifyListeners();
    } catch (e) {
      debugPrint('タスクの読み込みに失敗: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 指定日のタスクを取得（完了状態を反映）
  Future<List<Task>> getTasksForDay(DateTime date) async {
    final dateKey = _getDateKey(date);

    // その日の完了状態を読み込み
    final completedIds = await _repository.getCompletedTaskIdsOnDate(date);
    _dailyCompletions[dateKey] = completedIds.toSet();

    // その日に表示されるべきタスクをフィルタリング
    return _tasks.where((task) {
      return _isTaskVisibleOnDate(task, date);
    }).map((task) {
      // 完了状態を反映した新しいTaskオブジェクトを返す
      return Task(
        id: task.id,
        title: task.title,
        categoryId: task.categoryId,
        isCompleted: completedIds.contains(task.id),
        completedDate: task.completedDate,
        progress: completedIds.contains(task.id) ? 100 : 0,
        repeatType: task.repeatType,
        repeatValue: task.repeatValue,
        notificationTime: task.notificationTime,
        createdAt: task.createdAt,
        updatedAt: task.updatedAt,
        endDate: task.endDate,
      );
    }).toList();
  }

  /// 指定日にタスクが表示されるべきかチェック
  bool _isTaskVisibleOnDate(Task task, DateTime date) {
    final taskDate = task.createdAt;
    final taskDateOnly = DateTime(taskDate.year, taskDate.month, taskDate.day);

    // タスク作成日より前の日付では表示しない
    if (date.isBefore(taskDateOnly)) return false;

    // 終了日チェック
    if (task.endDate != null) {
      final endDateOnly =
          DateTime(task.endDate!.year, task.endDate!.month, task.endDate!.day);
      if (date.isAfter(endDateOnly)) return false;
    }

    // 繰り返し設定に基づいて判定
    switch (task.repeatType) {
      case RepeatType.none:
        return date.year == taskDate.year &&
            date.month == taskDate.month &&
            date.day == taskDate.day;

      case RepeatType.daily:
        return true;

      case RepeatType.weekly:
        return date.weekday == taskDate.weekday;

      case RepeatType.biweekly:
        // 開始日から2週間ごとかチェック
        final daysDifference = date.difference(taskDateOnly).inDays;
        return daysDifference % 14 == 0;

      case RepeatType.monthly:
        return date.day == taskDate.day;
    }
  }

  /// 指定日にタスクがあるかチェック
  bool hasTasksOnDate(DateTime date) {
    return _tasks.any((task) => _isTaskVisibleOnDate(task, date));
  }

  /// 指定月のタスクがある日付を取得
  List<DateTime> getTaskDatesInMonth(int year, int month) {
    final datesWithTasks = <DateTime>[];
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);

    for (int day = 1; day <= lastDay.day; day++) {
      final date = DateTime(year, month, day);
      if (hasTasksOnDate(date)) {
        datesWithTasks.add(date);
      }
    }

    return datesWithTasks;
  }

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
