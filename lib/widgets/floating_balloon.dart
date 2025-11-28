import 'package:flutter/material.dart';
import 'dart:math' as math;

/// 浮いている風船のようなアイコンウィジェット
class FloatingBalloon extends StatefulWidget {
  final IconData icon;
  final double size;
  final Duration floatDuration;
  final double floatDistance;
  final VoidCallback? onPop;

  const FloatingBalloon({
    super.key,
    required this.icon,
    this.size = 50,
    this.floatDuration = const Duration(seconds: 3),
    this.floatDistance = 15,
    this.onPop,
  });

  @override
  State<FloatingBalloon> createState() => FloatingBalloonState();
}

class FloatingBalloonState extends State<FloatingBalloon>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _popController;
  late Animation<double> _floatAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  final double _randomOffset = (math.Random().nextDouble() - 0.5) * 2;
  bool _isPopping = false;

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      duration: widget.floatDuration,
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(
      begin: -widget.floatDistance,
      end: widget.floatDistance,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));

    _popController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _popController,
      curve: Curves.easeOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _popController,
      curve: Curves.easeOut,
    ));

    _popController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onPop?.call();
      }
    });
  }

  @override
  void dispose() {
    _floatController.dispose();
    _popController.dispose();
    super.dispose();
  }

  void pop() {
    if (!_isPopping) {
      setState(() {
        _isPopping = true;
      });
      _floatController.stop();
      _popController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _floatAnimation,
        _scaleAnimation,
        _opacityAnimation,
      ]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            _randomOffset * 5,
            _isPopping ? 0 : _floatAnimation.value,
          ),
          child: Opacity(
            opacity: _isPopping ? _opacityAnimation.value : 1.0,
            child: Transform.scale(
              scale: _isPopping ? _scaleAnimation.value : 1.0,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200],
                  border: Border.all(
                    color: Colors.grey[800]!,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  widget.icon,
                  color: Colors.grey[800],
                  size: widget.size * 0.5,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// カテゴリーIDからアイコンを取得
class CategoryIconHelper {
  static IconData getIcon(String? categoryId) {
    switch (categoryId) {
      case 'toilet':
        return Icons.wc;
      case 'kitchen':
        return Icons.kitchen;
      case 'living':
        return Icons.living;
      case 'bedroom':
        return Icons.hotel;
      case 'bath':
        return Icons.bathtub;
      case 'garbage':
        return Icons.delete;
      default:
        return Icons.more_horiz;
    }
  }
}
