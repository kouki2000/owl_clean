import 'package:flutter/material.dart';

/// アプリ定数
class AppConstants {
  // アプリ情報
  static const String appName = '猫とお掃除';
  static const String appVersion = '1.0.0';

  // 繰り返し設定
  static const List<Map<String, String>> repeatOptions = [
    {'value': 'none', 'label': 'なし'},
    {'value': 'daily', 'label': '毎日'},
    {'value': 'weekly', 'label': '毎週'},
    {'value': 'monthly', 'label': '毎月'},
  ];

  // 曜日
  static const List<Map<String, dynamic>> weekdays = [
    {'value': 0, 'label': '日'},
    {'value': 1, 'label': '月'},
    {'value': 2, 'label': '火'},
    {'value': 3, 'label': '水'},
    {'value': 4, 'label': '木'},
    {'value': 5, 'label': '金'},
    {'value': 6, 'label': '土'},
  ];
}

/// スペーシング
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
}

/// テキストスタイル
class AppTextStyles {
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w300,
    letterSpacing: -0.5,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.5,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w300,
    letterSpacing: 0.5,
  );

  static const TextStyle label = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w300,
    letterSpacing: 1.5,
    color: Color(0xFF9E9E9E),
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w300,
    color: Color(0xFFBDBDBD),
  );
}
