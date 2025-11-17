import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/colors.dart';

/// ナビゲーションアイテムのデータ
class NavItem {
  final IconData icon;
  final String label;

  const NavItem({required this.icon, required this.label});
}

/// カスタムボトムナビゲーションバー
///
/// エレガント＆シンプルなデザインに合わせた
/// ミニマルなナビゲーションバー
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
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.9),
        border: const Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isActive = currentIndex == index;

                  return _NavButton(
                    icon: item.icon,
                    label: item.label,
                    isActive: isActive,
                    onTap: () => onTap(index),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ナビゲーションボタン
class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // アイコン部分
            Stack(
              alignment: Alignment.center,
              children: [
                // フクロウ画像（実装時に画像パスを使用）
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.gray100 : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/images/owl_character.png',
                      width: 24,
                      height: 24,
                      color: isActive ? null : AppColors.gray300,
                      colorBlendMode: isActive ? null : BlendMode.saturation,
                      errorBuilder: (context, error, stackTrace) {
                        // 画像がない場合はアイコンで代替
                        return Icon(
                          icon,
                          size: 20,
                          color: isActive
                              ? AppColors.gray800
                              : AppColors.gray300,
                        );
                      },
                    ),
                  ),
                ),

                // 機能アイコン（右下）
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        icon,
                        size: 10,
                        color: isActive ? AppColors.gray800 : AppColors.gray300,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // アクティブインジケーター
            if (isActive) ...[
              const SizedBox(height: 8),
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: AppColors.gray800,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
