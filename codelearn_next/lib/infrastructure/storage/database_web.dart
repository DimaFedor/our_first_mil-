import 'package:sembast_web/sembast_web.dart';

Future<Database> openLearningDatabase() =>
    databaseFactoryWeb.openDatabase('codelearn-v1', version: 1);
