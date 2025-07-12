import "dart:io";
import "dart:isolate";

import "package:mustache_template/mustache.dart";
import "package:path/path.dart" as p;
import "constants.dart";
import 'logger.dart';

/// A utility class that provides helper methods for handling template files,
/// rendering them with variable substitution, copying and modifying files,
/// and cleaning up generated directories.
class Utils {
  /// Resolves the full file system path to a template file given its [relativePath]
  /// within the package.
  ///
  /// It first attempts to resolve the path using `Isolate.resolvePackageUri`.
  /// If that fails (e.g. during local development), it falls back to computing
  /// the path manually from the script's location.
  ///
  /// Throws an [Exception] if the resolved file does not exist.
  static Future<String> resolveTemplatePath(String relativePath) async {
    try {
      final uri = Uri.parse("package:$packageName/templates/$relativePath");
      final resolved = await Isolate.resolvePackageUri(uri);

      if (resolved == null) {
        // Fallback for local development
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
      throw Exception("Failed to resolve template path: $e");
    }
  }

  /// Renders a single template file located at [inputPath] and writes the rendered
  /// output to [outputPath], substituting variables from [variables].
  ///
  /// If the output file already exists, prompts the user whether to:
  /// - Overwrite the file (`O`)
  /// - Append the rendered output to the end (`A`)
  /// - Skip rendering this file (`S`)
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

  /// Recursively copies and renders all template files from the [from] directory
  /// to the [to] directory.
  ///
  /// Replaces template variable placeholders using [vars].
  ///
  /// Adjusts paths dynamically based on the presence of the `workerName` variable
  /// or if the file is under the `vite/` directory (which is replaced with [targetWorkerDir]).
  ///
  /// Makes shell scripts (`.sh` files) executable by running `chmod +x`.
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

  /// Deletes specific generated files from the [from] directory.
  ///
  /// This method is typically used to clean up files that are no longer needed.
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
