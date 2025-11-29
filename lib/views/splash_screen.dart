import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../widgets/walking_cat.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2E3B4E),
              Color(0xFF3D4E5C),
            ],
          ),
        ),
        child: Stack(
          children: [
            // キラキラエフェクト
            ...List.generate(25, (index) {
              return SparkleParticle(
                controller: _controller,
                index: index,
              );
            }),

            // メインコンテンツ
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 寝ている猫のアイコン
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: WalkingCat(
                        size: 140,
                        isSleeping: true,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // アプリ名
                  const Text(
                    '猫とお掃除',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // バージョン
                  const Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// キラキラパーティクル
class SparkleParticle extends StatelessWidget {
  final AnimationController controller;
  final int index;

  const SparkleParticle({
    super.key,
    required this.controller,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final random = math.Random(index);
    final startX = random.nextDouble();
    final size = 8 + random.nextDouble() * 8; // 8-16px（大きく）
    final delay = random.nextDouble();

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final progress = ((controller.value + delay) % 1.0);
        final screenHeight = MediaQuery.of(context).size.height;
        final screenWidth = MediaQuery.of(context).size.width;

        // 上から下にゆっくり落ちる（速度を遅く）
        final y = progress * screenHeight;
        final x = startX * screenWidth + math.sin(progress * math.pi * 3) * 30;

        // フェードイン・フェードアウト
        final opacity = progress < 0.1
            ? progress * 10
            : progress > 0.9
                ? (1 - progress) * 10
                : 1.0;

        // 回転アニメーション（キラキラ感を出す）
        final rotation = progress * math.pi * 4;

        return Positioned(
          left: x,
          top: y,
          child: Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: Transform.rotate(
              angle: rotation,
              child: Icon(
                Icons.star, // ⭐️ 星型アイコン
                size: size,
                color: Colors.yellow.withOpacity(0.9), // 黄色で明るく
              ),
            ),
          ),
        );
      },
    );
  }
}
