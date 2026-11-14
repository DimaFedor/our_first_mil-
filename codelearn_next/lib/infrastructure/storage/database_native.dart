import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';

Future<Database> openLearningDatabase() async {
  final directory = await getApplicationSupportDirectory();
  await directory.create(recursive: true);
  return databaseFactoryIo.openDatabase(
    '${directory.path}/codelearn-v1.db',
    version: 1,
  );
}
