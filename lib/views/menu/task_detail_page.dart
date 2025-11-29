import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../viewmodels/task_viewmodel.dart';
import '../../models/task.dart';

class TaskDetailPage extends StatefulWidget {
  final String? initialTaskName;
  final String? categoryId;
  final bool isTemplate;

  const TaskDetailPage({
    super.key,
    this.initialTaskName,
    this.categoryId,
    this.isTemplate = false,
  });

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  final TextEditingController _taskNameController = TextEditingController();
  RepeatType _repeatType = RepeatType.none;
  Set<int> _selectedWeekdays = {};
  Set<int> _selectedMonthDays = {};
  DateTime _startDate = DateTime.now();
  String? _selectedCategoryId;

  // カテゴリ定義
  final List<Map<String, dynamic>> _categories = [
    {'id': 'toilet', 'name': 'トイレ', 'icon': Icons.wc},
    {'id': 'kitchen', 'name': 'キッチン', 'icon': Icons.kitchen},
    {'id': 'living', 'name': 'リビング', 'icon': Icons.living},
    {'id': 'bedroom', 'name': '寝室', 'icon': Icons.hotel},
    {'id': 'bath', 'name': 'お風呂', 'icon': Icons.bathtub},
    {'id': 'garbage', 'name': 'ゴミ出し', 'icon': Icons.delete},
    {'id': null, 'name': 'その他', 'icon': Icons.more_horiz},
  ];

  @override
  void initState() {
    super.initState();
    _taskNameController.text = widget.initialTaskName ?? '';
    _selectedCategoryId = widget.categoryId;
  }

  @override
  void dispose() {
    _taskNameController.dispose();
    super.dispose();
  }

