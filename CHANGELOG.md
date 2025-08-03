# Changelog

All notable changes to this project will be documented in this file.

## [0.0.4] - 2025-08-03

### Changed
- Flutter SDK version.
- Dependencies versions.

## [0.0.3] - 2025-07-12

### Added
- Added `timeoutDuration` parameter to the `compute` method in `FlutterNodeWorker` API
- Added support for older Dart SDK versions
- Added code documentation for public classes and methods
- Added logging with the `talker` package

### Changed
- Migrated from `dart:js` to `dart:js_interop` for better compatibility and future-proofing;
  The package now fully supports **WASM (WebAssembly)** compilation for Flutter Web.

## [0.0.2] - 2025-07-01

### Added
- Added `example/` project to the published package on pub.dev

### Fixed
- Fixed syntax issue in the documented CLI `init` command example
- Corrected Vite installation via `npm`

## [0.0.1] – Initial release

### Added
- CLI commands: `init`, `add`, `build`, `install`, `uninstall`
- Template generation for Web Workers with Vite configuration
- Makefile and Bash wrapper (`fnw`) for easier CLI usage
- Support for `--dir`, `--name`, and `--out-dir` arguments
- Example project with demo UI
- API for integrating with Web Workers from Dart (`FlutterNodeWorker`)

---

Generated using [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
