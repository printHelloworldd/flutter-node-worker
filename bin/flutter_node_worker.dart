import "dart:io";
import "package:args/args.dart";
import 'commands/add.dart';
import 'commands/build.dart';
import 'commands/init.dart';
import 'commands/install.dart';
import 'commands/uninstall.dart';
import 'utils/logger.dart';

Future<void> main(List<String> arguments) async {
  const List<String> commands = [
    "init",
    "build",
    "add",
    "install",
    "uninstall",
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
      await handleInit(parsedCommandArgs);
      break;
    case "build":
      handleBuildAll(parsedCommandArgs);
      break;
    case "add":
      handleAdd(parsedCommandArgs);
      break;
    case "install":
      handleInstall(parsedCommandArgs);
      break;
    case "uninstall":
      handleUninstall(parsedCommandArgs);
      break;
    default:
      logger.log("Unknown command: ${command.name}");
  }
}
