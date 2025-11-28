import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';

/// タスクカードウィジェット
class TaskCard extends StatelessWidget {
  final String title;
  final bool isCompleted;
  final VoidCallback onCheckboxTap;

  const TaskCard({
    super.key,
    required this.title,
    required this.isCompleted,
    required this.onCheckboxTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: 4,
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isCompleted ? AppColors.gray50 : AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // チェックボックス
          GestureDetector(
            onTap: onCheckboxTap,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted ? AppColors.gray800 : AppColors.gray300,
                  width: 2,
                ),
                color: isCompleted ? AppColors.gray800 : Colors.transparent,
              ),
              child: isCompleted
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: AppColors.white,
                    )
                  : null,
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          // タスク名
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.body.copyWith(
                decoration: isCompleted ? TextDecoration.lineThrough : null,
                color: isCompleted ? AppColors.gray400 : AppColors.gray800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
