import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../features/courses/models/course_model.dart';

class EnhancedCourseCard extends StatefulWidget {
  final Course course;
  final int completedLessons;
  final VoidCallback onTap;
  final int index;

  const EnhancedCourseCard({
    super.key,
    required this.course,
    required this.completedLessons,
    required this.onTap,
    this.index = 0,
  });

  @override
  State<EnhancedCourseCard> createState() => _EnhancedCourseCardState();
}

class _EnhancedCourseCardState extends State<EnhancedCourseCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final totalLessons = widget.course.totalLessons;
    final progress = totalLessons > 0 
        ? widget.completedLessons / totalLessons 
        : 0.0;
    final isCompleted = widget.completedLessons >= totalLessons && totalLessons > 0;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.course.color.withValues(alpha: 0.9),
                widget.course.color.withValues(alpha: 0.6),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: widget.course.color.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background emoji
              Positioned(
                right: -10,
                bottom: -10,
                child: Text(
                  widget.course.icon,
                  style: TextStyle(
                    fontSize: 80,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
              ),
              
              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon and completion badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.course.icon,
                          style: const TextStyle(fontSize: 32),
                        ),
                        if (isCompleted)
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check,
                              color: widget.course.color,
                              size: 16,
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              widget.course.difficulty,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Title
                    Text(
                      widget.course.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Description
                    Expanded(
                      child: Text(
                        widget.course.description,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    
                    // Progress bar
                    if (widget.completedLessons > 0) ...[
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          valueColor: const AlwaysStoppedAnimation(Colors.white),
                          minHeight: 4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.completedLessons}/$totalLessons lessons',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 10,
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 8),
                      // Stats
                      Row(
                        children: [
                          Icon(
                            Icons.play_circle_outline,
                            color: Colors.white.withValues(alpha: 0.8),
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$totalLessons lessons',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.access_time,
                            color: Colors.white.withValues(alpha: 0.8),
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.course.estimatedHours}h',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
