import 'package:flutter/material.dart';

/// フクロウキャラクターの表示状態
enum OwlMood {
  happy, // 通常
  excited, // 喜び（タスク完了時など）
  proud, // 誇らしげ（達成時）
}

/// フクロウキャラクターウィジェット
///
/// 画像を表示し、状態に応じてアニメーションやエフェクトを追加
class OwlCharacter extends StatefulWidget {
  final OwlMood mood;
  final double size;
  final VoidCallback? onTap;

  const OwlCharacter({
    super.key,
    this.mood = OwlMood.happy,
    this.size = 80.0,
    this.onTap,
  });

  @override
  State<OwlCharacter> createState() => _OwlCharacterState();
}

class _OwlCharacterState extends State<OwlCharacter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: -10.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
  }

  @override
  void didUpdateWidget(OwlCharacter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.mood != oldWidget.mood && widget.mood != OwlMood.happy) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _bounceAnimation.value),
            child: Transform.scale(
              scale: widget.mood == OwlMood.happy ? 1.0 : _scaleAnimation.value,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // フクロウ画像
                  Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/owl_character.png',
                        width: widget.size * 0.8,
                        height: widget.size * 0.8,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          // 画像が見つからない場合の代替表示
                          return const Center(
                            child: Text('🦉', style: TextStyle(fontSize: 40)),
                          );
                        },
                      ),
                    ),
                  ),

                  // エフェクト（excited状態）
                  if (widget.mood == OwlMood.excited) ...[
                    Positioned(top: -8, left: -8, child: _buildSparkle()),
                    Positioned(top: -8, right: -8, child: _buildSparkle()),
                  ],

                  // エフェクト（proud状態）
                  if (widget.mood == OwlMood.proud)
                    Positioned(top: -12, right: -12, child: _buildStar()),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSparkle() {
    return Container(
      width: 20,
      height: 20,
      decoration: const BoxDecoration(
        color: Color(0xFFFBBF24),
        shape: BoxShape.circle,
      ),
      child: const Center(child: Text('✨', style: TextStyle(fontSize: 12))),
    );
  }

  Widget _buildStar() {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: const Color(0xFFFBBF24),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFBBF24).withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Center(child: Text('⭐', style: TextStyle(fontSize: 14))),
    );
  }
}
