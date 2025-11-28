import 'package:flutter/material.dart';
import 'dart:math' as math;

/// 歩く猫のアニメーションウィジェット
class WalkingCat extends StatefulWidget {
  final double size;
  final bool isSleeping;

  const WalkingCat({
    super.key,
    this.size = 100,
    this.isSleeping = false,
  });

  @override
  State<WalkingCat> createState() => _WalkingCatState();
}

class _WalkingCatState extends State<WalkingCat>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: widget.isSleeping
              ? SleepingCatPainter(animationProgress: _animation.value)
              : SittingCatPainter(animationProgress: _animation.value),
        );
      },
    );
  }
}

/// 座っている猫を描画するカスタムペインター
class SittingCatPainter extends CustomPainter {
  final double animationProgress;

  SittingCatPainter({required this.animationProgress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final scale = size.width / 100;
    final bobOffset = math.sin(animationProgress * math.pi) * 2 * scale;
    final centerX = size.width / 2;
    final baseY = size.height * 0.7;

    canvas.save();
    canvas.translate(0, bobOffset);

    // 尻尾
    final tailPath = Path();
    final tailSwing = math.sin(animationProgress * math.pi * 2) * 10 * scale;
    tailPath.moveTo(centerX + 18 * scale, baseY - 20 * scale);
    tailPath.quadraticBezierTo(
      centerX + 30 * scale + tailSwing,
      baseY - 35 * scale,
      centerX + 25 * scale + tailSwing,
      baseY - 50 * scale,
    );
    tailPath.quadraticBezierTo(
      centerX + 22 * scale + tailSwing,
      baseY - 55 * scale,
      centerX + 18 * scale + tailSwing,
      baseY - 52 * scale,
    );
    canvas.drawPath(tailPath, paint);

    // 後ろ足
    final backLegPath = Path();
    backLegPath.moveTo(centerX + 8 * scale, baseY - 15 * scale);
    backLegPath.lineTo(centerX + 12 * scale, baseY - 5 * scale);
    backLegPath.lineTo(centerX + 15 * scale, baseY);
    backLegPath.lineTo(centerX + 10 * scale, baseY);
    backLegPath.close();
    canvas.drawPath(backLegPath, paint);

    // 体
    final bodyRect = Rect.fromCenter(
      center: Offset(centerX, baseY - 20 * scale),
      width: 35 * scale,
      height: 40 * scale,
    );
    canvas.drawOval(bodyRect, paint);

    // 前足
    final frontLegPath = Path();
    frontLegPath.moveTo(centerX - 8 * scale, baseY - 10 * scale);
    frontLegPath.lineTo(centerX - 8 * scale, baseY);
    frontLegPath.lineTo(centerX - 3 * scale, baseY);
    frontLegPath.lineTo(centerX - 3 * scale, baseY - 10 * scale);
    frontLegPath.close();
    canvas.drawPath(frontLegPath, paint);

    // 胸
    final chestPath = Path();
    chestPath.moveTo(centerX - 15 * scale, baseY - 25 * scale);
    chestPath.quadraticBezierTo(
      centerX - 18 * scale,
      baseY - 15 * scale,
      centerX - 15 * scale,
      baseY - 5 * scale,
    );
    chestPath.lineTo(centerX - 10 * scale, baseY - 5 * scale);
    chestPath.lineTo(centerX - 10 * scale, baseY - 25 * scale);
    chestPath.close();
    canvas.drawPath(chestPath, paint);

    // 頭
    final headRect = Rect.fromCenter(
      center: Offset(centerX - 12 * scale, baseY - 40 * scale),
      width: 25 * scale,
      height: 28 * scale,
    );
    canvas.drawOval(headRect, paint);

    // 耳（左）
    final leftEarPath = Path();
    leftEarPath.moveTo(centerX - 20 * scale, baseY - 48 * scale);
    leftEarPath.lineTo(centerX - 25 * scale, baseY - 58 * scale);
    leftEarPath.lineTo(centerX - 15 * scale, baseY - 52 * scale);
    leftEarPath.close();
    canvas.drawPath(leftEarPath, paint);

    // 耳（右）
    final rightEarPath = Path();
    rightEarPath.moveTo(centerX - 4 * scale, baseY - 50 * scale);
    rightEarPath.lineTo(centerX - 2 * scale, baseY - 58 * scale);
    rightEarPath.lineTo(centerX - 10 * scale, baseY - 53 * scale);
    rightEarPath.close();
    canvas.drawPath(rightEarPath, paint);

    // 鼻・口
    final snoutPath = Path();
    snoutPath.moveTo(centerX - 22 * scale, baseY - 38 * scale);
    snoutPath.lineTo(centerX - 25 * scale, baseY - 35 * scale);
    snoutPath.lineTo(centerX - 22 * scale, baseY - 32 * scale);
    snoutPath.close();
    canvas.drawPath(snoutPath, paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(SittingCatPainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress;
  }
}

/// 寝ている猫を描画するカスタムペインター
class SleepingCatPainter extends CustomPainter {
  final double animationProgress;

  SleepingCatPainter({required this.animationProgress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final scale = size.width / 100;
    final breatheOffset = math.sin(animationProgress * math.pi) * 1.5 * scale;

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    canvas.save();

    // 体（横向き・楕円形）
    final bodyRect = Rect.fromCenter(
      center: Offset(centerX, centerY + breatheOffset),
      width: 50 * scale,
      height: 30 * scale,
    );
    canvas.drawOval(bodyRect, paint);

    // 頭（体の左側に丸まっている）
    final headRect = Rect.fromCenter(
      center: Offset(centerX - 15 * scale, centerY - 5 * scale + breatheOffset),
      width: 20 * scale,
      height: 22 * scale,
    );
    canvas.drawOval(headRect, paint);

    // 耳（小さめ）
    final leftEarPath = Path();
    leftEarPath.moveTo(
        centerX - 22 * scale, centerY - 12 * scale + breatheOffset);
    leftEarPath.lineTo(
        centerX - 25 * scale, centerY - 18 * scale + breatheOffset);
    leftEarPath.lineTo(
        centerX - 18 * scale, centerY - 14 * scale + breatheOffset);
    leftEarPath.close();
    canvas.drawPath(leftEarPath, paint);

    final rightEarPath = Path();
    rightEarPath.moveTo(
        centerX - 12 * scale, centerY - 14 * scale + breatheOffset);
    rightEarPath.lineTo(
        centerX - 10 * scale, centerY - 20 * scale + breatheOffset);
    rightEarPath.lineTo(
        centerX - 15 * scale, centerY - 15 * scale + breatheOffset);
    rightEarPath.close();
    canvas.drawPath(rightEarPath, paint);

    // 尻尾（体に沿って丸まっている）
    final tailPath = Path();
    tailPath.moveTo(centerX + 25 * scale, centerY + 5 * scale + breatheOffset);
    tailPath.quadraticBezierTo(
      centerX + 30 * scale,
      centerY - 5 * scale + breatheOffset,
      centerX + 20 * scale,
      centerY - 8 * scale + breatheOffset,
    );
    canvas.drawPath(tailPath, paint);

    // 足（軽く見える程度）
    final legPath = Path();
    legPath.moveTo(centerX - 5 * scale, centerY + 10 * scale + breatheOffset);
    legPath.lineTo(centerX - 5 * scale, centerY + 15 * scale + breatheOffset);
    legPath.lineTo(centerX, centerY + 15 * scale + breatheOffset);
    legPath.lineTo(centerX, centerY + 10 * scale + breatheOffset);
    legPath.close();
    canvas.drawPath(legPath, paint);

    canvas.restore();

    // Zzzマーク（浮かび上がる）
    _drawZzz(canvas, size, scale, animationProgress);
  }

  void _drawZzz(Canvas canvas, Size size, double scale, double progress) {
    final textPaint = Paint()
      ..color = Colors.black.withOpacity(0.3 + progress * 0.4)
      ..style = PaintingStyle.fill;

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Z の文字を描画
    final textSpan = TextSpan(
      text: 'Z',
      style: TextStyle(
        color: Colors.black.withOpacity(0.3 + progress * 0.4),
        fontSize: 20 * scale,
        fontWeight: FontWeight.bold,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    // 3つのZを異なる高さに配置
    final positions = [
      Offset(centerX + 20 * scale, centerY - 25 * scale - progress * 5 * scale),
      Offset(centerX + 28 * scale, centerY - 20 * scale - progress * 8 * scale),
      Offset(
          centerX + 35 * scale, centerY - 15 * scale - progress * 10 * scale),
    ];

    for (int i = 0; i < 3; i++) {
      canvas.save();
      canvas.translate(positions[i].dx, positions[i].dy);
      canvas.scale(0.7 + i * 0.15);
      textPainter.paint(canvas, Offset.zero);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(SleepingCatPainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress;
  }
}
