import "dart:js" as js;
import "package:flutter_node_worker/flutter_node_worker.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  testWidgets("Web Worker integration test", (tester) async {
    const workerPath = "workers/cipher_module.js";

    final worker = FlutterNodeWorker(path: workerPath);

    final result = await worker.compute(
      command: "encrypt",
      data: {"message": "test message", "password": "password123"},
      computeOnce: true,
    );

    expect(result, isNotNull);
    expect(result, contains("encrypted"));

    worker.terminate();
  });
}
