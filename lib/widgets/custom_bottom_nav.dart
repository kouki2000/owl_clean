import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/colors.dart';

/// ナビゲーションアイテムのデータ
class NavItem {
  final IconData icon;
  final String label;
  final String? imagePath; // 画像パス（オプション）

  const NavItem({required this.icon, required this.label, this.imagePath});
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
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isActive = currentIndex == index;

                  return _NavButton(
                    icon: item.icon,
                    label: item.label,
                    imagePath: item.imagePath,
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
  final String? imagePath;
  final bool isActive;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.label,
    this.imagePath,
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
            SizedBox(
              width: 36,
              height: 36,
              child: imagePath != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: ColorFiltered(
                        colorFilter: isActive
                            ? const ColorFilter.mode(
                                Colors.transparent,
                                BlendMode.multiply,
                              )
                            : ColorFilter.mode(
                                Colors.grey.withOpacity(0.5),
                                BlendMode.saturation,
                              ),
                        child: Image.asset(
                          imagePath!,
                          width: 36,
                          height: 36,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            // デバッグ用：エラー表示
                            print('画像読み込みエラー: $imagePath - $error');
                            return Icon(
                              icon,
                              size: 24,
                              color: isActive
                                  ? AppColors.gray800
                                  : AppColors.gray300,
                            );
                          },
                        ),
                      ),
                    )
                  : Icon(
                      icon,
                      size: 24,
                      color: isActive ? AppColors.gray800 : AppColors.gray300,
                    ),
            ),

            const SizedBox(height: 4),

            // ラベル
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w300,
                color: isActive ? AppColors.gray800 : AppColors.gray400,
                height: 1.2,
              ),
            ),

            const SizedBox(height: 4),

            // アクティブインジケーター
            if (isActive)
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: AppColors.gray800,
                  shape: BoxShape.circle,
                ),
              )
            else
              const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
