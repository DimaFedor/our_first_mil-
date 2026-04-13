import 'package:go_router/go_router.dart';
import '../../features/auth/screens/onboarding_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/courses/screens/course_detail_screen.dart';
import '../../features/courses/models/course_model.dart';
import '../../features/lessons/screens/lesson_screen.dart';
import '../../features/lessons/models/lesson_model.dart';
import '../../features/achievements/screens/achievements_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';
import '../../features/profile/screens/learning_journey_screen.dart';
import '../../features/rewards/screens/xp_rewards_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/support/screens/support_screen.dart';
import '../../shared/widgets/main_navigation.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/onboarding',
    routes: [
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const MainNavigationScreen(),
        routes: [
          GoRoute(
            path: 'course/:courseId',
            name: 'course_detail',
            builder: (context, state) {
              final course = state.extra as Course;
              return CourseDetailScreen(course: course);
            },
            routes: [
              GoRoute(
                path: 'lesson/:lessonId',
                name: 'lesson',
                builder: (context, state) {
                  final extra = state.extra as Map<String, dynamic>;
                  final course = extra['course'] as Course;
                  final lesson = extra['lesson'] as Lesson;
                  return LessonScreen(course: course, lesson: lesson);
                },
              ),
            ],
          ),
          GoRoute(
            path: 'achievements',
            name: 'achievements',
            builder: (context, state) => const AchievementsScreen(),
          ),
          GoRoute(
            path: 'settings',
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: 'edit-profile',
            name: 'edit_profile',
            builder: (context, state) => const EditProfileScreen(),
          ),
          GoRoute(
            path: 'learning-journey',
            name: 'learning_journey',
            builder: (context, state) => const LearningJourneyScreen(),
          ),
          GoRoute(
            path: 'support',
            name: 'support',
            builder: (context, state) => const SupportScreen(),
          ),
          GoRoute(
            path: 'xp-rewards',
            name: 'xp_rewards',
            builder: (context, state) => const XPRewardsScreen(),
          ),
        ],
      ),
    ],
  );
}
