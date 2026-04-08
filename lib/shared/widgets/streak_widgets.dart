import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class StreakCalendar extends StatelessWidget {
  final int currentStreak;
  final int longestStreak;
  final List<DateTime> activeDays;

  const StreakCalendar({
    super.key,
    required this.currentStreak,
    required this.longestStreak,
    this.activeDays = const [],
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final currentMonth = now.month;
    final currentYear = now.year;
    
    final firstDayOfMonth = DateTime(currentYear, currentMonth, 1);
    final lastDayOfMonth = DateTime(currentYear, currentMonth + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    
    // Calculate start offset (which day of week the month starts)
    final startWeekday = firstDayOfMonth.weekday % 7;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFF6B00).withValues(alpha: 0.2),
            const Color(0xFFFF9500).withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFF6B00).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B00), Color(0xFFFF9500)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_fire_department,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$currentStreak Day Streak',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Longest: $longestStreak days',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ).animate().fadeIn().slideX(begin: -0.2, end: 0),
          
          const SizedBox(height: 24),
          
          // Calendar
          Column(
            children: [
              // Weekday headers
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                    .map((day) => SizedBox(
                          width: 32,
                          child: Text(
                            day,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 12),
              
              // Days grid
              ...List.generate((daysInMonth + startWeekday) ~/ 7 + 1, (weekIndex) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(7, (dayIndex) {
                      final dayNumber = weekIndex * 7 + dayIndex - startWeekday + 1;
                      
                      if (dayNumber < 1 || dayNumber > daysInMonth) {
                        return const SizedBox(width: 32, height: 32);
                      }
                      
                      final date = DateTime(currentYear, currentMonth, dayNumber);
                      final isActive = activeDays.any((d) =>
                          d.year == date.year &&
                          d.month == date.month &&
                          d.day == date.day);
                      final isToday = date == today;
                      
                      return Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          gradient: isActive
                              ? const LinearGradient(
                                  colors: [Color(0xFFFF6B00), Color(0xFFFF9500)],
                                )
                              : null,
                          color: !isActive
                              ? Colors.white.withValues(alpha: 0.05)
                              : null,
                          borderRadius: BorderRadius.circular(8),
                          border: isToday
                              ? Border.all(color: Colors.white, width: 2)
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            '$dayNumber',
                            style: TextStyle(
                              color: isActive
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.3),
                              fontSize: 12,
                              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      )
                          .animate(delay: Duration(milliseconds: (weekIndex * 7 + dayIndex) * 20))
                          .fadeIn()
                          .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1));
                    }),
                  ),
                );
              }),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Motivation message
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.tips_and_updates,
                  color: const Color(0xFFFF9500),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _getMotivationMessage(currentStreak),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ).animate(delay: 800.ms).fadeIn().slideY(begin: 0.3, end: 0),
        ],
      ),
    );
  }

  String _getMotivationMessage(int streak) {
    if (streak == 0) {
      return 'Start your streak today! Complete a lesson to begin.';
    } else if (streak < 3) {
      return 'Great start! Keep it up to build momentum.';
    } else if (streak < 7) {
      return 'You\'re on fire! Don\'t break the streak now.';
    } else if (streak < 30) {
      return 'Incredible! You\'re building a strong habit.';
    } else {
      return 'Amazing dedication! You\'re a learning machine! 🔥';
    }
  }
}

class StreakIndicator extends StatelessWidget {
  final int days;
  final bool compact;

  const StreakIndicator({
    super.key,
    required this.days,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.local_fire_department,
            color: Color(0xFFFF6B00),
            size: 18,
          ),
          const SizedBox(width: 4),
          Text(
            '$days',
            style: const TextStyle(
              color: Color(0xFFFF9500),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B00), Color(0xFFFF9500)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B00).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.local_fire_department,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 6),
          Text(
            '$days Day${days != 1 ? 's' : ''}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ).animate(onPlay: (controller) => controller.repeat())
        .shimmer(delay: 2.seconds, duration: 1.seconds);
  }
}
