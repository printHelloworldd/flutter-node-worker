import 'dart:async';
import 'dart:convert';
import 'dart:js' as js;

import 'package:flutter/foundation.dart';

/// A utility class for interacting with JavaScript Web Workers from Dart/Flutter,
/// using a JavaScript module as the worker entry point.
///
/// This class provides an interface for spawning a worker, sending commands,
/// receiving responses, and optionally terminating the worker.
class FlutterNodeWorker {
  /// Path to the JavaScript worker file.
  final String path;

  /// The internal reference to the JavaScript `Worker` object.
  js.JsObject? worker;

  /// Creates an instance of [FlutterNodeWebworker] and spawns the worker.
  ///
  /// The [path] must point to a valid JavaScript module that can be run
  /// in a `Worker` environment.
  FlutterNodeWorker({required this.path}) {
    _spawn(path);
  }

  /// Spawns a Web Worker using the given [path], if no worker is already active.
  ///
  /// If a worker is already running, this method does nothing.
  void _spawn(String path) {
    // terminate();
    if (worker != null) return;

    final workerOptions = js.JsObject.jsify({"type": "module"});
    final workerConstructor = js.context["Worker"];
    worker = js.JsObject(workerConstructor, [path, workerOptions]);
  }

  /// Terminates the current worker if one is active and resets the internal reference.
  void terminate() {
    worker?.callMethod("terminate");
    worker = null;
  }

  /// Sends a command to the worker and waits for a response.
  ///
  /// - [command] is the name of the action to be executed in the worker.
  /// - [data] is a map of arguments passed to the worker.
  /// - [computeOnce] determines whether the worker should be terminated
  ///   after a single execution.
  ///
  /// Returns a [Future] containing the result sent from the worker,
  /// or `null` if the result could not be parsed.
  ///
  /// Throws if the worker returns a non-string result.
  Future<Map<String, dynamic>?> compute({
    required String command,
    required Map<String, dynamic> data,
    bool computeOnce = false,
  }) async {
    final completer = Completer<Map<String, dynamic>?>();

    if (worker == null) {
      _spawn(path);
    }

    void handler(jsEvent) {
      final event = js.JsObject.fromBrowserObject(jsEvent);
      final jsData = event["data"];

      if (jsData is String) {
        final Map<String, dynamic> parsed = jsonDecode(jsData);

        if (kDebugMode) {
          print("Parsed from worker: $parsed");
        }

        if (parsed["status"] == "success") {
          if (!completer.isCompleted) {
            completer.complete(parsed["result"]);
          }

          if (computeOnce) {
            terminate();
          }

          worker?.callMethod("removeEventListener", ["message", handler]);
        }
      } else {
        throw Exception(
          "Worker has returned unexpected data type ${jsData.runtimeType}. Expected String type",
        );
      }
    }

    worker?.callMethod("addEventListener", ["message", handler]);

    worker?.callMethod("postMessage", [
      js.JsObject.jsify({"command": command, "data": data}),
    ]);

    return completer.future;
  }
}
