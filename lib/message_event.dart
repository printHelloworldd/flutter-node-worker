import 'dart:js_interop';

/// Represents the JavaScript [`MessageEvent`](https://developer.mozilla.org/en-US/docs/Web/API/MessageEvent) interface.
///
/// Used for receiving messages sent to a worker.
@JS()
@staticInterop
class MessageEvent {}

/// Extension for accessing properties of a `MessageEvent`.
extension MessageEventExt on MessageEvent {
  /// The data sent from the worker.
  ///
  /// Can be any JavaScript-serializable value (string, object, number, etc.).
  external JSAny? get data;
}
