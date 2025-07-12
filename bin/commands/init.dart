import 'dart:io';

import 'package:args/args.dart';

import '../utils/logger.dart';
import '../utils/utils.dart';

Future<void> handleInit(ArgResults initArgs) async {
  logger.info("Initializing module worker...");

  final String dir = initArgs["dir"] as String;
  final String name = initArgs["name"] as String;
  // final String template = initArgs["template"] as String;

  final Directory targetDir = Directory(dir);
  if (!targetDir.existsSync()) {
    targetDir.createSync(recursive: true);
  }

  Process.runSync("npm", ["install", "vite"], runInShell: true);

  Process.runSync(
      "npm",
      [
        "create",
        "vite@latest",
        dir,
        "--",
        "--template",
        "vanilla",
      ],
      runInShell: true);

  final resolvedPath = await Utils.resolveTemplatePath('/');

  await Utils.copyAndRenderTemplates(
    from: resolvedPath,
    to: "./",
    vars: {"workerName": name},
    targetWorkerDir: dir,
  );

  Utils.clearDirectory(dir);

  logger.info("The module worker was initialized successfully.");
}
