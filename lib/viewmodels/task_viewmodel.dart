import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../repositories/task_repository.dart';

/// タスクViewModel
///
/// タスク関連のビジネスロジックと状態管理
class TaskViewModel extends ChangeNotifier {
  final TaskRepository _repository = TaskRepository();

  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _error;

  // 統計情報
  int _todayCompletedCount = 0;
  int _weekCompletedCount = 0;
  int _streakDays = 0;

  // Getters
  List<Task> get tasks => _tasks;
  List<Task> get todayTasks => _tasks.where((task) => task.isToday()).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get todayCompletedCount => _todayCompletedCount;
  int get weekCompletedCount => _weekCompletedCount;
  int get streakDays => _streakDays;
  int get totalCompletedCount =>
      _tasks.where((task) => task.isCompleted).length;

  /// 初期化
  Future<void> initialize() async {
    await loadTasks();
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
      notifyListeners();
    } catch (e) {
      _error = 'タスクの削除に失敗しました: $e';
      debugPrint(_error);
    }
  }

  /// タスクを完了/未完了にする
  Future<void> toggleTaskCompletion(String id) async {
    _error = null;

    try {
      final taskIndex = _tasks.indexWhere((t) => t.id == id);
      if (taskIndex == -1) return;

      final task = _tasks[taskIndex];
      final updatedTask = await _repository.toggleTaskCompletion(task);

      _tasks[taskIndex] = updatedTask;

      // 統計情報を更新
      await loadStats();

      notifyListeners();
    } catch (e) {
      _error = 'タスクの完了状態の変更に失敗しました: $e';
      debugPrint(_error);
    }
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

  /// サンプルデータを追加（開発用）
  Future<void> addSampleData() async {
    await addTask(title: '床掃除', categoryId: 'living');
    await addTask(title: '窓拭き', categoryId: 'living');
    await addTask(title: 'トイレ掃除', categoryId: 'toilet');
  }

  /// ローディング状態を設定
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
