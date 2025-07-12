import "dart:io";
import "package:args/args.dart";
import 'package:path/path.dart' as p;
import 'package:talker/talker.dart';
import 'utils.dart';

final logger = Talker();

Future<void> main(List<String> arguments) async {
  const List<String> commands = [
    "init",
    "build",
    "add",
    "install",
    "uninstall",
    "run",
  ];

  const Map<String, Map<String, String>> options = {
    "dir": {"abbr": "d", "defaultsTo": "workers"},
    "name": {"abbr": "n", "defaultsTo": "worker"},
    "out-dir": {"abbr": "o", "defaultsTo": "dist"},
  };

  ArgParser parser = ArgParser();
  for (String command in commands) {
    parser.addCommand(command);
  }
  options.forEach(
    (key, value) => value.isNotEmpty
        ? parser.addOption(
            key,
            abbr: value["abbr"],
            defaultsTo: value["defaultsTo"],
          )
        : parser.addOption(key),
  );

  final ArgResults results = parser.parse(arguments);

  final ArgResults? command = results.command;
  if (arguments.isEmpty) {
    logger.info("Usage: dart run flutter_node_worker <command> [options]");
    logger.info("Commands: $commands");
    exit(1);
  } else if (command == null) {
    logger.error("Unknown command: '${arguments.first}'");
    exit(1);
  }

  final ArgResults parsedCommandArgs = parser.parse(command.arguments);

  switch (command.name) {
    case "init":
      await _handleInit(parsedCommandArgs);
      break;
    case "build":
      _handleBuildAll(parsedCommandArgs);
      break;
    case "add":
      _handleAdd(parsedCommandArgs);
      break;
    case "install":
      _handleInstall(parsedCommandArgs);
      break;
    case "uninstall":
      _handleUninstall(parsedCommandArgs);
      break;
    case "run":
      _handleRun(parsedCommandArgs);
      break;
    default:
      logger.log("Unknown command: ${command.name}");
  }
}

Future<void> _handleInit(ArgResults initArgs) async {
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

void _handleBuildAll(ArgResults initArgs) {
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

void _handleAdd(ArgResults initArgs) async {
  try {
    logger.info("Adding new worker...");

    final String dir = initArgs["dir"] as String;
    final String name = initArgs["name"] as String;

    final Directory targetDir = Directory(dir);
    if (!targetDir.existsSync()) {
      throw Exception("No such derectory: $dir");
    }

    final resolvedPath = await Utils.resolveTemplatePath('vite/src/worker.js');

    Utils.renderTemplateFile(
      inputPath: resolvedPath,
      outputPath: '$dir/src/$name.js',
      variables: {'workerName': name},
    );

    logger.info("Added worker to $dir");
  } catch (e, st) {
    logger.handle(e, st);
  }
}

void _handleInstall(ArgResults initArgs) {
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

void _handleUninstall(ArgResults initArgs) {
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

void _handleRun(ArgResults initArgs) {
  try {
    logger.info("Running vite project...");

    final String dir = initArgs["dir"] as String;

    final Directory targetDir = Directory(dir);
    if (!targetDir.existsSync()) {
      throw Exception("No such derectory: $dir");
    }

    final result = Process.runSync(
      "npm",
      ["run", "dev"],
      workingDirectory: dir,
      runInShell: true,
    );

    if (result.exitCode != 0) {
      logger.error("❌ Failed to uninstall packages");
    } else {
      logger.info("✅ Uninstalled packages");
    }
  } catch (e, st) {
    logger.handle(e, st);
  }
}
