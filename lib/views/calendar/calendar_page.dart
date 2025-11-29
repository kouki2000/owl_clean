import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../viewmodels/calendar_viewmodel.dart';
import '../../viewmodels/task_viewmodel.dart';
import '../../models/task.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<CalendarViewModel>();
      viewModel.selectDate(DateTime.now());
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _deleteTask(String id, String title) async {
    final calendarViewModel = context.read<CalendarViewModel>();
    final taskViewModel = context.read<TaskViewModel>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('削除確認'),
        content: Text('「$title」を削除しますか？'),
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

    if (confirmed == true) {
      await taskViewModel.deleteTask(id);
      await calendarViewModel.loadTasks();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('「$title」を削除しました'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  String _getRepeatText(dynamic task) {
    switch (task.repeatType) {
      case 'daily':
        return '毎日';
      case 'weekly':
        return '毎週';
      case 'monthly':
        return '毎月';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: SingleChildScrollView(
                // ⚠️ 追加
                child: Column(
                  children: [
                    _buildCalendar(),
                    _buildSelectedDateHeader(),
                    _buildTaskList(), // ⚠️ Expandedを削除
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        children: [
          Text('カレンダー', style: AppTextStyles.h1),
        ],
      ),
    );
  }

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

  Widget _buildCalendar() {
    final viewModel = context.watch<CalendarViewModel>();
    final isGarbageTab = _tabController.index == 1;

    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) {
        return isSameDay(viewModel.selectedDate, day);
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _focusedDay = focusedDay;
        });
        viewModel.selectDate(selectedDay);
      },
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
      },
      eventLoader: (day) {
        return viewModel.hasEventsOnDay(day, isGarbageTab: isGarbageTab)
            ? [day]
            : [];
      },
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: AppColors.gray400,
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
        defaultTextStyle: AppTextStyles.body,
        weekendTextStyle: AppTextStyles.body,
      ),
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: AppTextStyles.h2,
      ),
      locale: 'ja_JP',
    );
  }

  Widget _buildSelectedDateHeader() {
    final viewModel = context.watch<CalendarViewModel>();
    final selectedDate = viewModel.selectedDate ?? DateTime.now();
    final weekdayNames = ['月', '火', '水', '木', '金', '土', '日'];
    final weekdayName = weekdayNames[selectedDate.weekday - 1];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${selectedDate.month}月${selectedDate.day}日($weekdayName)',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w400),
          ),
          Text(
            '今日の予定',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList() {
    final viewModel = context.watch<CalendarViewModel>();
    final taskViewModel = context.read<TaskViewModel>();
    final selectedDate = viewModel.selectedDate ?? DateTime.now();
    final isGarbageTab = _tabController.index == 1;

    return FutureBuilder<List<Task>>(
      future:
          viewModel.getTasksForDay(selectedDate, isGarbageTab: isGarbageTab),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 200,
            child: Center(
              child: CircularProgressIndicator(color: AppColors.gray800),
            ),
          );
        }

        if (snapshot.hasError) {
          return SizedBox(
            height: 200,
            child: Center(
              child: Text('エラーが発生しました: ${snapshot.error}'),
            ),
          );
        }

        final tasks = snapshot.data ?? [];

        if (tasks.isEmpty) {
          final dateStr = '${selectedDate.month}月${selectedDate.day}日';
          return SizedBox(
            height: 200,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('✨', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      '$dateStrのタスクはありません',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.gray400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.lg),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
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
                leading: task.isCompleted // ⚠️ 完了時のみアイコン表示
                    ? const Icon(
                        Icons.check_circle,
                        color: AppColors.gray800,
                        size: 24,
                      )
                    : null,
                title: Text(
                  task.title,
                  style: AppTextStyles.body.copyWith(
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    color: task.isCompleted
                        ? AppColors.gray400
                        : AppColors.gray800,
                  ),
                ),
                subtitle: task.repeatType != RepeatType.none
                    ? Text(
                        _getRepeatText(task),
                        style: AppTextStyles.caption,
                      )
                    : null,
                trailing: IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppColors.error,
                    size: 20,
                  ),
                  onPressed: () => _deleteTask(task.id, task.title),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
