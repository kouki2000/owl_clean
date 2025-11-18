import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';

/// 全タスク完了時の祝福オーバーレイ
class CelebrationOverlay extends StatefulWidget {
  final VoidCallback onClose;

  const CelebrationOverlay({
    super.key,
    required this.onClose,
  });

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay>
    with SingleTickerProviderStateMixin {
  late VideoPlayerController _videoController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isVideoReady = false;

  @override
  void initState() {
    super.initState();

    // アニメーションコントローラー
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    // 動画プレーヤー初期化
    _videoController = VideoPlayerController.asset(
      'assets/videos/owl_complete.mp4',
    )..initialize().then((_) {
        setState(() {
          _isVideoReady = true;
        });
        _videoController.setLooping(true);
        _videoController.play();
        _animationController.forward();
      });
  }

  @override
  void dispose() {
    _videoController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _animationController.reverse().then((_) {
          widget.onClose();
        });
      },
      child: Container(
        color: Colors.black.withOpacity(0.95),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // タイトル
                const Text(
                  '🎉',
                  style: TextStyle(fontSize: 64),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  '全タスク完了！',
                  style: AppTextStyles.h1.copyWith(
                    color: AppColors.white,
                    fontSize: 32,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'お疲れさまでした！',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.white,
                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: AppSpacing.xxl),

                // 動画
                if (_isVideoReady)
                  Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: AspectRatio(
                        aspectRatio: _videoController.value.aspectRatio,
                        child: VideoPlayer(_videoController),
                      ),
                    ),
                  )
                else
                  Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      color: AppColors.gray800,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.white,
                      ),
                    ),
                  ),

                const SizedBox(height: AppSpacing.xxl),

                // 閉じるヒント
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.touch_app,
                        color: AppColors.white,
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'タップして閉じる',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
