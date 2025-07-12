import 'dart:io';

import 'package:args/args.dart';
import '../utils/logger.dart';

void handleUninstall(ArgResults initArgs) {
  try {
    logger.info("Uninstalling npm packages...");

    final String dir = initArgs["dir"] as String;

    final Directory targetDir = Directory(dir);
    if (!targetDir.existsSync()) {
      throw Exception("No such derectory: $dir");
    }

    final List<String> packages = initArgs.arguments.toList();
    packages.removeWhere((arg) => arg == "--dir" || arg == dir);

    final result = Process.runSync(
      "npm",
      ["uninstall", ...packages],
      workingDirectory: dir,
      runInShell: true,
    );

    if (result.exitCode != 0) {
      logger.error("❌ Failed to uninstall packages");
    }

    logger.info("🎉 All packages uninstalled!");
  } catch (e, st) {
    logger.handle(e, st);
  }
}
