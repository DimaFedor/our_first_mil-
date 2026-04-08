import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CelebrationAnimation extends StatelessWidget {
  final Widget child;
  final bool show;
  final VoidCallback? onComplete;

  const CelebrationAnimation({
    super.key,
    required this.child,
    this.show = false,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    if (!show) return child;

    return Stack(
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              color: Colors.transparent,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.emoji_events,
                    size: 100,
                    color: Color(0xFFFFD700),
                  ).animate(onComplete: (_) => onComplete?.call())
                    .scale(duration: 600.ms, curve: Curves.elasticOut)
                    .then()
                    .shimmer(duration: 1.seconds)
                    .then()
                    .fadeOut(duration: 500.ms),
                  
                  const SizedBox(height: 24),
                  
                  const Text(
                    'Awesome!',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ).animate()
                    .fadeIn(delay: 300.ms)
                    .slideY(begin: 0.3, end: 0)
                    .then()
                    .fadeOut(delay: 1.5.seconds, duration: 500.ms),
                ],
              ),
            ),
          ),
        ),
        // Confetti particles
        ...List.generate(20, (index) {
          final random = (index * 17 + 31) % 100 / 100;
          return Positioned(
            top: 50 + (random * 200),
            left: random * MediaQuery.of(context).size.width,
            child: Icon(
              [Icons.star, Icons.favorite, Icons.celebration][index % 3],
              color: [Colors.yellow, Colors.pink, Colors.purple][index % 3],
              size: 20 + (random * 20),
            ).animate()
              .fadeIn(delay: (index * 50).ms)
              .slideY(begin: -1, end: 1, duration: 2.seconds)
              .fadeOut(delay: 1.5.seconds, duration: 500.ms),
          );
        }),
      ],
    );
  }
}

class SuccessAnimation extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color color;

  const SuccessAnimation({
    super.key,
    required this.message,
    this.icon = Icons.check_circle,
    this.color = const Color(0xFF10B981),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 48,
              color: color,
            ),
          ).animate()
            .scale(duration: 500.ms, curve: Curves.elasticOut)
            .then()
            .shimmer(delay: 200.ms, duration: 800.ms),
          
          const SizedBox(height: 24),
          
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ).animate()
            .fadeIn(delay: 300.ms)
            .slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }
}

class XpGainAnimation extends StatelessWidget {
  final int xp;
  final VoidCallback? onComplete;

  const XpGainAnimation({
    super.key,
    required this.xp,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: 1.5.seconds,
      onEnd: onComplete,
      builder: (context, value, child) {
        final currentXp = (xp * value).toInt();
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFF59E0B).withValues(alpha: 0.9),
                const Color(0xFFFBBF24).withValues(alpha: 0.9),
              ],
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
                blurRadius: 20,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, color: Colors.white, size: 32),
              const SizedBox(width: 12),
              Text(
                '+$currentXp XP',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ).animate()
          .fadeIn(duration: 300.ms)
          .scale(begin: const Offset(0.5, 0.5), duration: 500.ms, curve: Curves.elasticOut)
          .then()
          .shimmer(duration: 800.ms)
          .then(delay: 400.ms)
          .slideY(begin: 0, end: -0.3, duration: 500.ms)
          .fadeOut(duration: 300.ms);
      },
    );
  }
}

class StreakFireAnimation extends StatelessWidget {
  final int days;
  
  const StreakFireAnimation({
    super.key,
    required this.days,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.local_fire_department,
          color: Color(0xFFFF6B00),
          size: 32,
        ).animate(onPlay: (controller) => controller.repeat())
          .shimmer(delay: 500.ms, duration: 1.seconds)
          .shake(delay: 1.5.seconds, duration: 500.ms),
        
        const SizedBox(width: 8),
        
        Text(
          '$days',
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFF9500),
          ),
        ).animate(onPlay: (controller) => controller.repeat())
          .shimmer(delay: 600.ms, duration: 1.seconds),
      ],
    );
  }
}

class LevelUpAnimation extends StatelessWidget {
  final int newLevel;
  final VoidCallback? onComplete;

  const LevelUpAnimation({
    super.key,
    required this.newLevel,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Burst effect
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF0066FF).withValues(alpha: 0.6),
                  const Color(0xFF8B5CF6).withValues(alpha: 0.0),
                ],
              ),
            ),
          ).animate(onComplete: (_) => onComplete?.call())
            .scale(begin: const Offset(0, 0), duration: 600.ms, curve: Curves.easeOut)
            .fadeIn(duration: 200.ms)
            .then()
            .fadeOut(duration: 400.ms),
          
          // Level badge
          Container(
            width: 120,
            height: 120,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0066FF), Color(0xFF8B5CF6)],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'LEVEL',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  Text(
                    '$newLevel',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ).animate()
            .scale(delay: 100.ms, duration: 600.ms, curve: Curves.elasticOut)
            .then()
            .shimmer(duration: 1.seconds),
          
          const SizedBox(height: 24),
          
          const Text(
            'LEVEL UP!',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 3,
            ),
          ).animate()
            .fadeIn(delay: 400.ms)
            .slideY(begin: 0.3, end: 0)
            .then()
            .shimmer(duration: 1.seconds),
        ],
      ),
    );
  }
}

class PulseAnimation extends StatelessWidget {
  final Widget child;
  final bool enabled;
  
  const PulseAnimation({
    super.key,
    required this.child,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;
    
    return child.animate(onPlay: (controller) => controller.repeat(reverse: true))
      .scale(
        begin: const Offset(1.0, 1.0),
        end: const Offset(1.05, 1.05),
        duration: 1.seconds,
      );
  }
}
