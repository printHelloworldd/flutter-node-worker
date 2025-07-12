import 'dart:js_interop';

import 'package:flutter_node_worker/worker_options.dart';

/// Represents a JavaScript [`Worker`](https://developer.mozilla.org/en-US/docs/Web/API/Worker) object.
///
/// Allows running scripts in background threads (Web Workers) via Dart-JS interop.
///
/// Example usage:
/// ```dart
/// final worker = Worker('worker.js', WorkerOptions(type: 'module'));
/// worker.postMessage('Hello from Dart!');
/// ```
@JS("Worker")
@staticInterop
class Worker {
  /// Creates a new web worker that executes the script at the given [path],
  /// using the provided [options].
  ///
  /// - [path]: A string URL pointing to the worker script.
  /// - [options]: Optional settings like `type: 'module'` for ES module workers.
  external factory Worker(String path, WorkerOptions options);
}

/// Extension methods for interacting with a JavaScript `Worker` instance.
extension WorkerExtension on Worker {
  /// Sends a message to the worker.
  ///
  /// [data] can be any serializable JavaScript value.
  external void postMessage(JSAny? data);

  /// Adds an event listener to the worker, such as for `'message'` or `'error'`.
  ///
  /// [type]: The event type (e.g., `'message'`, `'error'`).
  /// [listener]: A JavaScript function to handle the event.
  external void addEventListener(String type, JSFunction listener);

  /// Removes a previously added event listener.
  ///
  /// [type]: The event type.
  /// [listener]: The same function that was passed to `addEventListener`.
  external void removeEventListener(String type, JSFunction listener);

  /// Terminates the worker immediately.
  ///
  /// This stops the worker thread and discards any tasks or messages.
  external void terminate();
}
