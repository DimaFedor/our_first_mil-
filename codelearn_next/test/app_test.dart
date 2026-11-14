import 'dart:convert';
import 'dart:io';

import 'package:codelearn_next/app/codelearn_app.dart';
import 'package:codelearn_next/app/providers.dart';
import 'package:codelearn_next/app/router.dart';
import 'package:codelearn_next/features/catalog/domain/content.dart';
import 'package:codelearn_next/features/progress/data/learning_repository.dart';
import 'package:codelearn_next/features/progress/domain/learning_data.dart';
import 'package:codelearn_next/features/portfolio/presentation/portfolio_screen.dart';
import 'package:codelearn_next/foundation/json.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_memory.dart';

class FixtureLearningController extends LearningController {
  final LearningData fixture;
  FixtureLearningController(this.fixture);
  @override
  Future<LearningData> build() async => fixture;
}

void main() {
  for (final locale in ['uk', 'en']) {
    for (final size in [const Size(360, 740), const Size(1280, 900)]) {
      testWidgets('all main pages render in $locale at ${size.width}', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final fixtures = await tester.runAsync(() async {
          final database = await databaseFactoryMemory.openDatabase(
            'ui-$locale-${size.width}',
          );
          final repository = LearningRepository(database);
          await repository.updatePreferences({
            'uiLocale': locale,
            'learningLocale': locale,
            'onboarded': true,
          });
          final data = await repository.load('guest');
          final courses = jsonList(
            jsonDecode(
              await File('assets/content/catalog.json').readAsString(),
            ),
          ).map((item) => Course.fromJson(jsonMap(item))).toList();
          final languages = jsonList(
            jsonDecode(
              await File('assets/content/languages.json').readAsString(),
            ),
          ).map((item) => ContentLanguage.fromJson(jsonMap(item))).toList();
          final lessons = jsonList(
            jsonMap(
              jsonDecode(
                await File('assets/content/en__python.json').readAsString(),
              ),
            )['lessons'],
          ).map((item) => Lesson.fromJson(jsonMap(item))).toList();
          return (
            repository: repository,
            data: data,
            courses: courses,
            languages: languages,
            lessons: lessons,
          );
        });
        final value = fixtures!;
        final container = ProviderContainer(
          overrides: [
            repositoryProvider.overrideWithValue(value.repository),
            dataProvider.overrideWith(
              () => FixtureLearningController(value.data),
            ),
            coursesProvider.overrideWith((ref) async => value.courses),
            languagesProvider.overrideWith((ref) async => value.languages),
            lessonsProvider.overrideWith((ref, id) async => value.lessons),
            portfolioEntriesProvider.overrideWith(
              (ref, limit) async => const [],
            ),
          ],
        );
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const CodeLearnApp(),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        for (final route in [
          '/courses',
          '/journey',
          '/rewards',
          '/profile',
          '/settings',
          '/portfolio',
          '/support',
          '/auth',
          '/course/python',
          '/course/python/lesson/python_lesson_1',
        ]) {
          container.read(routerProvider).go(route);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: route);
        }
        await tester.pumpWidget(const SizedBox());
        container.dispose();
        await tester.runAsync(value.repository.database.close);
      });
    }
  }
}
