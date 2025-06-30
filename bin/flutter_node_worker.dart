import "dart:io";
import "package:args/args.dart";
import 'package:path/path.dart' as p;
import 'utils.dart';

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
    (key, value) =>
        value.isNotEmpty
            ? parser.addOption(
              key,
              abbr: value["abbr"],
              defaultsTo: value["defaultsTo"],
            )
            : parser.addOption(key),
  );

  final ArgResults results = parser.parse(arguments);

  final ArgResults? command = results.command;
  if (command == null) {
    print("Usage: fmw <command> [options]");
    print("Commands: $commands");
    exit(0);
  }
  final ArgResults initArgs = parser.parse(command.arguments);

  switch (command.name) {
    case "init":
      await _handleInit(initArgs);
      break;
    case "build":
      _handleBuildAll(initArgs);
      break;
    case "add":
      _handleAdd(initArgs);
      break;
    case "install":
      _handleInstall(initArgs);
      break;
    case "uninstall":
      _handleUninstall(initArgs);
      break;
    case "run":
      _handleRun(initArgs);
      break;
    default:
      print("Unknown command: ${command.name}");
  }
}

Future<void> _handleInit(ArgResults initArgs) async {
  print("Initializing module worker...");

  final String dir = initArgs["dir"] as String;
  final String name = initArgs["name"] as String;
  // final String template = initArgs["template"] as String;

  final Directory targetDir = Directory(dir);
  if (!targetDir.existsSync()) {
    targetDir.createSync(recursive: true);
  }

  Process.runSync("npm", [
    "create",
    "vite@latest",
    dir,
    "--",
    "--template",
    "vanilla",
  ], runInShell: true);

  Process.runSync("npm", ["install"], runInShell: true);

  final resolvedPath = await Utils.resolveTemplatePath('/');

  await Utils.copyAndRenderTemplates(
    from: resolvedPath,
    to: "./",
    vars: {"workerName": name},
    targetWorkerDir: dir,
  );

  Utils.clearDirectory(dir);

  print("The module worker was initialized successfully.");
}

void _handleBuildAll(ArgResults initArgs) {
  final String dir = initArgs["dir"] as String;
  final String outPath = initArgs["out-dir"] as String;

  print("🔧 Auto-building all workers in '$dir/src/' using Vite...");

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

  final entryFiles =
      srcDir
          .listSync()
          .whereType<File>()
          .where(
            (f) =>
                f.path.endsWith(".ts") ||
                f.path.endsWith(".js") && !f.path.contains("main.js"),
          )
          .toList();

  if (entryFiles.isEmpty) {
    print("⚠️ No .ts or .js files found in src/");
    return;
  }

  for (final file in entryFiles) {
    final fileName = p.basename(file.path);
    final entryPath = p.relative(file.path, from: dir);
    final outputName = "${p.basenameWithoutExtension(fileName)}_module.js";

    print("📦 Building: $fileName → dist/$outputName.js");

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
      print("❌ Failed to build $fileName");
    } else {
      print("✅ Built $outputName.js");
    }
  }

  print("🎉 All workers built!");
}

void _handleAdd(ArgResults initArgs) async {
  print("Adding new worker...");

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

  print("Added worker to $dir");
}

void _handleInstall(ArgResults initArgs) {
  print("Installing npm packages...");

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
    print("❌ Failed to install packages");
  } else {
    print("✅ Installed packages");
  }

  print("🎉 All packages installed!");
}

void _handleUninstall(ArgResults initArgs) {
  print("Uninstalling npm packages...");

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
    print("❌ Failed to uninstall packages");
  } else {
    print("✅ Uninstalled packages");
  }

  print("🎉 All packages uninstalled!");
}

void _handleRun(ArgResults initArgs) {
  print("Running vite project...");

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
    print("❌ Failed to uninstall packages");
  } else {
    print("✅ Uninstalled packages");
  }
}
