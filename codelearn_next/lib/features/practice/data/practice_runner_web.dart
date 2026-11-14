import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';

import 'package:web/web.dart';

import '../../../foundation/json.dart';
import '../domain/practice_result.dart';

class PracticeRunner {
  Worker? worker;
  Completer<PracticeResult>? pending;
  Future<PracticeResult> run(JsonMap request) async {
    cancel();
    final completer = Completer<PracticeResult>();
    pending = completer;
    final current = Worker('assets/assets/runtime/language_worker.js'.toJS);
    worker = current;
    current.onmessage = ((MessageEvent event) {
      if (completer.isCompleted) return;
      try {
        completer.complete(
          PracticeResult.fromJson(
            jsonMap(jsonDecode((event.data as JSString).toDart)),
          ),
        );
      } on FormatException {
        completer.complete(
          const PracticeResult(passed: false, diagnostic: 'unsupportedCode'),
        );
      }
    }).toJS;
    current.onerror = ((Event event) {
      if (!completer.isCompleted) {
        completer.complete(
          const PracticeResult(passed: false, diagnostic: 'workerUnavailable'),
        );
      }
    }).toJS;
    current.postMessage(jsonEncode(request).toJS);
    try {
      return await completer.future.timeout(
        const Duration(seconds: 20),
        onTimeout: () =>
            const PracticeResult(passed: false, diagnostic: 'timeout'),
      );
    } finally {
      current.terminate();
      if (worker == current) worker = null;
    }
  }

  void cancel() {
    worker?.terminate();
    worker = null;
    final current = pending;
    if (current != null && !current.isCompleted) {
      current.complete(
        const PracticeResult(passed: false, diagnostic: 'cancelled'),
      );
    }
  }
}
