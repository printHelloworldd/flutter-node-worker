import 'dart:js_interop';

import 'package:flutter_node_worker/worker_options.dart';

@JS("Worker")
@staticInterop
class Worker {
  external factory Worker(String path, WorkerOptions options);
}

extension WorkerExtension on Worker {
  external void postMessage(JSAny? data);
  external void addEventListener(String type, JSFunction listener);
  external void removeEventListener(String type, JSFunction listener);
  external void terminate();
}
