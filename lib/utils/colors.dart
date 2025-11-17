import 'package:flutter/material.dart';

/// アプリ全体のカラーパレット
/// エレガント＆シンプルなデザインのための色定義
class AppColors {
  // プライベートコンストラクタ（インスタンス化を防ぐ）
  AppColors._();

  // ベースカラー
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFFAFAFA);
  static const Color background = Color(0xFFFFFFFF);

  // グレースケール
  static const Color gray800 = Color(0xFF2D3748);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray600 = Color(0xFF4A5568);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray400 = Color(0xFFA0AEC0);
  static const Color gray300 = Color(0xFFCBD5E0);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray100 = Color(0xFFF7FAFC);
  static const Color gray50 = Color(0xFFFAFAFA);

  // アクセントカラー（控えめ）
  static const Color primary = Color(0xFF2D3748);
  static const Color accent = Color(0xFF718096);

  // システムカラー
  static const Color success = Color(0xFF48BB78);
  static const Color error = Color(0xFFF56565);
  static const Color warning = Color(0xFFF6AD55);
  static const Color info = Color(0xFF4299E1);

  // テキストカラー
  static const Color textPrimary = gray800;
  static const Color textSecondary = gray600;
  static const Color textTertiary = gray400;
  static const Color textDisabled = gray300;

  // ボーダーカラー
  static const Color border = gray100;
  static const Color borderHover = gray300;
  static const Color borderActive = gray800;

  // 背景カラー
  static const Color cardBackground = white;
  static const Color surfaceBackground = gray50;
}
