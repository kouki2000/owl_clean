import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../viewmodels/calendar_viewmodel.dart';
import '../../models/garbage_schedule.dart';

/// カレンダー画面
class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
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

            // カレンダー
            _buildCalendar(),

            // タブビュー（選択された日付のコンテンツ）
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildCleaningTab(), _buildGarbageTab()],
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
      child: Row(children: [Text('カレンダー', style: AppTextStyles.h1)]),
    );
  }

  /// タブバー
  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.md,
      ),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.gray50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(6),
            boxShadow: AppShadows.light,
          ),
          indicatorPadding: const EdgeInsets.all(4),
          dividerColor: Colors.transparent,
          labelColor: AppColors.gray800,
          unselectedLabelColor: AppColors.gray400,
          labelStyle: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w400,
            fontSize: 14,
          ),
          unselectedLabelStyle: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w300,
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: '掃除'),
            Tab(text: 'ゴミ出し'),
          ],
        ),
      ),
    );
  }

  /// カレンダー
  Widget _buildCalendar() {
    return Consumer<CalendarViewModel>(
      builder: (context, viewModel, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: viewModel.focusedDate,
            selectedDayPredicate: (day) {
              return isSameDay(viewModel.selectedDate, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              viewModel.selectDate(selectedDay);
              viewModel.updateFocusedDate(focusedDay);
            },
            onPageChanged: (focusedDay) {
              viewModel.updateFocusedDate(focusedDay);
            },
            calendarFormat: CalendarFormat.month,
            startingDayOfWeek: StartingDayOfWeek.sunday,
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: AppTextStyles.h3.copyWith(
                fontWeight: FontWeight.w300,
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
              weekdayStyle: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w300,
              ),
              weekendStyle: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w300,
              ),
            ),
            calendarStyle: CalendarStyle(
              defaultTextStyle: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w300,
              ),
              weekendTextStyle: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w300,
              ),
              selectedDecoration: const BoxDecoration(
                color: AppColors.gray800,
                shape: BoxShape.circle,
              ),
              selectedTextStyle: AppTextStyles.body.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w400,
              ),
              todayDecoration: BoxDecoration(
                color: AppColors.gray300,
                shape: BoxShape.circle,
              ),
              todayTextStyle: AppTextStyles.body.copyWith(
                color: AppColors.gray800,
                fontWeight: FontWeight.w400,
              ),
              outsideDaysVisible: false,
              markerDecoration: const BoxDecoration(
                color: AppColors.gray800,
                shape: BoxShape.circle,
              ),
              markerSize: 4,
            ),
            calendarBuilders: CalendarBuilders(
              // マーカー（イベントがある日に小さな点を表示）
              markerBuilder: (context, date, events) {
                final hasEvents = viewModel.hasEventsOnDay(
                  date,
                  includeGarbage: _currentTabIndex == 1,
                );

                if (hasEvents) {
                  return Positioned(
                    bottom: 4,
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isSameDay(date, viewModel.selectedDate)
                            ? AppColors.white
                            : AppColors.gray800,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }
                return null;
              },
            ),
          ),
        );
      },
    );
  }

  /// 掃除タブ
  Widget _buildCleaningTab() {
    return Consumer<CalendarViewModel>(
      builder: (context, viewModel, child) {
        final tasks = viewModel.getTasksForDay(viewModel.selectedDate);
        final dateFormat = DateFormat('M月d日(E)', 'ja_JP');

        return Column(
          children: [
            // 選択された日付
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(
                dateFormat.format(viewModel.selectedDate),
                style: AppTextStyles.label,
              ),
            ),

            // タスクリスト
            Expanded(
              child: tasks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('✨', style: TextStyle(fontSize: 48)),
                          const SizedBox(height: AppSpacing.md),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return _buildTaskItem(task, viewModel);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  /// ゴミ出しタブ
  Widget _buildGarbageTab() {
    return Consumer<CalendarViewModel>(
      builder: (context, viewModel, child) {
        final schedules = viewModel.getGarbageSchedulesForDay(
          viewModel.selectedDate,
        );
        final dateFormat = DateFormat('M月d日(E)', 'ja_JP');

        return Column(
          children: [
            // 選択された日付
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(
                dateFormat.format(viewModel.selectedDate),
                style: AppTextStyles.label,
              ),
            ),

            // ゴミ出しリスト
            Expanded(
              child: schedules.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🗑️', style: TextStyle(fontSize: 48)),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'この日のゴミ出しはありません',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.gray400,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          ElevatedButton(
                            onPressed: () {
                              // サンプルゴミ出しスケジュールを追加
                              viewModel.addSampleGarbageSchedules();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.gray800,
                              foregroundColor: AppColors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xl,
                                vertical: AppSpacing.md,
                              ),
                            ),
                            child: const Text('サンプルを追加'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      itemCount: schedules.length,
                      itemBuilder: (context, index) {
                        final schedule = schedules[index];
                        return _buildGarbageItem(schedule);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  /// タスクアイテム
  Widget _buildTaskItem(Task, CalendarViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // チェックボックス
          GestureDetector(
            onTap: () => viewModel.toggleTaskCompletion(Task.id),
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Task.isCompleted
                    ? AppColors.gray800
                    : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Task.isCompleted
                      ? AppColors.gray800
                      : AppColors.gray300,
                  width: 2,
                ),
              ),
              child: Task.isCompleted
                  ? const Icon(Icons.check, size: 12, color: AppColors.white)
                  : null,
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          // タスク名
          Expanded(
            child: Text(
              Task.title,
              style: AppTextStyles.body.copyWith(
                decoration: Task.isCompleted
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
                color: Task.isCompleted ? AppColors.gray400 : AppColors.gray800,
              ),
            ),
          ),

          // 進捗
          Text('${Task.progress}%', style: AppTextStyles.caption),
        ],
      ),
    );
  }

  /// ゴミ出しアイテム
  Widget _buildGarbageItem(GarbageSchedule schedule) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // アイコン
          Text(
            GarbageTypes.getEmoji(schedule.garbageType),
            style: const TextStyle(fontSize: 24),
          ),

          const SizedBox(width: AppSpacing.md),

          // ゴミの種類
          Expanded(
            child: Text(schedule.garbageType, style: AppTextStyles.body),
          ),

          // 曜日
          Text('${schedule.dayOfWeekName}曜日', style: AppTextStyles.caption),
        ],
      ),
    );
  }
}
