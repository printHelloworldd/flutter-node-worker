import "dart:io";
import "dart:isolate";

import "package:mustache_template/mustache.dart";
import "package:path/path.dart" as p;
import "package:talker/talker.dart";
import "constants.dart";

final Talker logger = Talker();

class Utils {
  static Future<String> resolveTemplatePath(String relativePath) async {
    try {
      final uri = Uri.parse("package:$packageName/templates/$relativePath");
      final resolved = await Isolate.resolvePackageUri(uri);

      if (resolved == null) {
        // Fallback для локальной разработки
        final scriptDir = File.fromUri(Platform.script).parent;
        final rootDir = scriptDir.path.contains('/example/')
            ? Directory(p.normalize(p.join(scriptDir.path, '../'))).absolute
            : Directory.current;
        final fullPath = p.join(rootDir.path, 'templates', relativePath);

        if (!File(fullPath).existsSync()) {
          throw Exception("Template not found: $fullPath");
        }

        return fullPath;
      }
      return resolved.toFilePath(windows: Platform.isWindows);
    } catch (e, st) {
      logger.handle(e, st);
      throw Exception("Failed to resolve template path");
    }
  }

  static void renderTemplateFile({
    required String inputPath,
    required String outputPath,
    required Map<String, String> variables,
  }) {
    final raw = File(inputPath).readAsStringSync();
    final template = Template(raw, htmlEscapeValues: false);
    final rendered = template.renderString(variables);

    final outputFile = File(outputPath);

    if (outputFile.existsSync()) {
      stdout.write(
        "The file '$outputPath' already exists. [O]verwrite/[A]ppend/[S]kip? (O/A/S, Enter=O): ",
      );
      final choice = stdin.readLineSync()?.trim().toUpperCase();
      if (choice == "S") {
        logger.info("Skipped: $outputPath");
        return;
      } else if (choice == "A") {
        outputFile.writeAsStringSync("\n$rendered", mode: FileMode.append);
        logger.info("Added to the end: $outputPath");
        return;
      } else if (choice == "O" || choice == null || choice.isEmpty) {
        outputFile.writeAsStringSync(rendered);
        logger.info("File overwritten: $outputPath");
        return;
      } else {
        logger.info("Unknown choice, skipped: $outputPath");
        return;
      }
    } else {
      outputFile.createSync(recursive: true);
    }

    outputFile.writeAsStringSync(rendered);
  }

  static Future<void> copyAndRenderTemplates({
    required String from,
    required String to,
    required String targetWorkerDir,
    required Map<String, String> vars,
  }) async {
    try {
      final srcDir = Directory(from);
      final dstDir = Directory(to);

      if (!srcDir.existsSync()) {
        throw Exception("The templates was not found: $from");
      }

      for (var entity in srcDir.listSync(recursive: true)) {
        if (entity is File) {
          String relativePath = p.relative(entity.path, from: srcDir.path);

          final String resolvedPath = await resolveTemplatePath(relativePath);

          if (vars.containsKey("workerName") &&
              vars["workerName"]!.isNotEmpty) {
            relativePath =
                relativePath.replaceAll("worker", vars["workerName"]!);
          }

          if (relativePath.startsWith("vite/")) {
            relativePath = relativePath.replaceFirst(
              "vite/",
              "$targetWorkerDir/",
            );
          }

          final outputPath = "${dstDir.path}/$relativePath";

          renderTemplateFile(
            inputPath: resolvedPath,
            outputPath: outputPath,
            variables: vars,
          );

          if (relativePath.endsWith(".sh")) {
            Process.runSync("chmod", ["+x", outputPath]);
          }
        }
      }
    } catch (e, st) {
      logger.handle(e, st);
    }
  }

  static void clearDirectory(String from) {
    final List<String> paths = [
      "$from/src/counter.js",
      "$from/src/javascript.svg",
    ];

    for (String path in paths) {
      if (File(path).existsSync()) {
        File(path).deleteSync();
      }
    }
  }
}
