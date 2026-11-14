import 'package:cloud_functions/cloud_functions.dart';
import 'package:sembast/sembast.dart';

import 'package:codelearn_next/foundation/json.dart';
import 'package:codelearn_next/infrastructure/sync/sync_service.dart';
import 'package:codelearn_next/features/progress/data/learning_repository.dart';

class FirebaseSyncService implements SyncService {
  final LearningRepository repository;
  bool syncing = false;
  FirebaseSyncService(this.repository);

  @override
  Future<void> synchronize(String account) async {
    if (account == 'guest' || syncing) return;
    syncing = true;
    try {
      final rows = await repository.outbox.find(
        repository.database,
        finder: repository.forAccount(account, limit: 100, sort: 'at'),
      );
      final callable = FirebaseFunctions.instance.httpsCallable(
        'applyLearningOperation',
      );
      for (final row in rows) {
        final operation = row.value;
        await callable.call<Object?>(operation);
        await repository.database.transaction((transaction) async {
          final current = await repository.outbox
              .record(row.key)
              .get(transaction);
          if (current != null &&
              jsonEncodeStable(current) == jsonEncodeStable(operation)) {
            await repository.outbox.record(row.key).delete(transaction);
          }
        });
      }
      final snapshot = await FirebaseFunctions.instance
          .httpsCallable('getLearningSnapshot')
          .call<Object?>();
      final data = jsonMap(snapshot.data);
      await repository.database.transaction((transaction) async {
        final profile =
            await repository.profiles.record(account).get(transaction) ??
            <String, Object?>{};
        await repository.profiles.record(account).put(transaction, {
          ...profile,
          ...jsonMap(data['profile']),
        });
        for (final item in jsonList(data['completions'])) {
          final value = jsonMap(item);
          final id = jsonString(value['lessonId']);
          if (id.isNotEmpty) {
            await repository.completions
                .record(repository.key(account, id))
                .put(transaction, {...value, 'accountId': account});
          }
        }
        for (final item in jsonList(data['portfolio'])) {
          final value = jsonMap(item);
          final id = jsonString(value['id']);
          if (id.isNotEmpty) {
            await repository.portfolio.record(repository.key(account, id)).put(
              transaction,
              {...value, 'accountId': account},
            );
          }
        }
      });
    } finally {
      syncing = false;
    }
  }
}

String jsonEncodeStable(JsonMap value) => value.toString();
