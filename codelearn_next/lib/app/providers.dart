import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/auth_service.dart';
import '../features/catalog/data/asset_content_repository.dart';
import '../features/catalog/domain/content.dart';
import '../features/progress/data/learning_repository.dart';
import '../features/progress/domain/learning_data.dart';
import '../infrastructure/audio/feedback_service.dart';
import '../infrastructure/sync/sync_service.dart';

final repositoryProvider = Provider<LearningRepository>(
  (ref) => throw StateError('Database must be initialized'),
);
final authServiceProvider = Provider<AuthService>(
  (ref) => const GuestAuthService(),
);
final authUserProvider = StreamProvider<AuthIdentity?>(
  (ref) => ref.watch(authServiceProvider).changes,
);
final accountProvider = Provider<String>(
  (ref) => ref.watch(authUserProvider).value?.uid ?? 'guest',
);
final contentProvider = Provider<ContentRepository>(
  (ref) => AssetContentRepository(rootBundle),
);
final coursesProvider = FutureProvider<List<Course>>(
  (ref) => ref.watch(contentProvider).courses(),
);
final languagesProvider = FutureProvider<List<ContentLanguage>>(
  (ref) => ref.watch(contentProvider).languages(),
);
final dataProvider = AsyncNotifierProvider<LearningController, LearningData>(
  LearningController.new,
);
final lessonsProvider = FutureProvider.family<List<Lesson>, String>((
  ref,
  courseId,
) {
  final locale =
      ref.watch(dataProvider).value?.preferences.learningLocale ?? 'uk';
  return ref.watch(contentProvider).lessons(courseId, locale);
});
final feedbackProvider = Provider<FeedbackService>((ref) {
  final service = FeedbackService();
  ref.onDispose(service.dispose);
  return service;
});
final syncProvider = Provider<SyncService>((ref) => const LocalSyncService());

class LearningController extends AsyncNotifier<LearningData> {
  @override
  Future<LearningData> build() =>
      ref.watch(repositoryProvider).load(ref.watch(accountProvider));

  Future<void> reload() async {
    final next = await ref
        .read(repositoryProvider)
        .load(ref.read(accountProvider));
    if (ref.mounted) state = AsyncData(next);
  }

  Future<void> perform(
    Future<void> Function(LearningRepository repository, String account) action,
  ) async {
    await action(ref.read(repositoryProvider), ref.read(accountProvider));
    await reload();
  }
}
