import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../models/garbage_schedule.dart';
import '../repositories/task_repository.dart';
import '../services/database_service.dart';

/// カレンダーViewModel
///
/// カレンダー画面のビジネスロジックと状態管理
class CalendarViewModel extends ChangeNotifier {
  final TaskRepository _taskRepository = TaskRepository();
  final DatabaseService _dbService = DatabaseService.instance;

  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();

  List<Task> _tasks = [];
  List<GarbageSchedule> _garbageSchedules = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  DateTime get selectedDate => _selectedDate;
  DateTime get focusedDate => _focusedDate;
  List<Task> get tasks => _tasks;
  List<GarbageSchedule> get garbageSchedules => _garbageSchedules;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 選択された日付のタスクを取得
  List<Task> getTasksForDay(DateTime day) {
    return _tasks.where((task) {
      // 繰り返しタスクの場合は毎日/該当する曜日に表示
      if (task.repeatType != RepeatType.none) {
        return _shouldShowOnDate(task, day);
      }

      // 単発タスクの場合、未完了なら表示
      return !task.isCompleted;
    }).toList();
  }

  /// 選択された日付のゴミ出しスケジュールを取得
  List<GarbageSchedule> getGarbageSchedulesForDay(DateTime day) {
    final dayOfWeek = day.weekday % 7;
    return _garbageSchedules
        .where((schedule) => schedule.dayOfWeek == dayOfWeek)
        .toList();
  }

  /// 指定した日にタスクやゴミ出しがあるかチェック（カレンダーのマーカー用）
  bool hasEventsOnDay(DateTime day, {bool includeGarbage = true}) {
    final hasTasks = getTasksForDay(day).isNotEmpty;
    final hasGarbage =
        includeGarbage && getGarbageSchedulesForDay(day).isNotEmpty;
    return hasTasks || hasGarbage;
  }

  /// タスクが指定した日付に表示されるべきかチェック
  bool _shouldShowOnDate(Task task, DateTime day) {
    switch (task.repeatType) {
      case RepeatType.daily:
        return true;
      case RepeatType.weekly:
        // TODO: repeatValueから曜日情報を取得して判定
        return true;
      case RepeatType.monthly:
        // TODO: repeatValueから日付情報を取得して判定
        return true;
      case RepeatType.none:
        return false;
    }
  }

  /// 初期化
  Future<void> initialize() async {
    await loadTasks();
    await loadGarbageSchedules();
  }

  /// タスクを読み込み
  Future<void> loadTasks() async {
    _setLoading(true);
    _error = null;

    try {
      _tasks = await _taskRepository.getAllTasks();
      notifyListeners();
    } catch (e) {
      _error = 'タスクの読み込みに失敗しました: $e';
      debugPrint(_error);
    } finally {
      _setLoading(false);
    }
  }

  /// ゴミ出しスケジュールを読み込み
  Future<void> loadGarbageSchedules() async {
    _error = null;

    try {
      _garbageSchedules = await _dbService.getGarbageSchedules();
      notifyListeners();
    } catch (e) {
      _error = 'ゴミ出しスケジュールの読み込みに失敗しました: $e';
      debugPrint(_error);
    }
  }

  /// 日付を選択
  void selectDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  /// フォーカス日付を変更
  void updateFocusedDate(DateTime date) {
    _focusedDate = date;
    notifyListeners();
  }

  /// タスクを完了/未完了にする
  Future<void> toggleTaskCompletion(String id) async {
    _error = null;

    try {
      final taskIndex = _tasks.indexWhere((t) => t.id == id);
      if (taskIndex == -1) return;

      final task = _tasks[taskIndex];
      final updatedTask = await _taskRepository.toggleTaskCompletion(task);

      _tasks[taskIndex] = updatedTask;
      notifyListeners();
    } catch (e) {
      _error = 'タスクの完了状態の変更に失敗しました: $e';
      debugPrint(_error);
    }
  }

  /// ゴミ出しスケジュールを追加
  Future<void> addGarbageSchedule({
    required String garbageType,
    required int dayOfWeek,
    DateTime? notificationTime,
  }) async {
    _error = null;

    try {
      final schedule = GarbageSchedule(
        id: 'garbage_${DateTime.now().millisecondsSinceEpoch}',
        garbageType: garbageType,
        dayOfWeek: dayOfWeek,
        notificationTime: notificationTime,
        createdAt: DateTime.now(),
      );

      await _dbService.insertGarbageSchedule(schedule);
      await loadGarbageSchedules();
    } catch (e) {
      _error = 'ゴミ出しスケジュールの追加に失敗しました: $e';
      debugPrint(_error);
    }
  }

  /// ゴミ出しスケジュールを削除
  Future<void> deleteGarbageSchedule(String id) async {
    _error = null;

    try {
      await _dbService.deleteGarbageSchedule(id);
      await loadGarbageSchedules();
    } catch (e) {
      _error = 'ゴミ出しスケジュールの削除に失敗しました: $e';
      debugPrint(_error);
    }
  }

  /// サンプルゴミ出しスケジュールを追加（開発用）
  Future<void> addSampleGarbageSchedules() async {
    await addGarbageSchedule(
      garbageType: GarbageTypes.burnable,
      dayOfWeek: 2, // 火曜日
    );
    await addGarbageSchedule(
      garbageType: GarbageTypes.burnable,
      dayOfWeek: 5, // 金曜日
    );
    await addGarbageSchedule(
      garbageType: GarbageTypes.recyclable,
      dayOfWeek: 3, // 水曜日
    );
  }

  /// ローディング状態を設定
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
