import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../viewmodels/task_viewmodel.dart';
import '../../models/task.dart';
import '../../models/task_category.dart';
import '../../services/database_service.dart';

/// タスク管理画面
class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  List<TaskCategory> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categories = await DatabaseService.instance.getCategories();
    setState(() {
      _categories = categories;
    });
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

            // タスク一覧
            Expanded(
              child: Consumer<TaskViewModel>(
                builder: (context, viewModel, child) {
                  final tasks = viewModel.tasks;

                  if (tasks.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('✨', style: TextStyle(fontSize: 48)),
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            'タスクがありません',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.gray400,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          ElevatedButton.icon(
                            onPressed: () => _showAddTaskDialog(context),
                            icon: const Icon(Icons.add, size: 20),
                            label: const Text('タスクを追加'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.gray800,
                              foregroundColor: AppColors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xl,
                                vertical: AppSpacing.md,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return _buildTaskItem(task, viewModel);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // フローティングボタン
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context),
        backgroundColor: AppColors.gray800,
        child: const Icon(Icons.add, color: AppColors.white),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('タスク管理', style: AppTextStyles.h1),
          Consumer<TaskViewModel>(
            builder: (context, viewModel, child) {
              return Text(
                '${viewModel.tasks.length}件',
                style: AppTextStyles.caption,
              );
            },
          ),
        ],
      ),
    );
  }

  /// タスクアイテム
  Widget _buildTaskItem(Task task, TaskViewModel viewModel) {
    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        color: AppColors.error,
        child: const Icon(Icons.delete_outline, color: AppColors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
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
      },
      onDismissed: (direction) {
        viewModel.deleteTask(task.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('「${task.title}」を削除しました'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // タスク名と完了チェック
            Row(
              children: [
                GestureDetector(
                  onTap: () => viewModel.toggleTaskCompletion(task.id),
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: task.isCompleted
                          ? AppColors.gray800
                          : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: task.isCompleted
                            ? AppColors.gray800
                            : AppColors.gray300,
                        width: 2,
                      ),
                    ),
                    child: task.isCompleted
                        ? const Icon(
                            Icons.check,
                            size: 12,
                            color: AppColors.white,
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    task.title,
                    style: AppTextStyles.h3.copyWith(
                      fontWeight: FontWeight.w300,
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: task.isCompleted
                          ? AppColors.gray400
                          : AppColors.gray800,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // 繰り返し設定
            if (task.repeatType != RepeatType.none)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.gray50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _getRepeatTypeLabel(task.repeatType),
                  style: AppTextStyles.caption.copyWith(fontSize: 11),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 繰り返しタイプのラベルを取得
  String _getRepeatTypeLabel(RepeatType type) {
    switch (type) {
      case RepeatType.daily:
        return '毎日';
      case RepeatType.weekly:
        return '毎週';
      case RepeatType.monthly:
        return '毎月';
      case RepeatType.none:
        return '';
    }
  }

  /// タスク追加ダイアログ
  void _showAddTaskDialog(BuildContext context) {
    final titleController = TextEditingController();
    String? selectedCategoryId;
    RepeatType selectedRepeatType = RepeatType.none;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('タスクを追加'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // タスク名入力
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'タスク名',
                      hintText: '例：床掃除',
                      border: OutlineInputBorder(),
                    ),
                    autofocus: true,
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // カテゴリ選択
                  Text(
                    'カテゴリ',
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: _categories.map((category) {
                      final isSelected = selectedCategoryId == category.id;
                      return ChoiceChip(
                        label: Text(
                          '${category.icon} ${category.name}',
                          style: TextStyle(
                            fontSize: 13,
                            color: isSelected
                                ? AppColors.white
                                : AppColors.gray800,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            selectedCategoryId = selected ? category.id : null;
                          });
                        },
                        selectedColor: AppColors.gray800,
                        backgroundColor: AppColors.gray50,
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // 繰り返し設定
                  Text(
                    '繰り返し',
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      _buildRepeatChip(
                        '繰り返しなし',
                        RepeatType.none,
                        selectedRepeatType,
                        (type) => setState(() => selectedRepeatType = type),
                      ),
                      _buildRepeatChip(
                        '毎日',
                        RepeatType.daily,
                        selectedRepeatType,
                        (type) => setState(() => selectedRepeatType = type),
                      ),
                      _buildRepeatChip(
                        '毎週',
                        RepeatType.weekly,
                        selectedRepeatType,
                        (type) => setState(() => selectedRepeatType = type),
                      ),
                      _buildRepeatChip(
                        '毎月',
                        RepeatType.monthly,
                        selectedRepeatType,
                        (type) => setState(() => selectedRepeatType = type),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('キャンセル'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (titleController.text.trim().isNotEmpty) {
                    // タスクを追加
                    context.read<TaskViewModel>().addTask(
                      title: titleController.text.trim(),
                      categoryId: selectedCategoryId,
                      repeatType: selectedRepeatType,
                    );
                    Navigator.of(dialogContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('タスクを追加しました'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gray800,
                  foregroundColor: AppColors.white,
                ),
                child: const Text('追加'),
              ),
            ],
          );
        },
      ),
    );
  }

  /// 繰り返しチップ
  Widget _buildRepeatChip(
    String label,
    RepeatType type,
    RepeatType selectedType,
    Function(RepeatType) onSelected,
  ) {
    final isSelected = selectedType == type;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          color: isSelected ? AppColors.white : AppColors.gray800,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) => onSelected(type),
      selectedColor: AppColors.gray800,
      backgroundColor: AppColors.gray50,
    );
  }
}
