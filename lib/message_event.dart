import 'dart:js_interop';

@JS()
@staticInterop
class MessageEvent {}

extension MessageEventExt on MessageEvent {
  external JSAny? get data;
}
