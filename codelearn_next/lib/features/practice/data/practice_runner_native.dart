import 'dart:async';
import 'dart:isolate';

import '../../../foundation/json.dart';
import '../domain/practice_result.dart';
import 'exercise_evaluator.dart';
import 'runtime_host.dart';

class PracticeRunner {
  RuntimeHost? runtimeHost;
  Isolate? worker;
  Completer<PracticeResult>? pending;
  Future<PracticeResult> run(JsonMap request) async {
    cancel();
    final language = jsonString(jsonMap(request['challenge'])['language']);
    if (['python', 'javascript', 'js', 'react', 'jsx'].contains(language)) {
      final host = RuntimeHost();
      runtimeHost = host;
      try {
        return await host.run(request);
      } finally {
        runtimeHost = null;
      }
    }
    final completer = Completer<PracticeResult>();
    pending = completer;
    final port = ReceivePort();
    final subscription = port.listen((message) {
      if (!completer.isCompleted) {
        completer.complete(PracticeResult.fromJson(jsonMap(message)));
      }
    });
    try {
      worker = await Isolate.spawn(runPracticeIsolate, [
        port.sendPort,
        request,
      ]);
      return await completer.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () =>
            const PracticeResult(passed: false, diagnostic: 'timeout'),
      );
    } finally {
      worker?.kill(priority: Isolate.immediate);
      worker = null;
      await subscription.cancel();
      port.close();
    }
  }

  void cancel() {
    runtimeHost?.cancel();
    worker?.kill(priority: Isolate.immediate);
    worker = null;
    final current = pending;
    if (current != null && !current.isCompleted) {
      current.complete(
        const PracticeResult(passed: false, diagnostic: 'cancelled'),
      );
    }
  }
}

Future<void> runPracticeIsolate(List<Object?> message) async {
  final sender = message.first as SendPort;
  try {
    sender.send(await evaluateExercise(jsonMap(message[1])));
  } on Object catch (error) {
    sender.send(
      PracticeResult(passed: false, diagnostic: error.toString()).toJson(),
    );
  }
}
