import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';

/// カスタムボトムナビゲーションバー
class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<NavItem> items;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.sm,
            horizontal: AppSpacing.md,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              items.length,
              (index) => _buildNavItem(
                item: items[index],
                isSelected: currentIndex == index,
                onTap: () => onTap(index),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required NavItem item,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // アイコン
            Icon(
              item.icon,
              size: 24,
              color: isSelected ? AppColors.gray800 : AppColors.gray400,
            ),
            const SizedBox(height: 4),
            // ラベル
            Text(
              item.label,
              style: AppTextStyles.caption.copyWith(
                fontSize: 11,
                color: isSelected ? AppColors.gray800 : AppColors.gray400,
                fontWeight: isSelected ? FontWeight.w400 : FontWeight.w300,
              ),
            ),
            // 選択インジケーター
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 2),
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: AppColors.gray800,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// ナビゲーションアイテム
class NavItem {
  final IconData icon;
  final String label;
  final String? imagePath; // 後方互換性のために残す

  const NavItem({
    required this.icon,
    required this.label,
    this.imagePath,
  });
}
