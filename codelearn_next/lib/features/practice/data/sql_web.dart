import 'package:sqlite3/wasm.dart';

Future<CommonDatabase> createSqlDatabase() async {
  final sqlite = await WasmSqlite3.loadFromUrl(Uri.parse('sqlite3.wasm'));
  sqlite.registerVirtualFileSystem(InMemoryFileSystem(), makeDefault: true);
  return sqlite.openInMemory();
}
