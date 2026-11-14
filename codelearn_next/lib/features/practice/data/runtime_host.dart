import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../../foundation/json.dart';
import '../domain/practice_result.dart';

class RuntimeHost {
  HttpServer? server;
  HeadlessInAppWebView? webView;
  Completer<PracticeResult>? pending;

  Future<PracticeResult> run(JsonMap request) async {
    final result = Completer<PracticeResult>();
    pending = result;
    final token = List.generate(
      24,
      (index) => Random.secure().nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
    final host = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server = host;
    host.listen((incoming) async {
      final path = incoming.uri.path;
      if (!path.startsWith('/$token/') || path.contains('..')) {
        incoming.response.statusCode = 404;
        await incoming.response.close();
        return;
      }
      final file = path.substring(token.length + 2);
      try {
        if (file.isEmpty) {
          incoming.response.headers.contentType = ContentType.html;
          incoming.response.write(
            '<html><body><script>window.start = request => { window.engine = new Worker("language_worker.js"); window.engine.onmessage = event => window.flutter_inappwebview.callHandler("result", event.data); window.engine.onerror = () => window.flutter_inappwebview.callHandler("result", JSON.stringify({passed:false,diagnostic:"workerUnavailable"})); window.engine.postMessage(JSON.stringify(request)); };</script></body></html>',
          );
        } else {
          if (!RegExp(r'^[a-zA-Z0-9_./-]+$').hasMatch(file)) {
            throw const AppFailure('notFound');
          }
          final data = await rootBundle.load('assets/runtime/$file');
          incoming.response.headers.contentType = file.endsWith('.wasm')
              ? ContentType('application', 'wasm')
              : file.endsWith('.js')
              ? ContentType('text', 'javascript')
              : ContentType.binary;
          incoming.response.add(
            data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
          );
        }
      } on Exception {
        incoming.response.statusCode = 404;
      }
      await incoming.response.close();
    });
    final view = HeadlessInAppWebView(
      initialUrlRequest: URLRequest(
        url: WebUri('http://127.0.0.1:${host.port}/$token/'),
      ),
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        isInspectable: false,
      ),
      onWebViewCreated: (controller) {
        controller.addJavaScriptHandler(
          handlerName: 'result',
          callback: (arguments) {
            if (!result.isCompleted &&
                arguments.isNotEmpty &&
                arguments.first is String) {
              result.complete(
                PracticeResult.fromJson(
                  jsonMap(jsonDecode(arguments.first as String)),
                ),
              );
            }
            return null;
          },
        );
      },
      onLoadStop: (controller, url) async {
        await controller.evaluateJavascript(
          source: 'window.start(${jsonEncode(request)});',
        );
      },
    );
    webView = view;
    try {
      await view.run();
      return await result.future.timeout(
        const Duration(seconds: 20),
        onTimeout: () =>
            const PracticeResult(passed: false, diagnostic: 'timeout'),
      );
    } finally {
      await dispose();
    }
  }

  void cancel() {
    final result = pending;
    if (result != null && !result.isCompleted) {
      result.complete(
        const PracticeResult(passed: false, diagnostic: 'cancelled'),
      );
    }
  }

  Future<void> dispose() async {
    await webView?.dispose();
    webView = null;
    await server?.close(force: true);
    server = null;
  }
}
