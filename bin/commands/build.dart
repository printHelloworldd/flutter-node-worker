import 'dart:io';

import 'package:args/args.dart';
import '../utils/logger.dart';
import 'package:path/path.dart' as p;

void handleBuildAll(ArgResults initArgs) {
  try {
    final String dir = initArgs["dir"] as String;
    final String outPath = initArgs["out-dir"] as String;

    logger.info("🔧 Auto-building all workers in '$dir/src/' using Vite...");

    final srcDir = Directory(p.join(dir, "src"));
    if (!srcDir.existsSync()) {
      throw Exception("❌ No src directory found at $dir/src/");
    }

    final outDir = Directory(outPath);
    if (!outDir.existsSync()) {
      Directory(outPath).createSync(recursive: true);
    }

    final viteConfig = File(p.join(dir, "vite.config.js"));
    if (!viteConfig.existsSync()) {
      throw Exception("❌ Missing vite.config.js in $dir/");
    }

    final entryFiles = srcDir
        .listSync()
        .whereType<File>()
        .where(
          (f) =>
              f.path.endsWith(".ts") ||
              f.path.endsWith(".js") && !f.path.contains("main.js"),
        )
        .toList();

    if (entryFiles.isEmpty) {
      logger.error("⚠️ No .js files found in src/");
      return;
    }

    for (final file in entryFiles) {
      final fileName = p.basename(file.path);
      final entryPath = p.relative(file.path, from: dir);
      final outputName = "${p.basenameWithoutExtension(fileName)}_module.js";

      logger.info("📦 Building: $fileName → dist/$outputName.js");

      final result = Process.runSync(
        "npm",
        ["run", "build"],
        workingDirectory: dir,
        runInShell: true,
        environment: {
          "ENTRY": entryPath,
          "FILENAME": outputName,
          "OUTDIR": outPath,
        },
      );

      stdout.write(result.stdout);
      stderr.write(result.stderr);

      if (result.exitCode != 0) {
        logger.error("❌ Failed to build $fileName");
      } else {
        logger.info("✅ Built $outputName.js");
      }
    }

    logger.info("🎉 All workers built!");
  } catch (e, st) {
    logger.handle(e, st);
  }
}
