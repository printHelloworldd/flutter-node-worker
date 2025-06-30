import 'dart:io';
import 'dart:isolate';

import 'package:mustache_template/mustache.dart';
import 'package:path/path.dart' as p;
import 'constants.dart';

class Utils {
  static Future<String> resolveTemplatePath(String relativePath) async {
    final uri = Uri.parse("package:$packageName/templates/$relativePath");
    final resolved = await Isolate.resolvePackageUri(uri);
    if (resolved == null) {
      throw Exception("Failed to resolve template path: $relativePath");
    }

    return resolved.toFilePath(windows: Platform.isWindows);
  }

  static void renderTemplateFile({
    required String inputPath,
    required String outputPath,
    required Map<String, String> variables,
  }) {
    final raw = File(inputPath).readAsStringSync();
    final template = Template(raw, htmlEscapeValues: false);
    final rendered = template.renderString(variables);
    File(outputPath).createSync(recursive: true);
    File(outputPath).writeAsStringSync(rendered);
  }

  static Future<void> copyAndRenderTemplates({
    required String from,
    required String to,
    required Map<String, String> vars,
  }) async {
    final srcDir = Directory(from);
    final dstDir = Directory(to);

    if (!srcDir.existsSync()) {
      throw Exception("The templates was not found: $from");
    }

    for (var entity in srcDir.listSync(recursive: true)) {
      if (entity is File) {
        // String relativePath = entity.path.substring(from.length + 1);
        String relativePath = p.relative(entity.path, from: srcDir.path);

        // final isTemplate = relativePath.endsWith(".template");

        // final outputPath =
        // "${dstDir.path}/${isTemplate ? relativePath.replaceFirst(".template", "") : relativePath}";

        if (vars.containsKey("workerName") && vars["workerName"]!.isNotEmpty) {
          relativePath = relativePath.replaceAll("worker", vars["workerName"]!);
        }

        final outputPath = "${dstDir.path}/$relativePath";

        final String resolvedPath = await resolveTemplatePath(relativePath);
        // if (isTemplate) {
        renderTemplateFile(
          inputPath: resolvedPath,
          outputPath: outputPath,
          variables: vars,
        );
        // } else {
        //   final outFile = File(outputPath);
        //   outFile.createSync(recursive: true);
        //   outFile.writeAsBytesSync(entity.readAsBytesSync());
        // }
      }
    }
  }

  static void clearDirectory(String from) {
    final List<String> paths = [
      "$from/src/counter.js",
      "$from/src/javascript.svg",
      // "$from/src/style.css",
      // "$from/index.html",
    ];

    for (String path in paths) {
      if (File(path).existsSync()) {
        File(path).deleteSync();
      }
    }

    // if (Directory("$from/public").existsSync()) {
    //   Directory("$from/public").deleteSync(recursive: true);
    // }
  }
}
