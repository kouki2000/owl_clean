import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../viewmodels/calendar_viewmodel.dart';
import '../../viewmodels/task_viewmodel.dart';
import '../../models/task.dart';

/// カレンダー画面
class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // データを読み込み
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CalendarViewModel>().loadTasks();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ヘッダー
            _buildHeader(),

            // タブバー
            _buildTabBar(),

            // タブビュー
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // 掃除タブ
                  _buildCleaningTab(),
                  // ゴミ出しタブ
                  _buildGarbageTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ヘッダー
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Text(
        'カレンダー',
        style: AppTextStyles.h2,
        textAlign: TextAlign.center,
      ),
    );
  }

  /// タブバー
  Widget _buildTabBar() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: '掃除'),
          Tab(text: 'ゴミ出し'),
        ],
        labelColor: AppColors.gray800,
        unselectedLabelColor: AppColors.gray400,
        indicatorColor: AppColors.gray800,
        labelStyle: AppTextStyles.body.copyWith(fontWeight: FontWeight.w400),
        unselectedLabelStyle: AppTextStyles.body,
      ),
    );
  }

  /// 掃除タブ
  Widget _buildCleaningTab() {
    final calendarViewModel = context.watch<CalendarViewModel>();

    return Column(
      children: [
        // カレンダー
        _buildCalendar(calendarViewModel, isGarbageTab: false),

        // 選択日の表示
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              Text(
                '${_selectedDay.month}月${_selectedDay.day}日(${_getWeekdayName(_selectedDay.weekday)})',
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Spacer(),
              Text(
                '今日の予定',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.gray400,
                ),
              ),
            ],
          ),
        ),

        // タスクリスト
        Expanded(
          child: _buildTaskList(calendarViewModel, isGarbageTab: false),
        ),
      ],
    );
  }

  /// ゴミ出しタブ
  Widget _buildGarbageTab() {
    final calendarViewModel = context.watch<CalendarViewModel>();

    return Column(
      children: [
        // カレンダー
        _buildCalendar(calendarViewModel, isGarbageTab: true),

        // 選択日の表示
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              Text(
                '${_selectedDay.month}月${_selectedDay.day}日(${_getWeekdayName(_selectedDay.weekday)})',
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Spacer(),
              Text(
                '今日の予定',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.gray400,
                ),
              ),
            ],
          ),
        ),

        // タスクリスト
        Expanded(
          child: _buildTaskList(calendarViewModel, isGarbageTab: true),
        ),
      ],
    );
  }

  /// カレンダー
  Widget _buildCalendar(CalendarViewModel viewModel,
      {required bool isGarbageTab}) {
    return TableCalendar(
      firstDay: DateTime(2020),
      lastDay: DateTime(DateTime.now().year + 10),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      locale: 'ja_JP',
      calendarFormat: CalendarFormat.month,
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: AppTextStyles.caption.copyWith(fontSize: 12),
        weekendStyle: AppTextStyles.caption.copyWith(fontSize: 12),
      ),
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: AppColors.gray800,
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: AppColors.gray800,
          shape: BoxShape.circle,
        ),
        markerDecoration: BoxDecoration(
          color: AppColors.accent,
          shape: BoxShape.circle,
        ),
        markersMaxCount: 1,
        markerSize: 6,
      ),
      eventLoader: (day) {
        // その日にタスクがあるかチェック
        final hasTasks = viewModel.tasks.any((task) {
          // ゴミ出しタブの場合は garbage カテゴリーのみ
          if (isGarbageTab && task.categoryId != 'garbage') {
            return false;
          }
          // 掃除タブの場合は garbage 以外
          if (!isGarbageTab && task.categoryId == 'garbage') {
            return false;
          }
          return _isTaskVisibleOnDate(task, day);
        });
        return hasTasks ? [1] : [];
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      onPageChanged: (focusedDay) {
        setState(() {
          _focusedDay = focusedDay;
        });
      },
    );
  }

  /// タスクリスト
  Widget _buildTaskList(CalendarViewModel viewModel,
      {required bool isGarbageTab}) {
    return FutureBuilder<List<Task>>(
      future: viewModel.getTasksForDay(_selectedDay),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState();
        }

        // フィルタリング
        final tasks = snapshot.data!.where((task) {
          if (isGarbageTab) {
            return task.categoryId == 'garbage';
          } else {
            return task.categoryId != 'garbage';
          }
        }).toList();

        if (tasks.isEmpty) {
          return _buildEmptyState();
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: tasks.map((task) => _buildTaskItem(task)).toList(),
          ),
        );
      },
    );
  }

  /// 空の状態
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: AppSpacing.md),
          Text(
            '${_selectedDay.month}月${_selectedDay.day}日のタスクはありません',
            style: AppTextStyles.body.copyWith(
              color: AppColors.gray400,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// タスクアイテム
  Widget _buildTaskItem(Task task) {
    // 通知時間を取得
    String? notificationTimeText;
    if (task.notificationTime != null) {
      final time = task.notificationTime!;
      notificationTimeText =
          '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        leading: task.isCompleted
            ? const Icon(Icons.check_circle, color: AppColors.accent, size: 24)
            : null,
        title: Text(
          task.title,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w400,
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            color: task.isCompleted ? AppColors.gray400 : AppColors.gray800,
          ),
        ),
        subtitle: notificationTimeText != null // ⚠️ 通知時間を表示
            ? Row(
                children: [
                  const Icon(
                    Icons.notifications,
                    size: 14,
                    color: AppColors.gray400,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    notificationTimeText,
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 12,
                      color: AppColors.gray400,
                    ),
                  ),
                ],
              )
            : null,
        trailing: IconButton(
          icon: const Icon(
            Icons.delete_outline,
            color: AppColors.error,
            size: 20,
          ),
          onPressed: () => _deleteTask(task),
        ),
      ),
    );
  }

  /// タスク削除
  Future<void> _deleteTask(Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('削除確認'),
        content: Text('「${task.title}」を削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              '削除',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final taskViewModel = context.read<TaskViewModel>();
      final calendarViewModel = context.read<CalendarViewModel>();

      await taskViewModel.deleteTask(task.id);
      await calendarViewModel.loadTasks();

      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('「${task.title}」を削除しました'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
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
      case RepeatType.none:
        return date.year == taskDate.year &&
            date.month == taskDate.month &&
            date.day == taskDate.day;
      case RepeatType.daily:
        return true;
      case RepeatType.weekly:
        return date.weekday == taskDate.weekday;
      case RepeatType.biweekly:
        final daysDifference = date.difference(taskDateOnly).inDays;
        return daysDifference % 14 == 0;
      case RepeatType.monthly:
        return date.day == taskDate.day;
    }
  }

  /// 曜日名を取得
  String _getWeekdayName(int weekday) {
    const weekdays = ['月', '火', '水', '木', '金', '土', '日'];
    return weekdays[weekday - 1];
  }
}