  void _saveTask() async {
    if (_taskNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('タスク名を入力してください')),
      );
      return;
    }

    String? repeatValue;
    if (_repeatType == RepeatType.weekly && _selectedWeekdays.isNotEmpty) {
      repeatValue = _selectedWeekdays.join(',');
    } else if (_repeatType == RepeatType.monthly &&
        _selectedMonthDays.isNotEmpty) {
      repeatValue = _selectedMonthDays.join(',');
    }

    final viewModel = context.read<TaskViewModel>();
    await viewModel.addTask(
      title: _taskNameController.text.trim(),
      categoryId: _selectedCategoryId,
      repeatType: _repeatType,
      repeatValue: repeatValue,
      createdAt: _startDate,
    );

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  String _getCategoryName(String? categoryId) {
    final category = _categories.firstWhere(
      (c) => c['id'] == categoryId,
      orElse: () => _categories.last,
    );
    return category['name'] as String;
  }

  IconData _getCategoryIcon(String? categoryId) {
    final category = _categories.firstWhere(
      (c) => c['id'] == categoryId,
      orElse: () => _categories.last,
    );
    return category['icon'] as IconData;
  }

  String _getRepeatTypeName(RepeatType type) {
    switch (type) {
      case RepeatType.none:
        return '繰り返しなし';
      case RepeatType.daily:
        return '毎日';
      case RepeatType.weekly:
        return '毎週';
      case RepeatType.monthly:
        return '毎月';
    }
  }

  IconData _getRepeatTypeIcon(RepeatType type) {
    switch (type) {
      case RepeatType.none:
        return Icons.event_busy;
      case RepeatType.daily:
        return Icons.refresh;
      case RepeatType.weekly:
        return Icons.calendar_view_week;
      case RepeatType.monthly:
        return Icons.calendar_month;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.gray800),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'タスクを追加',
          style: AppTextStyles.h2.copyWith(fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // テンプレートの場合はタスク名を表示のみ
                    if (widget.isTemplate) ...[
                      Text('タスク名', style: AppTextStyles.label),
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: AppColors.gray50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Text(
                              widget.initialTaskName ?? '',
                              style: AppTextStyles.body.copyWith(
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                    ],

                    // 自由入力の場合はタスク名とカテゴリーを編集可能
                    if (!widget.isTemplate) ...[
                      // タスク名
                      Text('タスク名', style: AppTextStyles.label),
                      const SizedBox(height: AppSpacing.sm),
                      TextField(
                        controller: _taskNameController,
                        decoration: InputDecoration(
                          hintText: 'タスク名を入力',
                          hintStyle: AppTextStyles.body.copyWith(
                            color: AppColors.gray400,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: AppColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                                color: AppColors.gray800, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.md,
                          ),
                        ),
                        style: AppTextStyles.body,
                      ),

                      const SizedBox(height: AppSpacing.xxl),

                      // カテゴリー（ドロップダウン）
                      Text('カテゴリー', style: AppTextStyles.label),
                      const SizedBox(height: AppSpacing.sm),
                      _buildCategoryDropdown(),

                      const SizedBox(height: AppSpacing.xxl),
                    ],

                    // 開始日（共通）
                    Text('開始日', style: AppTextStyles.label),
                    const SizedBox(height: AppSpacing.sm),
                    _buildDateSelector(),

                    const SizedBox(height: AppSpacing.xxl),

                    // 繰り返し（ドロップダウン・共通）
                    Text('繰り返し', style: AppTextStyles.label),
                    const SizedBox(height: AppSpacing.sm),
                    _buildRepeatTypeDropdown(),

                    if (_repeatType == RepeatType.weekly) ...[
                      const SizedBox(height: AppSpacing.lg),
                      _buildWeekdaySelector(),
                    ],

                    if (_repeatType == RepeatType.monthly) ...[
                      const SizedBox(height: AppSpacing.lg),
                      _buildMonthDaySelector(),
                    ],
                  ],
                ),
              ),
            ),

            // 保存ボタン
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.border, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.lg,
                        ),
                      ),
                      child: Text(
                        'キャンセル',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.gray600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _saveTask,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gray800,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.lg,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('保存', style: AppTextStyles.body),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return GestureDetector(
      onTap: () async {
        final selected = await showModalBottomSheet<String?>(
          context: context,
          backgroundColor: AppColors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.gray300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ..._categories.map((category) {
                    return ListTile(
                      leading: Icon(
                        category['icon'] as IconData,
                        color: AppColors.gray600,
                      ),
                      title: Text(
                        category['name'] as String,
                        style: AppTextStyles.body,
                      ),
                      trailing: _selectedCategoryId == category['id']
                          ? const Icon(Icons.check, color: AppColors.gray800)
                          : null,
                      onTap: () => Navigator.pop(context, category['id']),
                    );
                  }).toList(),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            );
          },
        );

        if (selected != null || selected == null) {
          setState(() {
            _selectedCategoryId = selected;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              _getCategoryIcon(_selectedCategoryId),
              color: AppColors.gray600,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              _getCategoryName(_selectedCategoryId),
              style: AppTextStyles.body,
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: AppColors.gray400),
          ],
        ),
      ),
    );
  }

  Widget _buildRepeatTypeDropdown() {
    return GestureDetector(
      onTap: () async {
        final selected = await showModalBottomSheet<RepeatType>(
          context: context,
          backgroundColor: AppColors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.gray300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ...RepeatType.values.map((type) {
                    return ListTile(
                      leading: Icon(
                        _getRepeatTypeIcon(type),
                        color: AppColors.gray600,
                      ),
                      title: Text(
                        _getRepeatTypeName(type),
                        style: AppTextStyles.body,
                      ),
                      trailing: _repeatType == type
                          ? const Icon(Icons.check, color: AppColors.gray800)
                          : null,
                      onTap: () => Navigator.pop(context, type),
                    );
                  }).toList(),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            );
          },
        );

        if (selected != null) {
          setState(() {
            _repeatType = selected;
            // 繰り返しタイプが変わったら選択をクリア
            _selectedWeekdays.clear();
            _selectedMonthDays.clear();
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              _getRepeatTypeIcon(_repeatType),
              color: AppColors.gray600,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              _getRepeatTypeName(_repeatType),
              style: AppTextStyles.body,
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: AppColors.gray400),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _startDate,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          locale: const Locale('ja', 'JP'),
        );
        if (picked != null) {
          setState(() {
            _startDate = picked;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today,
                color: AppColors.gray600, size: 20),
            const SizedBox(width: AppSpacing.md),
            Text(
              '${_startDate.year}年${_startDate.month}月${_startDate.day}日(${_getWeekdayName(_startDate.weekday)})',
              style: AppTextStyles.body,
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: AppColors.gray400),
          ],
        ),
      ),
    );
  }

  String _getWeekdayName(int weekday) {
    const weekdays = ['月', '火', '水', '木', '金', '土', '日'];
    return weekdays[weekday - 1];
  }

  Widget _buildWeekdaySelector() {
    const weekdays = [
      {'value': 1, 'label': '月'},
      {'value': 2, 'label': '火'},
      {'value': 3, 'label': '水'},
      {'value': 4, 'label': '木'},
      {'value': 5, 'label': '金'},
      {'value': 6, 'label': '土'},
      {'value': 0, 'label': '日'},
    ];

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: weekdays.map((day) {
        final value = day['value'] as int;
        final isSelected = _selectedWeekdays.contains(value);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedWeekdays.remove(value);
              } else {
                _selectedWeekdays.add(value);
              }
            });
          },
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.gray800 : AppColors.white,
              border: Border.all(
                color: isSelected ? AppColors.gray800 : AppColors.border,
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                day['label'] as String,
                style: AppTextStyles.body.copyWith(
                  color: isSelected ? AppColors.white : AppColors.gray800,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMonthDaySelector() {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: List.generate(31, (index) {
        final day = index + 1;
        final isSelected = _selectedMonthDays.contains(day);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedMonthDays.remove(day);
              } else {
                _selectedMonthDays.add(day);
              }
            });
          },
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.gray800 : AppColors.white,
              border: Border.all(
                color: isSelected ? AppColors.gray800 : AppColors.border,
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                day.toString(),
                style: AppTextStyles.body.copyWith(
                  color: isSelected ? AppColors.white : AppColors.gray800,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
