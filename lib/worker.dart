// @JS()
// library worker_api;

import 'dart:js_interop';

import 'package:flutter_node_worker/worker_options.dart';

@JS('Worker')
class Worker {
  external factory Worker(String path, WorkerOptions options);

  external void postMessage(dynamic data);
  external void addEventListener(String type, Function listener);
  external void terminate();
}
