import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../repositories/task_repository.dart';

class CalendarViewModel extends ChangeNotifier {
  final TaskRepository _repository = TaskRepository();

  List<Task> _tasks = [];
  Map<String, Set<String>> _dailyCompletions = {}; // 日付 -> 完了タスクIDセット
  DateTime? _selectedDate;
  bool _isLoading = false;
  String? _error;

  List<Task> get tasks => _tasks;
  DateTime? get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 初期化
  Future<void> initialize() async {
    await loadTasks();
  }

  /// タスク一覧を読み込み
  Future<void> loadTasks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tasks = await _repository.getAllTasks(); // ⚠️ getTasks() → getAllTasks()

      // 今日の日次完了状態を読み込む
      final today = DateTime.now();
      await _loadDailyCompletionsForDate(today);

      _error = null;
    } catch (e) {
      _error = 'タスクの読み込みに失敗しました';
      debugPrint('Error loading tasks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 指定日の日次完了状態を読み込む
  Future<void> _loadDailyCompletionsForDate(DateTime date) async {
    try {
      final dateKey = _getDateKey(date);
      final completedIds = await _repository.getCompletedTaskIdsOnDate(
          date); // ⚠️ getDailyCompletions() → getCompletedTaskIdsOnDate()
      _dailyCompletions[dateKey] = completedIds.toSet();
    } catch (e) {
      debugPrint('Error loading daily completions: $e');
    }
  }

  /// 日付キーを生成
  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// 指定日にタスクが表示されるべきかチェック
  bool _isTaskVisibleOnDate(Task task, DateTime date) {
    final taskDate = task.createdAt;
    final taskDateOnly = DateTime(taskDate.year, taskDate.month, taskDate.day);

    // タスク作成日より前の日付では表示しない
    if (date.isBefore(taskDateOnly)) return false;

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

      case RepeatType.monthly:
        return date.day == taskDate.day;
    }
  }

  /// 特定の日のタスクを取得（日次完了状態を反映）
  Future<List<Task>> getTasksForDay(DateTime date,
      {bool isGarbageTab = false}) async {
    // 指定日の日次完了状態を読み込む
    await _loadDailyCompletionsForDate(date);

    final dateKey = _getDateKey(date);
    final completedIds = _dailyCompletions[dateKey] ?? {};

    // フィルタリング
    final filteredTasks = _tasks.where((task) {
      // ゴミ出しタブかどうかでフィルタ
      if (isGarbageTab) {
        if (task.categoryId != 'garbage') return false;
      } else {
        if (task.categoryId == 'garbage') return false;
      }

      // 指定日に表示されるべきかチェック
      return _isTaskVisibleOnDate(task, date);
    }).toList();

    // 日次完了状態を反映した新しいTaskオブジェクトを作成
    return filteredTasks.map((task) {
      final isCompletedToday = completedIds.contains(task.id);

      return Task(
        id: task.id,
        title: task.title,
        categoryId: task.categoryId,
        isCompleted: isCompletedToday,
        completedDate: isCompletedToday ? date : null,
        progress: task.progress,
        repeatType: task.repeatType,
        repeatValue: task.repeatValue,
        notificationTime: task.notificationTime,
        createdAt: task.createdAt,
        updatedAt: task.updatedAt,
      );
    }).toList();
  }

  /// 指定日にイベント（タスク）があるかチェック
  bool hasEventsOnDay(DateTime day, {bool isGarbageTab = false}) {
    return _tasks.any((task) {
      // ゴミ出しタブかどうかでフィルタ
      if (isGarbageTab) {
        if (task.categoryId != 'garbage') return false;
      } else {
        if (task.categoryId == 'garbage') return false;
      }

      return _isTaskVisibleOnDate(task, day);
    });
  }

  /// 日付を選択
  void selectDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  /// タスクの完了状態を切り替え（日次完了）
  Future<void> toggleTaskCompletion(String taskId, DateTime date) async {
    try {
      await _repository.toggleTaskCompletionOnDate(taskId, date); // ⚠️ 正しいメソッド名

      // ローカル状態を更新
      final dateKey = _getDateKey(date);
      _dailyCompletions[dateKey] ??= {};
      if (_dailyCompletions[dateKey]!.contains(taskId)) {
        _dailyCompletions[dateKey]!.remove(taskId);
      } else {
        _dailyCompletions[dateKey]!.add(taskId);
      }

      notifyListeners();
    } catch (e) {
      _error = 'タスクの更新に失敗しました';
      debugPrint('Error toggling task completion: $e');
      notifyListeners();
    }
  }
}
