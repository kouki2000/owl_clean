import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
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
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _tabController = TabController(length: 2, vsync: this);

    // タブ切り替え時に再描画
    _tabController.addListener(() {
      if (mounted) {
        setState(() {});
      }
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
            // ヘッダー（固定）
            _buildHeader(),

            // タブ（固定）
            _buildTabBar(),

            // スクロール可能なコンテンツ
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // カレンダー
                    _buildCalendar(),

                    // 選択した日のタスク一覧
                    _buildTaskList(),
                  ],
                ),
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

  /// タブバー
  Widget _buildTabBar() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.gray800,
        unselectedLabelColor: AppColors.gray400,
        labelStyle: AppTextStyles.body.copyWith(fontWeight: FontWeight.w400),
        unselectedLabelStyle:
            AppTextStyles.body.copyWith(fontWeight: FontWeight.w300),
        indicatorColor: AppColors.gray800,
        indicatorWeight: 2,
        tabs: const [
          Tab(text: '掃除'),
          Tab(text: 'ゴミ出し'),
        ],
      ),
    );
  }

  /// カレンダー
  Widget _buildCalendar() {
    return Consumer<CalendarViewModel>(
      builder: (context, viewModel, child) {
        // 現在のタブがゴミ出しタブかどうか
        final isGarbageTab = _tabController.index == 1;

        return Container(
          decoration: const BoxDecoration(
            border:
                Border(bottom: BorderSide(color: AppColors.border, width: 1)),
          ),
          child: TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: CalendarFormat.month,
            startingDayOfWeek: StartingDayOfWeek.sunday,
            locale: 'ja_JP',
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: AppTextStyles.body.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              leftChevronIcon: const Icon(
                Icons.chevron_left,
                color: AppColors.gray800,
              ),
              rightChevronIcon: const Icon(
                Icons.chevron_right,
                color: AppColors.gray800,
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
              defaultTextStyle: AppTextStyles.body.copyWith(fontSize: 14),
              weekendTextStyle: AppTextStyles.body.copyWith(fontSize: 14),
              outsideTextStyle: AppTextStyles.body.copyWith(
                fontSize: 14,
                color: AppColors.gray300,
              ),
              markerDecoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
              markersMaxCount: 3,
            ),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              context.read<CalendarViewModel>().selectDate(selectedDay);
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            // タスクがある日にマーカーを表示（タブに応じて）
            eventLoader: (day) {
              return viewModel.hasEventsOnDay(day, isGarbageTab: isGarbageTab)
                  ? ['event']
                  : [];
            },
          ),
        );
      },
    );
  }

  /// 選択した日のタスク一覧
  Widget _buildTaskList() {
    final selectedDateStr = _selectedDay != null
        ? DateFormat('M月d日(E)', 'ja_JP').format(_selectedDay!)
        : '';

    return Consumer<CalendarViewModel>(
      builder: (context, viewModel, child) {
        // 現在のタブがゴミ出しタブかどうか
        final isGarbageTab = _tabController.index == 1;

        // タブに応じてタスクを取得
        final tasksForSelectedDay = viewModel.getTasksForDay(
          _selectedDay!,
          isGarbageTab: isGarbageTab,
        );

        return Column(
          children: [
            // 日付ヘッダー
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: const BoxDecoration(
                color: AppColors.gray50,
              ),
              child: Row(
                children: [
                  Text(
                    selectedDateStr,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${tasksForSelectedDay.length}件のタスク',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),

            // タスク一覧
            tasksForSelectedDay.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(AppSpacing.xxl),
                    child: Column(
                      children: [
                        // const Text('📅', style: TextStyle(fontSize: 48)),
                        // const SizedBox(height: AppSpacing.md),
                        Text(
                          'この日のタスクはありません',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.gray400,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: tasksForSelectedDay.length,
                    itemBuilder: (context, index) {
                      final task = tasksForSelectedDay[index];
                      return _buildTaskItem(task, viewModel);
                    },
                  ),
          ],
        );
      },
    );
  }

  /// タスクアイテム（削除ボタン付き）
  Widget _buildTaskItem(Task task, CalendarViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: task.isCompleted ? AppColors.gray50 : AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // チェックボックス
          GestureDetector(
            onTap: () {
              viewModel.toggleTaskCompletion(task.id, _selectedDay);
            },
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      task.isCompleted ? AppColors.gray800 : AppColors.gray300,
                  width: 2,
                ),
                color:
                    task.isCompleted ? AppColors.gray800 : Colors.transparent,
              ),
              child: task.isCompleted
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: AppColors.white,
                    )
                  : null,
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          // タスク情報
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: AppTextStyles.body.copyWith(
                    decoration:
                        task.isCompleted ? TextDecoration.lineThrough : null,
                    color: task.isCompleted
                        ? AppColors.gray400
                        : AppColors.gray800,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildRepeatBadge(task.repeatType),
                    if (task.isCompleted) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '完了',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.gray400,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: AppSpacing.sm),

          // 削除ボタン
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              color: AppColors.gray400,
              size: 20,
            ),
            onPressed: () => _deleteTask(task),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  /// タスクを削除
  Future<void> _deleteTask(Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('削除確認'),
        content: Text('「${task.title}」を削除しますか？\n\n繰り返しタスクの場合、すべての予定が削除されます。'),
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
      await context.read<TaskViewModel>().deleteTask(task.id);
      await context.read<CalendarViewModel>().loadTasks();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('「${task.title}」を削除しました'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// 繰り返しバッジ
  Widget _buildRepeatBadge(RepeatType repeatType) {
    String text;
    IconData icon;
    Color color;

    switch (repeatType) {
      case RepeatType.daily:
        text = '毎日';
        icon = Icons.refresh;
        color = AppColors.accent;
      case RepeatType.weekly:
        text = '毎週';
        icon = Icons.calendar_today;
        color = Colors.blue;
      case RepeatType.monthly:
        text = '毎月';
        icon = Icons.calendar_month;
        color = Colors.purple;
      case RepeatType.none:
      default:
        text = '1回のみ';
        icon = Icons.event;
        color = AppColors.gray400;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
