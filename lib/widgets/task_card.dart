import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';

/// タスクカードウィジェット
///
/// エレガント＆シンプルなデザインのタスク表示カード
class TaskCard extends StatelessWidget {
  final String title;
  final bool isCompleted;
  final int progress;
  final VoidCallback? onTap;
  final VoidCallback? onCheckboxTap;

  const TaskCard({
    super.key,
    required this.title,
    this.isCompleted = false,
    this.progress = 0,
    this.onTap,
    this.onCheckboxTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        opacity: isCompleted ? 0.6 : 1.0,
        duration: AppDurations.normal,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.lg,
          ),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.border, width: 1),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // チェックボックス
              GestureDetector(
                onTap: onCheckboxTap,
                child: AnimatedContainer(
                  duration: AppDurations.fast,
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    color: isCompleted ? AppColors.gray800 : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCompleted
                          ? AppColors.gray800
                          : AppColors.gray300,
                      width: 2,
                    ),
                  ),
                  child: isCompleted
                      ? const Icon(
                          Icons.check,
                          size: 12,
                          color: AppColors.white,
                        )
                      : null,
                ),
              ),

              const SizedBox(width: AppSpacing.lg),

              // タイトルと進捗バー
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // タイトル
                    Text(
                      title,
                      style: AppTextStyles.h3.copyWith(
                        fontWeight: FontWeight.w300,
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        color: isCompleted
                            ? AppColors.gray400
                            : AppColors.gray800,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // 進捗バーと進捗率
                    Row(
                      children: [
                        // 進捗バー
                        Expanded(
                          child: Stack(
                            children: [
                              // 背景
                              Container(height: 1, color: AppColors.gray100),
                              // 進捗
                              AnimatedContainer(
                                duration: AppDurations.slow,
                                height: 1,
                                width:
                                    MediaQuery.of(context).size.width *
                                    (progress / 100),
                                color: AppColors.gray800,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: AppSpacing.md),

                        // 進捗率
                        SizedBox(
                          width: 36,
                          child: Text(
                            '$progress%',
                            style: AppTextStyles.caption.copyWith(
                              fontWeight: FontWeight.w300,
                              color: AppColors.gray400,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
