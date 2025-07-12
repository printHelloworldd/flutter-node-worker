import 'dart:io';

import 'package:args/args.dart';

import '../utils/logger.dart';
import '../utils/utils.dart';

void handleAdd(ArgResults initArgs) async {
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
