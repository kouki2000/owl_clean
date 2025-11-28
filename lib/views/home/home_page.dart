import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/walking_cat.dart';
import '../../widgets/task_card.dart';
import '../../widgets/floating_balloon.dart';
import '../../viewmodels/task_viewmodel.dart';
import '../../widgets/celebration_overlay.dart';

/// ホーム画面
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _hasShownCelebration = false;
  final Map<String, GlobalKey<FloatingBalloonState>> _balloonKeys = {};

  void _toggleTask(String id) async {
    final viewModel = context.read<TaskViewModel>();
    final task = viewModel.tasks.firstWhere((t) => t.id == id);

    if (!task.isCompleted && _balloonKeys.containsKey(id)) {
      _balloonKeys[id]?.currentState?.pop();
      await Future.delayed(const Duration(milliseconds: 400));
    }

    await viewModel.toggleTaskCompletion(id, DateTime.now());
  }

  Future<void> _deleteTask(String id, String title) async {
    final viewModel = context.read<TaskViewModel>();

    if (_balloonKeys.containsKey(id)) {
      _balloonKeys[id]?.currentState?.pop();
      await Future.delayed(const Duration(milliseconds: 400));
    }

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
          if (viewModel.isLoading && viewModel.tasks.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.gray800),
            );
          }

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
          final incompleteTasks =
              todayTasks.where((task) => !task.isCompleted).toList();
          final completedCount =
              todayTasks.where((task) => task.isCompleted).length;
          final totalCount = todayTasks.length;
          final allCompleted = totalCount > 0 && completedCount == totalCount;

          if (allCompleted && !_hasShownCelebration) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showCelebration(context);
            });
          }

          if (!allCompleted) {
            _hasShownCelebration = false;
          }

          return SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // 猫と風船のエリア
                        SizedBox(
                          height: 220,
                          child: Center(
                            child: SizedBox(
                              width: 280,
                              height: 220,
                              child: Stack(
                                children: [
                                  // 猫（中央）
                                  Center(
                                    child: WalkingCat(
                                      size: 100,
                                      isSleeping:
                                          incompleteTasks.isEmpty, // ⚠️ ここを追加
                                    ),
                                  ),

                                  // 風船（円形に均等配置）
                                  ..._buildCircularBalloons(incompleteTasks),
                                ],
                              ),
                            ),
                          ),
                        ),

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
                                return false;
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

  /// 円形に風船を配置
  List<Widget> _buildCircularBalloons(List<dynamic> tasks) {
    if (tasks.isEmpty) return [];

    final balloons = <Widget>[];
    final radius = 100.0; // 円の半径
    final centerX = 140.0; // 中心X座標
    final centerY = 110.0; // 中心Y座標

    for (int i = 0; i < tasks.length; i++) {
      final task = tasks[i];

      // 角度を計算（-90度から開始して時計回り）
      final angle = (i * 2 * math.pi / tasks.length) - (math.pi / 2);

      // 円周上の座標を計算
      final x = centerX + radius * math.cos(angle) - 25; // -25はアイコンサイズの半分
      final y = centerY + radius * math.sin(angle) - 25;

      _balloonKeys[task.id] ??= GlobalKey<FloatingBalloonState>();

      balloons.add(
        Positioned(
          left: x,
          top: y,
          child: FloatingBalloon(
            key: _balloonKeys[task.id],
            icon: CategoryIconHelper.getIcon(task.categoryId),
            size: 50,
            floatDuration: Duration(milliseconds: 2500 + (i * 200)),
            onPop: () {
              setState(() {
                _balloonKeys.remove(task.id);
              });
            },
          ),
        ),
      );
    }

    return balloons;
  }

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
