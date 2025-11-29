import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../repositories/task_repository.dart';

/// タスクViewModel
///
/// タスク関連のビジネスロジックと状態管理
class TaskViewModel extends ChangeNotifier {
  final TaskRepository _repository = TaskRepository();

  List<Task> _tasks = [];
  Map<String, Set<String>> _dailyCompletions = {}; // 日付 -> 完了タスクIDセット
  bool _isLoading = false;
  String? _error;

  // 統計情報
  int _todayCompletedCount = 0;
  int _weekCompletedCount = 0;
  int _streakDays = 0;

  // Getters
  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get todayCompletedCount => _todayCompletedCount;
  int get weekCompletedCount => _weekCompletedCount;
  int get streakDays => _streakDays;
  int get totalCompletedCount => _todayCompletedCount; // 今日の完了数

  /// 今日のタスク（日付ごとの完了状態を反映）
  List<Task> get todayTasks {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final todayStr = _getDateKey(todayOnly);
    final completedTaskIds = _dailyCompletions[todayStr] ?? {};

    return _tasks.where((task) {
      // 今日表示されるべきタスクかチェック
      return _isTaskVisibleOnDate(task, todayOnly);
    }).map((task) {
      // 今日の完了状態を反映
      return Task(
        id: task.id,
        title: task.title,
        categoryId: task.categoryId,
        isCompleted: completedTaskIds.contains(task.id),
        completedDate: task.completedDate,
        progress: completedTaskIds.contains(task.id) ? 100 : 0,
        repeatType: task.repeatType,
        repeatValue: task.repeatValue,
        notificationTime: task.notificationTime,
        createdAt: task.createdAt,
        updatedAt: task.updatedAt,
      );
    }).toList();
  }

  /// タスクが指定日に表示されるべきかチェック
  bool _isTaskVisibleOnDate(Task task, DateTime date) {
    final taskDate = task.createdAt;
    final taskDateOnly = DateTime(taskDate.year, taskDate.month, taskDate.day);

    // タスク作成日より前の日付には表示しない
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

  /// 初期化
  Future<void> initialize() async {
    await loadTasks();
    await _loadDailyCompletions();
    await loadStats();
  }

  /// タスクを読み込み
  Future<void> loadTasks() async {
    _setLoading(true);
    _error = null;

    try {
      _tasks = await _repository.getAllTasks();
      notifyListeners();
    } catch (e) {
      _error = 'タスクの読み込みに失敗しました: $e';
      debugPrint(_error);
    } finally {
      _setLoading(false);
    }
  }

  /// 日次完了状態を読み込み
  Future<void> _loadDailyCompletions() async {
    try {
      final today = DateTime.now();
      final todayKey = _getDateKey(today);
      final completedIds = await _repository.getCompletedTaskIdsOnDate(today);
      _dailyCompletions[todayKey] = completedIds.toSet();
      notifyListeners();
    } catch (e) {
      debugPrint('日次完了状態の読み込みに失敗しました: $e');
    }
  }

  /// 統計情報を読み込み
  Future<void> loadStats() async {
    try {
      _todayCompletedCount = await _repository.getTodayCompletedCount();
      _weekCompletedCount = await _repository.getWeekCompletedCount();
      _streakDays = await _repository.getStreakDays();
      notifyListeners();
    } catch (e) {
      debugPrint('統計情報の読み込みに失敗しました: $e');
    }
  }

  /// タスクを追加
  Future<void> addTask({
    required String title,
    String? categoryId,
    RepeatType repeatType = RepeatType.none,
    String? repeatValue,
    DateTime? notificationTime,
    DateTime? createdAt,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final task = await _repository.createTask(
        title: title,
        categoryId: categoryId,
        repeatType: repeatType,
        repeatValue: repeatValue,
        notificationTime: notificationTime,
        createdAt: createdAt,
      );

      _tasks.insert(0, task);
      notifyListeners();
    } catch (e) {
      _error = 'タスクの追加に失敗しました: $e';
      debugPrint(_error);
    } finally {
      _setLoading(false);
    }
  }

  /// タスクを更新
  Future<void> updateTask(Task task) async {
    _error = null;

    try {
      await _repository.updateTask(task);
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = task;
        notifyListeners();
      }
    } catch (e) {
      _error = 'タスクの更新に失敗しました: $e';
      debugPrint(_error);
    }
  }

  /// タスクを削除
  Future<void> deleteTask(String id) async {
    _error = null;

    try {
      await _repository.deleteTask(id);
      _tasks.removeWhere((task) => task.id == id);
      await loadStats();
      notifyListeners();
    } catch (e) {
      _error = 'タスクの削除に失敗しました: $e';
      debugPrint(_error);
    }
  }

  /// タスクを完了/未完了にする（日次）
  Future<void> toggleTaskCompletion(String id, [DateTime? date]) async {
    _error = null;
    final targetDate = date ?? DateTime.now();
    final dateKey = _getDateKey(targetDate);

    try {
      await _repository.toggleTaskCompletionOnDate(id, targetDate);

      // ローカル状態を更新
      _dailyCompletions[dateKey] ??= {};
      if (_dailyCompletions[dateKey]!.contains(id)) {
        _dailyCompletions[dateKey]!.remove(id);
      } else {
        _dailyCompletions[dateKey]!.add(id);
      }

      await loadStats();
      notifyListeners();
    } catch (e) {
      _error = 'タスクの完了状態の変更に失敗しました: $e';
      debugPrint(_error);
    }
  }

  /// 指定日のタスクが完了しているか
  bool isTaskCompletedOnDate(String taskId, DateTime date) {
    final dateKey = _getDateKey(date);
    return _dailyCompletions[dateKey]?.contains(taskId) ?? false;
  }

  /// タスクの進捗を更新
  Future<void> updateProgress(String id, int progress) async {
    _error = null;

    try {
      final taskIndex = _tasks.indexWhere((t) => t.id == id);
      if (taskIndex == -1) return;

      final task = _tasks[taskIndex];
      final updatedTask = await _repository.updateTaskProgress(task, progress);

      _tasks[taskIndex] = updatedTask;
      notifyListeners();
    } catch (e) {
      _error = 'タスクの進捗の更新に失敗しました: $e';
      debugPrint(_error);
    }
  }

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// ローディング状態を設定
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
