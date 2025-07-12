import 'dart:js_interop';

/// Represents the options that can be passed when creating a JavaScript Web Worker.
///
/// This is used to interop with the JS `WorkerOptions` object.
///
/// Example (in JS):
/// ```js
/// new Worker('worker.js', { type: 'module' });
/// ```
///
/// Dart usage (interop):
/// ```dart
/// final options = WorkerOptions(type: 'module');
/// ```
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/Worker/Worker
@JS()
@anonymous
@staticInterop
class WorkerOptions {
  external factory WorkerOptions({String type});
}
