import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LanguageStatsCard extends StatelessWidget {
  final int pythonLessons;
  final int jsLessons;
  final int htmlCssLessons;
  final int reactLessons;
  final int sqlLessons;
  final int totalLessons;

  const LanguageStatsCard({
    super.key,
    required this.pythonLessons,
    required this.jsLessons,
    required this.htmlCssLessons,
    this.reactLessons = 0,
    this.sqlLessons = 0,
    required this.totalLessons,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade900.withOpacity(0.3),
            Colors.purple.shade900.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.code,
                color: Colors.blue.shade300,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Languages',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Python
          _buildLanguageRow(
            context,
            '🐍 Python',
            pythonLessons,
            10,
            Colors.blue,
            0,
          ),
          const SizedBox(height: 16),
          
          // JavaScript
          _buildLanguageRow(
            context,
            '⚡ JavaScript',
            jsLessons,
            10,
            Colors.yellow,
            100,
          ),
          const SizedBox(height: 16),
          
          // HTML/CSS
          _buildLanguageRow(
            context,
            '🎨 HTML/CSS',
            htmlCssLessons,
            10,
            Colors.orange,
            200,
          ),
          const SizedBox(height: 16),
          
          // React
          _buildLanguageRow(
            context,
            '⚛️ React',
            reactLessons,
            8,
            Colors.cyan,
            300,
          ),
          const SizedBox(height: 16),
          
          // SQL
          _buildLanguageRow(
            context,
            '🗄️ SQL',
            sqlLessons,
            10,
            Colors.indigo,
            400,
          ),
          
          const SizedBox(height: 20),
          Divider(color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 12),
          
          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Progress',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              Text(
                '$totalLessons/48 lessons',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade300,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 300.ms)
      .slideY(begin: 0.1, end: 0, duration: 600.ms, delay: 300.ms);
  }

  Widget _buildLanguageRow(
    BuildContext context,
    String language,
    int completed,
    int total,
    MaterialColor color,
    int delayMs,
  ) {
    final progress = total > 0 ? completed / total : 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              language,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            Text(
              '$completed/$total',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color.shade300,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: Colors.white.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: Duration(milliseconds: delayMs))
      .slideX(begin: -0.1, end: 0, duration: 400.ms, delay: Duration(milliseconds: delayMs));
  }
}
