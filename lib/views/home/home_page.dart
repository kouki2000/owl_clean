import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/owl_character.dart';
import '../../widgets/task_card.dart';
import '../../viewmodels/task_viewmodel.dart';
import '../../widgets/celebration_overlay.dart';

/// ホーム画面
///
/// 今日のタスク一覧を表示
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  OwlMood owlMood = OwlMood.happy;
  bool _hasShownCelebration = false;

  void _toggleTask(String id) async {
    final viewModel = context.read<TaskViewModel>();

    // フクロウの表情を変更
    setState(() {
      owlMood = OwlMood.excited;
    });

    // タスクの完了状態を切り替え（今日の日付で）
    await viewModel.toggleTaskCompletion(id, DateTime.now());

    // 2秒後に通常に戻す
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          owlMood = OwlMood.happy;
        });
      }
    });
  }

  /// タスクを削除
  Future<void> _deleteTask(String id, String title) async {
    final viewModel = context.read<TaskViewModel>();

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
      await viewModel.deleteTask(id);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Consumer<TaskViewModel>(
        builder: (context, viewModel, child) {
          // ローディング中
          if (viewModel.isLoading && viewModel.tasks.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.gray800),
            );
          }

          // エラー表示
          if (viewModel.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('⚠️', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    viewModel.error!,
                    style: AppTextStyles.body,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ElevatedButton(
                    onPressed: () => viewModel.loadTasks(),
                    child: const Text('再読み込み'),
                  ),
                ],
              ),
            );
          }

          final todayTasks = viewModel.todayTasks;
          final completedCount =
              todayTasks.where((task) => task.isCompleted).length;
          final totalCount = todayTasks.length;
          final allCompleted = totalCount > 0 && completedCount == totalCount;

          // 全タスク完了時に祝福オーバーレイを表示
          if (allCompleted && !_hasShownCelebration) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showCelebration(context);
            });
          }

          // タスクが未完了になったらフラグをリセット
          if (!allCompleted) {
            _hasShownCelebration = false;
          }

          return SafeArea(
            child: Column(
              children: [
                // ヘッダー
                _buildHeader(),

                // メインコンテンツ
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: AppSpacing.xl),

                        // フクロウキャラクター
                        OwlCharacter(mood: owlMood, size: 80),

                        const SizedBox(height: AppSpacing.xl),

                        // セクションタイトル
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xl,
                          ),
                          child: Row(
                            children: [
                              Text(
                                "Today's Focus".toUpperCase(),
                                style: AppTextStyles.label,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        // タスクリスト
                        if (todayTasks.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(AppSpacing.xxl),
                            child: Column(
                              children: [
                                const Text('✨', style: TextStyle(fontSize: 48)),
                                const SizedBox(height: AppSpacing.md),
                                Text(
                                  '今日のタスクはありません',
                                  style: AppTextStyles.body.copyWith(
                                    color: AppColors.gray400,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          ...todayTasks.map((task) {
                            return Dismissible(
                              key: Key(task.id),
                              direction: DismissDirection.endToStart,
                              confirmDismiss: (direction) async {
                                return false; // ダイアログで確認するのでfalse
                              },
                              onDismissed: (direction) {
                                // 実際には呼ばれない
                              },
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding:
                                    const EdgeInsets.only(right: AppSpacing.xl),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.lg,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.error,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.delete_outline,
                                  color: AppColors.white,
                                  size: 24,
                                ),
                              ),
                              child: GestureDetector(
                                onHorizontalDragEnd: (details) {
                                  if (details.primaryVelocity! < 0) {
                                    _deleteTask(task.id, task.title);
                                  }
                                },
                                child: TaskCard(
                                  title: task.title,
                                  isCompleted: task.isCompleted,
                                  onCheckboxTap: () => _toggleTask(task.id),
                                ),
                              ),
                            );
                          }).toList(),

                        const SizedBox(height: AppSpacing.xxl),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 祝福オーバーレイを表示
  void _showCelebration(BuildContext context) {
    setState(() {
      _hasShownCelebration = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (context) => CelebrationOverlay(
        onClose: () => Navigator.of(context).pop(),
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
          // アプリ名とサブタイトル
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppConstants.appName, style: AppTextStyles.h1),
              const SizedBox(height: 4),
              Text(AppConstants.appSubtitle, style: AppTextStyles.caption),
            ],
          ),
        ],
      ),
    );
  }
}
