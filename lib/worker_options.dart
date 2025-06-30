import 'dart:js_interop';

@JS()
@anonymous
class WorkerOptions {
  external String get type;
  external factory WorkerOptions({String type});
}
