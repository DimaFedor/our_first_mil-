import 'dart:convert';
import 'dart:js_interop';

import 'package:web/web.dart';

import 'package:codelearn_next/foundation/json.dart';
import 'package:codelearn_next/features/practice/data/exercise_evaluator.dart';

void main() {
  final scope = globalContext as DedicatedWorkerGlobalScope;
  scope.onmessage = ((MessageEvent event) {
    unawaitedWorker(scope, event);
  }).toJS;
}

Future<void> unawaitedWorker(
  DedicatedWorkerGlobalScope scope,
  MessageEvent event,
) async {
  final request = jsonMap(jsonDecode((event.data as JSString).toDart));
  final result = await evaluateExercise(request);
  scope.postMessage(jsonEncode(result).toJS);
}
