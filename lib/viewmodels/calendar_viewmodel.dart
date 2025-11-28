import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../models/garbage_schedule.dart';
import '../repositories/task_repository.dart';
import '../services/database_service.dart';

/// カレンダーViewModel
class CalendarViewModel extends ChangeNotifier {
  final TaskRepository _taskRepository = TaskRepository();
  final DatabaseService _dbService = DatabaseService.instance;

  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();

  List<Task> _tasks = [];
  Map<String, Set<String>> _dailyCompletions = {}; // 日付 -> 完了タスクIDセット
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

  /// 選択された日付のタスクを取得（タブでフィルタリング）
  List<Task> getTasksForDay(DateTime day, {bool isGarbageTab = false}) {
    final dayOnly = DateTime(day.year, day.month, day.day);
    final dateKey = _getDateKey(dayOnly);
    final completedIds = _dailyCompletions[dateKey] ?? {};

    return _tasks.where((task) {
      // タブに応じてフィルタリング
      if (isGarbageTab) {
        // ゴミ出しタブ：categoryId = 'garbage' のみ
        if (task.categoryId != 'garbage') return false;
      } else {
        // 掃除タブ：categoryId != 'garbage' のみ
        if (task.categoryId == 'garbage') return false;
      }

      return _isTaskVisibleOnDate(task, dayOnly);
    }).map((task) {
      // 日次完了状態を反映したTaskを返す
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
      );
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
  bool hasEventsOnDay(DateTime day, {bool isGarbageTab = false}) {
    final hasTasks = getTasksForDay(day, isGarbageTab: isGarbageTab).isNotEmpty;
    return hasTasks;
  }

  /// タスクが指定した日付に表示されるべきかチェック
  bool _isTaskVisibleOnDate(Task task, DateTime day) {
    final taskDate = task.createdAt;
    final taskDateOnly = DateTime(taskDate.year, taskDate.month, taskDate.day);

    if (day.isBefore(taskDateOnly)) return false;

    switch (task.repeatType) {
      case RepeatType.daily:
        return true;
      case RepeatType.weekly:
        return day.weekday == taskDate.weekday;
      case RepeatType.monthly:
        return day.day == taskDate.day;
      case RepeatType.none:
        return day.year == taskDate.year &&
            day.month == taskDate.month &&
            day.day == taskDate.day;
    }
  }

  /// 初期化
  Future<void> initialize() async {
    await loadTasks();
    await _loadDailyCompletions();
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

  /// 日次完了状態を読み込み
  Future<void> _loadDailyCompletions() async {
    try {
      // 今日の完了状態のみ読み込み
      final now = DateTime.now();
      final dateKey = _getDateKey(now);
      final completedIds = await _taskRepository.getCompletedTaskIdsOnDate(now);
      _dailyCompletions[dateKey] = completedIds.toSet();

      notifyListeners();
    } catch (e) {
      debugPrint('日次完了状態の読み込みに失敗しました: $e');
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

  /// タスクを完了/未完了にする（日次）
  Future<void> toggleTaskCompletion(String id, [DateTime? date]) async {
    _error = null;
    final targetDate = date ?? _selectedDate;
    final dateKey = _getDateKey(targetDate);

    try {
      await _taskRepository.toggleTaskCompletionOnDate(id, targetDate);

      // ローカル状態を更新
      _dailyCompletions[dateKey] ??= {};
      if (_dailyCompletions[dateKey]!.contains(id)) {
        _dailyCompletions[dateKey]!.remove(id);
      } else {
        _dailyCompletions[dateKey]!.add(id);
      }

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

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// ローディング状態を設定
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
