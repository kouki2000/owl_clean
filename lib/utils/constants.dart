import 'package:flutter/material.dart';
import 'colors.dart';

/// アプリ全体で使用する定数
class AppConstants {
  AppConstants._();

  // アプリ情報
  static const String appName = 'CleanUp';
  static const String appVersion = '1.0.0';
  static const String appSubtitle = 'Clean living, Clear mind';
}

/// スペーシング定数
class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

/// タイポグラフィ（テキストスタイル）
class AppTextStyles {
  AppTextStyles._();

  // 見出し1（ページタイトル）
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w300,
    letterSpacing: -0.5,
    color: AppColors.gray800,
    height: 1.2,
  );

  // 見出し2（セクションタイトル）
  static const TextStyle h2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.3,
    color: AppColors.gray800,
    height: 1.3,
  );

  // 見出し3（カードタイトル）
  static const TextStyle h3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.2,
    color: AppColors.gray800,
    height: 1.4,
  );

  // 本文
  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.gray600,
    height: 1.5,
  );

  // 小さい本文
  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.gray600,
    height: 1.5,
  );

  // キャプション
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w300,
    letterSpacing: 0.5,
    color: AppColors.gray400,
    height: 1.4,
  );

  // ラベル（大文字）
  static const TextStyle label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w300,
    letterSpacing: 1.2,
    color: AppColors.gray400,
    height: 1.4,
  );

  // ボタンテキスト
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    color: AppColors.white,
    height: 1.2,
  );
}

/// ボーダー半径
class AppBorderRadius {
  AppBorderRadius._();

  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double full = 9999.0;
}

/// シャドウ
class AppShadows {
  AppShadows._();

  // 軽いシャドウ
  static const List<BoxShadow> light = [
    BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 2)),
  ];

  // 通常のシャドウ
  static const List<BoxShadow> normal = [
    BoxShadow(color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, 4)),
  ];

  // 強いシャドウ
  static const List<BoxShadow> strong = [
    BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, 8)),
  ];
}

/// アニメーション時間
class AppDurations {
  AppDurations._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
}
