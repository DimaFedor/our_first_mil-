import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../features/progress/services/xp_system.dart';

class LevelProgressWidget extends StatelessWidget {
  final LevelInfo levelInfo;
  final bool compact;
  final bool showDetails;

  const LevelProgressWidget({
    super.key,
    required this.levelInfo,
    this.compact = false,
    this.showDetails = true,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _buildCompactVersion(context);
    }
    return _buildFullVersion(context);
  }

  Widget _buildCompactVersion(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0066FF), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(levelInfo.badge, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(
            'Lvl ${levelInfo.level}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullVersion(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            isDarkTheme
                ? const Color(0xFF0066FF).withValues(alpha: 0.2)
                : const Color(0xFF0066FF).withValues(alpha: 0.16),
            isDarkTheme
                ? const Color(0xFF8B5CF6).withValues(alpha: 0.1)
                : const Color(0xFF8B5CF6).withValues(alpha: 0.12),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkTheme
              ? const Color(0xFF0066FF).withValues(alpha: 0.3)
              : const Color(0xFF0066FF).withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with badge and level
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0066FF), Color(0xFF8B5CF6)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0066FF).withValues(alpha: 0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    levelInfo.badge,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Level ${levelInfo.level}',
                      style: TextStyle(
                        color: onSurface,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      levelInfo.title,
                      style: TextStyle(
                        color: onSurface.withValues(alpha: 0.75),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              // XP badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Color(0xFFF59E0B), size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '${levelInfo.currentXP} XP',
                      style: const TextStyle(
                        color: Color(0xFFF59E0B),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ).animate(delay: 100.ms).fadeIn().slideX(begin: -0.2, end: 0),

          const SizedBox(height: 24),

          // Progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    levelInfo.isMaxLevel
                        ? 'Max Level Reached!'
                        : 'Progress to Level ${levelInfo.level + 1}',
                    style: TextStyle(
                      color: onSurface.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                  if (!levelInfo.isMaxLevel)
                    Text(
                      '${levelInfo.xpNeededForNextLevel} XP needed',
                      style: TextStyle(
                        color: onSurface.withValues(alpha: 0.65),
                        fontSize: 12,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 10),

              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  children: [
                    Container(
                      height: 12,
                      decoration: BoxDecoration(
                        color: isDarkTheme
                            ? Colors.white.withValues(alpha: 0.1)
                            : onSurface.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: levelInfo.progress,
                      child:
                          Container(
                                height: 12,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF0066FF),
                                      Color(0xFF8B5CF6),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF0066FF,
                                      ).withValues(alpha: 0.5),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                              )
                              .animate(delay: 300.ms)
                              .scaleX(
                                begin: 0,
                                duration: 800.ms,
                                curve: Curves.easeOutCubic,
                                alignment: Alignment.centerLeft,
                              ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // XP range
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${levelInfo.xpForCurrentLevel} XP',
                    style: TextStyle(
                      color: onSurface.withValues(alpha: 0.55),
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    '${(levelInfo.progress * 100).toInt()}%',
                    style: const TextStyle(
                      color: Color(0xFF0066FF),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${levelInfo.xpForNextLevel} XP',
                    style: TextStyle(
                      color: onSurface.withValues(alpha: 0.55),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2, end: 0),

          if (showDetails) ...[
            const SizedBox(height: 20),

            // Next milestone
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.emoji_events,
                    color: Colors.white.withValues(alpha: 0.7),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Next Title',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          _getNextTitle(levelInfo.level),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _getNextTitleLevel(levelInfo.level),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.2, end: 0),
          ],
        ],
      ),
    );
  }

  String _getNextTitle(int currentLevel) {
    if (currentLevel < 5) return 'Apprentice';
    if (currentLevel < 10) return 'Student';
    if (currentLevel < 15) return 'Coder';
    if (currentLevel < 20) return 'Developer';
    if (currentLevel < 30) return 'Senior Developer';
    if (currentLevel < 40) return 'Expert';
    if (currentLevel < 50) return 'Master';
    if (currentLevel < 60) return 'Guru';
    if (currentLevel < 75) return 'Legend';
    if (currentLevel < 90) return 'Code Wizard';
    return 'Max Level!';
  }

  String _getNextTitleLevel(int currentLevel) {
    if (currentLevel < 5) return 'Level 5';
    if (currentLevel < 10) return 'Level 10';
    if (currentLevel < 15) return 'Level 15';
    if (currentLevel < 20) return 'Level 20';
    if (currentLevel < 30) return 'Level 30';
    if (currentLevel < 40) return 'Level 40';
    if (currentLevel < 50) return 'Level 50';
    if (currentLevel < 60) return 'Level 60';
    if (currentLevel < 75) return 'Level 75';
    if (currentLevel < 90) return 'Level 90';
    return '';
  }
}

class XPGainWidget extends StatelessWidget {
  final int xpGained;
  final String? bonusReason;

  const XPGainWidget({super.key, required this.xpGained, this.bonusReason});

  @override
  Widget build(BuildContext context) {
    return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: Colors.white, size: 28),
                  const SizedBox(width: 8),
                  Text(
                    '+$xpGained XP',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (bonusReason != null) ...[
                const SizedBox(height: 4),
                Text(
                  bonusReason!,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ],
          ),
        )
        .animate()
        .scale(
          begin: const Offset(0.5, 0.5),
          duration: 400.ms,
          curve: Curves.elasticOut,
        )
        .then()
        .shimmer(duration: 800.ms);
  }
}
