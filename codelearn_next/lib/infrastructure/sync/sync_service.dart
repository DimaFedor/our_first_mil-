abstract interface class SyncService {
  Future<void> synchronize(String account);
}

class LocalSyncService implements SyncService {
  const LocalSyncService();
  @override
  Future<void> synchronize(String account) async {}
}
