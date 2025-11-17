import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/owl_character.dart';
import '../../widgets/task_card.dart';

/// ホーム画面
///
/// 今日のタスク一覧を表示
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // サンプルデータ（後でViewModelから取得）
  List<Map<String, dynamic>> tasks = [
    {'id': '1', 'title': '床掃除', 'isCompleted': false, 'progress': 40},
    {'id': '2', 'title': '窓拭き', 'isCompleted': false, 'progress': 0},
    {'id': '3', 'title': 'トイレ掃除', 'isCompleted': true, 'progress': 100},
  ];

  int completedCount = 12;
  OwlMood owlMood = OwlMood.happy;

  void _toggleTask(String id) {
    setState(() {
      final taskIndex = tasks.indexWhere((t) => t['id'] == id);
      if (taskIndex != -1) {
        final task = tasks[taskIndex];
        final newCompleted = !task['isCompleted'];

        tasks[taskIndex] = {
          ...task,
          'isCompleted': newCompleted,
          'progress': newCompleted ? 100 : task['progress'],
        };

        if (newCompleted) {
          completedCount++;
          // フクロウの表情を変更
          owlMood = OwlMood.excited;
          // 2秒後に通常に戻す
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              setState(() {
                owlMood = OwlMood.happy;
              });
            }
          });
        } else {
          completedCount--;
        }
      }
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
                    ...tasks.map((task) {
                      return TaskCard(
                        title: task['title'],
                        isCompleted: task['isCompleted'],
                        progress: task['progress'],
                        onCheckboxTap: () => _toggleTask(task['id']),
                      );
                    }).toList(),

                    const SizedBox(height: AppSpacing.xl),

                    // 統計セクション
                    _buildStatsSection(),

                    const SizedBox(height: AppSpacing.xxl),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

          // 完了数
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$completedCount', style: AppTextStyles.h1),
              const SizedBox(height: 4),
              Text('COMPLETED', style: AppTextStyles.caption),
            ],
          ),
        ],
      ),
    );
  }

  /// 統計セクション
  Widget _buildStatsSection() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Today', '2'),
          _buildStatItem('Week', '12'),
          _buildStatItem('Streak', '5'),
        ],
      ),
    );
  }

  /// 統計アイテム
  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.w300),
        ),
        const SizedBox(height: 4),
        Text(label.toUpperCase(), style: AppTextStyles.caption),
      ],
    );
  }
}
