import 'dart:js_interop';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_node_worker/message_event.dart';
import 'package:flutter_node_worker/worker.dart';
import 'package:flutter_node_worker/worker_options.dart';

/// A utility class for interacting with JavaScript Web Workers from Dart/Flutter,
/// using a JavaScript module as the worker entry point.
///
/// This class provides an interface for spawning a worker, sending commands,
/// receiving responses, and optionally terminating the worker.
class FlutterNodeWorker {
  /// Path to the JavaScript worker file.
  final String path;

  /// The internal reference to the JavaScript `Worker` object.
  Worker? worker;

  /// Creates an instance of [FlutterNodeWebworker] and spawns the worker.
  ///
  /// The [path] must point to a valid JavaScript module that can be run
  /// in a `Worker` environment.
  FlutterNodeWorker({
    required this.path,
  }) {
    _spawn(path);
  }

  /// Spawns a Web Worker using the given [path], if no worker is already active.
  ///
  /// If a worker is already running, this method does nothing.
  void _spawn(String path) {
    if (worker != null) return;

    final workerOptions = WorkerOptions(type: "module");
    worker = Worker(path, workerOptions);
  }

  /// Terminates the current worker if one is active and resets the internal reference.
  void terminate() {
    worker?.terminate();
    worker = null;
  }

  /// Sends a command to the worker and waits for a response.
  ///
  /// - [command] is the name of the action to be executed in the worker.
  /// - [data] is a map of arguments passed to the worker.
  /// - [computeOnce] determines whether the worker should be terminated
  ///   after a single execution.
  /// - [timeoutDuration] is a `Duration` specifying the maximum amount of time to wait for a response from the worker.
  ///   If no response is received within this period, a `TimeoutException` will be thrown.
  ///
  /// Returns a [Future] containing the result sent from the worker,
  /// or `null` if the result could not be parsed.
  ///
  /// Throws if the worker returns a non-string result.
  Future<Map<String, dynamic>?> compute({
    required String command,
    required Map<String, dynamic> data,
    bool computeOnce = false,
    Duration timeoutDuration = const Duration(seconds: 10),
  }) async {
    try {
      late final JSFunction jsHandler;
      final completer = Completer<Map<String, dynamic>?>();

      if (worker == null) {
        _spawn(path);
      }

      jsHandler = ((MessageEvent jsEvent) {
        final JSAny? jsData = jsEvent.data;

        final Map<String, dynamic> parsed =
            jsonDecode(jsData.dartify() as String);

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

          worker?.removeEventListener("message", jsHandler);
        }
      }).toJS;

      worker?.addEventListener("message", jsHandler);

      worker?.postMessage(
        ({"command": command, "data": data}).jsify(),
      );

      return completer.future.timeout(
        timeoutDuration,
        onTimeout: () {
          worker?.removeEventListener("message", jsHandler);
          if (computeOnce) terminate();
          throw TimeoutException(
            "Worker timeout: no response in ${timeoutDuration.inSeconds} seconds.",
            timeoutDuration,
          );
        },
      );
    } catch (e) {
      throw Exception(
        "Worker has returned error ${e.toString()}.",
      );
    }
  }
}
