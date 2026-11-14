import 'dart:convert';

import 'package:sqlite3/common.dart';

import '../../../foundation/json.dart';
import '../domain/practice_result.dart';
import 'sql_database.dart';

const sqlFixture = '''
CREATE TABLE products(id INTEGER PRIMARY KEY, name TEXT, category TEXT, price REAL, stock INTEGER DEFAULT 10);
INSERT INTO products VALUES (1,'Keyboard','Electronics',49.99,10),(2,'Mouse','Electronics',29.99,20),(3,'Notebook','Office',9.99,30),(4,'Headphones','Electronics',79.99,12),(5,'Coffee Mug','Home',12.5,15),(6,'Monitor','Electronics',199.99,5),(7,'Cable','Electronics',5.0,8),(8,'Charger','Electronics',20,6),(9,'Speaker','Electronics',60,7),(10,'Camera','Electronics',90,9);
CREATE TABLE users(id INTEGER PRIMARY KEY, name TEXT, email TEXT, role TEXT);
INSERT INTO users VALUES(1,'John','john@gmail.com','user'),(2,'Julia','julia@gmail.com','user'),(3,'Alice','alice@yahoo.com','admin'),(4,'Mark','mark@outlook.com','user');
CREATE TABLE orders(id INTEGER PRIMARY KEY, user_id INTEGER, customer_id INTEGER, amount REAL, total REAL);
INSERT INTO orders VALUES(1,1,1,120,120),(2,1,1,75.5,75.5),(3,3,3,250,250),(4,1,1,20,20),(5,1,1,30,30),(6,1,1,40,40),(7,1,1,50,50);
''';

Future<PracticeResult> evaluateSql(String code, String reference) async {
  final actual = await createSqlDatabase();
  final expected = await createSqlDatabase();
  try {
    actual.execute(sqlFixture);
    expected.execute(sqlFixture);
    final wanted = sqlOutcome(expected, reference);
    final result = sqlOutcome(actual, code);
    final passed = jsonEncode(wanted) == jsonEncode(result);
    return PracticeResult(
      passed: passed,
      output: jsonEncode(result),
      diagnostic: passed ? '' : 'resultMismatch',
      passedCount: passed ? 1 : 0,
      totalCount: 1,
    );
  } on SqliteException catch (error) {
    return PracticeResult(
      passed: false,
      diagnostic: error.message,
      totalCount: 1,
    );
  } finally {
    actual.dispose();
    expected.dispose();
  }
}

JsonMap sqlOutcome(CommonDatabase database, String query) {
  if (query.trim().isEmpty ||
      query.length > 20000 ||
      RegExp(
        r'\b(attach|detach|pragma)\b',
        caseSensitive: false,
      ).hasMatch(query)) {
    throw const AppFailure('unsupportedCode');
  }
  final statements = database.prepareMultiple(query);
  final rows = <Object?>[];
  try {
    for (final statement in statements) {
      rows.addAll(statement.select().map((row) => row.values.toList()));
    }
    final schema = database
        .select(
          "SELECT name, sql FROM sqlite_master WHERE name NOT LIKE 'sqlite_%' ORDER BY name",
        )
        .map((row) => row.values.toList())
        .toList();
    final tables = database.select(
      "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' ORDER BY name",
    );
    final contents = <String, Object?>{};
    for (final row in tables) {
      final name = row['name'] as String;
      contents[name] = database
          .select('SELECT * FROM "$name"')
          .map((row) => row.values.toList())
          .toList();
    }
    return {'rows': rows, 'schema': schema, 'contents': contents};
  } finally {
    for (final statement in statements) {
      statement.dispose();
    }
  }
}
