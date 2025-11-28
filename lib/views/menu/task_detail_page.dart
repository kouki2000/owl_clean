import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../viewmodels/task_viewmodel.dart';
import '../../viewmodels/calendar_viewmodel.dart';
import '../../models/task.dart';

/// タスク詳細登録画面
class TaskDetailPage extends StatefulWidget {
  final String? initialTaskName;
  final String? categoryId; // 追加
  final Task? existingTask; // 編集時に使用

  const TaskDetailPage({
    super.key,
    this.initialTaskName,
    this.categoryId, // 追加
    this.existingTask,
  });

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  late TextEditingController _taskNameController;
  RepeatType _selectedRepeatType = RepeatType.none;
  DateTime _startDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _taskNameController = TextEditingController(
      text: widget.initialTaskName ?? widget.existingTask?.title ?? '',
    );

    if (widget.existingTask != null) {
      _selectedRepeatType = widget.existingTask!.repeatType;
      _startDate = widget.existingTask!.createdAt;
    }
  }

  @override
  void dispose() {
    _taskNameController.dispose();
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

            // メインコンテンツ
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // タスク名
                    _buildTaskNameField(),

                    const SizedBox(height: AppSpacing.xxl),

                    // 繰り返し設定
                    _buildRepeatTypeSection(),

                    const SizedBox(height: AppSpacing.xxl),

                    // 開始日
                    _buildStartDateSection(),
                  ],
                ),
              ),
            ),

            // ボタン
            _buildBottomButtons(),
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
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.gray800),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Text(
              widget.existingTask != null ? 'タスクを編集' : 'タスクを追加',
              style: AppTextStyles.h2,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48), // IconButtonと同じ幅
        ],
      ),
    );
  }

  /// タスク名入力フィールド
  Widget _buildTaskNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'タスク名',
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _taskNameController,
          decoration: InputDecoration(
            hintText: '例：床掃除',
            hintStyle: AppTextStyles.body.copyWith(
              color: AppColors.gray400,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.gray800, width: 2),
            ),
            contentPadding: const EdgeInsets.all(AppSpacing.lg),
          ),
          autofocus: widget.initialTaskName == null,
        ),
      ],
    );
  }

  /// 繰り返し設定セクション
  Widget _buildRepeatTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '繰り返し',
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _buildRepeatTypeOption('繰り返しなし', RepeatType.none, Icons.event_note),
        _buildRepeatTypeOption('毎日', RepeatType.daily, Icons.refresh),
        _buildRepeatTypeOption('毎週', RepeatType.weekly, Icons.calendar_today),
        _buildRepeatTypeOption('毎月', RepeatType.monthly, Icons.calendar_month),
      ],
    );
  }

  /// 繰り返し設定オプション
  Widget _buildRepeatTypeOption(String label, RepeatType type, IconData icon) {
    final isSelected = _selectedRepeatType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRepeatType = type;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.gray800 : AppColors.white,
          border: Border.all(
            color: isSelected ? AppColors.gray800 : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.white : AppColors.gray800,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              label,
              style: AppTextStyles.body.copyWith(
                color: isSelected ? AppColors.white : AppColors.gray800,
                fontWeight: FontWeight.w400,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.white,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  /// 開始日セクション
  Widget _buildStartDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '開始日',
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        GestureDetector(
          onTap: _selectStartDate,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: AppColors.gray800,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  DateFormat('yyyy年M月d日(E)', 'ja_JP').format(_startDate),
                  style: AppTextStyles.body,
                ),
                const Spacer(),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.gray400,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 開始日を選択
  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.gray800,
              onPrimary: AppColors.white,
              onSurface: AppColors.gray800,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  /// 下部ボタン
  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        children: [
          // キャンセルボタン
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.border),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'キャンセル',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.gray800,
                ),
              ),
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          // 保存ボタン
          Expanded(
            child: ElevatedButton(
              onPressed: _saveTask,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gray800,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('保存'),
            ),
          ),
        ],
      ),
    );
  }

  /// タスクを保存
  Future<void> _saveTask() async {
    final taskName = _taskNameController.text.trim();

    if (taskName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('タスク名を入力してください'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      // タスクを追加（categoryIdを渡す）
      await context.read<TaskViewModel>().addTask(
            title: taskName,
            categoryId: widget.categoryId, // categoryIdを渡す
            repeatType: _selectedRepeatType,
            createdAt: _startDate,
          );

      // カレンダーも更新
      await context.read<CalendarViewModel>().loadTasks();

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('「$taskName」を追加しました'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('タスクの追加に失敗しました: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
}
