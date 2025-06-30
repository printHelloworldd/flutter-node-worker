import "dart:io";

void main(List<String> arguments) {
  if (arguments.isEmpty) {
    print("Commands: init, build, run");
    exit(0);
  }

  switch (arguments.first) {
    case "init":
      _init(arguments.sublist(1, -1));
      break;
    case "build":
      _build();
      break;
    case "run":
      _run();
      break;
    default:
      print("Unknown command: ${arguments.first}");
  }
}

void _init(List<String> args) {
  print("Initializing project...");

  final String dir = args.firstWhere((arg) => arg == "--dir").split(" ").last;
  final String name = args.firstWhere((arg) => arg == "--name").split(" ").last;

  Directory(dir).createSync();

  Process.runSync("npm", [
    "create",
    "vite@latest",
    dir,
    "--",
    "--template",
    "vanilla",
  ], runInShell: true);

  final String workerFilePath = "$dir/src/$name.js";
  File("$dir/src/counter.js").rename(workerFilePath);
  final String workerFileAsString =
      File("templates/worker.js").readAsStringSync();
  File(workerFilePath).writeAsString(workerFileAsString);
}

void _build() {
  print("Building worker using Vite...");
  Process.runSync(
    "npm",
    ["run", "build"],
    workingDirectory: "./workers",
    runInShell: true,
  );
}

void _run() {
  print("Running vite project in dev mode...");
  Process.runSync(
    "npm",
    ["run", "dev"],
    workingDirectory: "./workers",
    runInShell: true,
  );
}
