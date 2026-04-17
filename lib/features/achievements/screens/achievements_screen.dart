import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../models/achievement_model.dart';
import '../providers/achievement_provider.dart';
import '../../../core/l10n/app_localizations.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final achievementsAsync = ref.watch(achievementsProvider);
    final allAchievements = Achievement.getAllAchievements();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkTheme
                ? const [
                    Color(0xFF0A0E27),
                    Color(0xFF1A1F3A),
                    Color(0xFF0D1B3A),
                  ]
                : const [
                    Color(0xFFF8FAFF),
                    Color(0xFFEEF3FF),
                    Color(0xFFE6EEFF),
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: achievementsAsync.when(
                  data: (unlockedAchievements) {
                    final unlockedIds = unlockedAchievements
                        .map((a) => a.achievementId)
                        .toSet();

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: allAchievements.length,
                      itemBuilder: (context, index) {
                        final achievement = allAchievements[index];
                        final isUnlocked = unlockedIds.contains(achievement.id);

                        return _AchievementCard(
                              achievement: achievement,
                              isUnlocked: isUnlocked,
                            )
                            .animate(delay: (index * 50).ms)
                            .fadeIn()
                            .slideX(begin: -0.2);
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(
                    child: Builder(
                      builder: (context) => Text(
                        '${AppLocalizations.of(context)?.get('error_prefix') ?? 'Error: '}$e',
                        style: TextStyle(color: onSurface),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/');
              }
            },
            icon: Icon(Icons.arrow_back, color: onSurface),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.emoji_events, color: Colors.amber, size: 30),
          const SizedBox(width: 10),
          Text(
            AppLocalizations.of(context)?.get('achievements') ?? 'Achievements',
            style: TextStyle(
              color: onSurface,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ).animate().fadeIn().slideY(begin: -0.2),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final bool isUnlocked;

  const _AchievementCard({required this.achievement, required this.isUnlocked});

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final languageCode = Localizations.localeOf(context).languageCode;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isUnlocked
            ? LinearGradient(
                colors: [
                  achievement.color.withValues(alpha: 0.3),
                  achievement.color.withValues(alpha: 0.1),
                ],
              )
            : const LinearGradient(
                colors: [Color(0xFF1A1F3A), Color(0xFF0D1B3A)],
              ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnlocked
              ? achievement.color.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.1),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isUnlocked
                  ? achievement.color.withValues(alpha: 0.3)
                  : Colors.grey.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              achievement.icon,
              color: isUnlocked ? achievement.color : Colors.grey,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.titleForLocale(languageCode),
                  style: TextStyle(
                    color: isUnlocked
                        ? (isDarkTheme ? Colors.white : onSurface)
                        : Colors.grey,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.descriptionForLocale(languageCode),
                  style: TextStyle(
                    color: isUnlocked
                        ? (isDarkTheme
                              ? Colors.white70
                              : onSurface.withValues(alpha: 0.7))
                        : Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '+${achievement.xpReward} XP',
                  style: TextStyle(
                    color: isUnlocked ? achievement.color : Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (isUnlocked)
            Icon(Icons.check_circle, color: achievement.color, size: 24),
        ],
      ),
    );
  }
}
