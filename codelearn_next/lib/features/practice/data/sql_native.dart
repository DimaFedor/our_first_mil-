import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3/common.dart';

Future<CommonDatabase> createSqlDatabase() async => sqlite3.openInMemory();
