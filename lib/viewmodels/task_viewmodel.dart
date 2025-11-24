import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../repositories/task_repository.dart';

/// タスクViewModel
class TaskViewModel extends ChangeNotifier {
  final TaskRepository _repository = TaskRepository();

  List<Task> _tasks = [];
  Map<String, Set<String>> _dailyCompletions = {}; // 日付 -> 完了タスクIDセット
  bool _isLoading = false;
  String? _error;

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

  /// 今日のタスク（日次完了状態を反映）
  List<Task> get todayTasks {
    final today = DateTime.now();
    final todayKey = _getDateKey(today);
    final completedIds = _dailyCompletions[todayKey] ?? {};

    return _tasks.where((task) => task.isToday()).toList();
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

  /// サンプルデータを追加（開発用）
  Future<void> addSampleData() async {
    await addTask(
        title: '床掃除', categoryId: 'living', repeatType: RepeatType.daily);
    await addTask(
        title: '窓拭き', categoryId: 'living', repeatType: RepeatType.weekly);
    await addTask(
        title: 'トイレ掃除', categoryId: 'toilet', repeatType: RepeatType.daily);
  }

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
