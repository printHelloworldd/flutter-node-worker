import 'dart:io';

import 'package:args/args.dart';
import '../utils/logger.dart';

void handleInstall(ArgResults initArgs) {
  try {
    logger.info("Installing npm packages...");

    final String dir = initArgs["dir"] as String;

    final Directory targetDir = Directory(dir);
    if (!targetDir.existsSync()) {
      throw Exception("No such derectory: $dir");
    }

    final List<String> packages = initArgs.arguments.toList();
    packages.removeWhere((arg) => arg == "--dir" || arg == dir);

    final result = Process.runSync(
      "npm",
      ["install", ...packages],
      workingDirectory: dir,
      runInShell: true,
    );

    if (result.exitCode != 0) {
      logger.error("❌ Failed to install packages");
    }

    logger.info("🎉 All packages installed!");
  } catch (e, st) {
    logger.handle(e, st);
  }
}
