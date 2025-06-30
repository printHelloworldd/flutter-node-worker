flutter_node_worker
## 📖 Description

`flutter_node_worker` is a tool and library for Flutter Web that enables **[multithreading](https://en.wikipedia.org/wiki/Multithreading_(computer_architecture)) via [Web Workers](https://developer.mozilla.org/en-US/docs/Web/API/Web_Workers_API/Using_web_workers)** written in [Node.js](https://nodejs.org/).

Unlike Flutter on other platforms, **[Isolate](https://docs.flutter.dev/perf/isolates) is not supported on Web**, making it impossible to perform heavy computations outside the main thread. To avoid blocking the UI during long operations, it is recommended to use **Web Workers**, and this is what this package provides.

This is especially useful for cryptographic operations, parsing, computing, and any CPU-intensive operations.

---

## 📦 Features

- ✍️ `Node.js` worker logic using any `npm` packages
	
- ⚒️ Automatic project template generation (`init`)
	
- ⚡ Build via `Vite`
	
- 🧠 Integration of Web Workers into Flutter with a type-safe API
	
- 🎯 Support for multi-command logic and data transfer in both directions

---

## 🧠 Where to use

- Cryptographic methods
- Large calculations (parsing, math, crypto)
- JSON → Protobuf / MsgPack conversion
- Working with npm libraries directly from Flutter
- Parsers, transformers and generators

---

## Table of contents
- [📖 Description](#-description)
- [📦 Features](#-features)
- [🧠 Where to use](#-where-to-use)
- [Table of contents](#table-of-contents)
- [📥 Get started](#-get-started)
  - [Add dependency](#add-dependency)
  - [🚀 Quick start and usage example](#-quick-start-and-usage-example)
    - [1. Initialize a new worker](#1-initialize-a-new-worker)
    - [2. 🔒 Write the worker logic](#2--write-the-worker-logic)
    - [3. Build a module worker](#3-build-a-module-worker)
    - [4. Use a worker in Flutter Web](#4-use-a-worker-in-flutter-web)
- [🧩 Structure](#-structure)
- [📚 API](#-api)
  - [`FlutterNodeWorker`](#flutternodeworker)
    - [Methods](#methods)
- [📦 CLI commands](#-cli-commands)
  - [CLI Arguments](#cli-arguments)
- [🛠️ Dependencies](#️-dependencies)
- [🖼️ Demo](#️-demo)
- [🚀 What's Next](#-whats-next)
- [🤝 Support](#-support)
- [🤝 Contributors](#-contributors)

---

## 📥 Get started

### Add dependency

```yaml
dependencies:
  flutter_node_worker: any
```

or using command

```bash
flutter pub add flutter_node_worker
```

Install dependencies:

```bash
flutter pub get
```

### 🚀 Quick start and usage example

#### 1. Initialize a new worker
```bash
dart run fnw init --dir my_worker --name encryptor
```

Creates a template in the `my_worker/` folder with the worker name `encryptor`.

#### 2. 🔒 Write the worker logic

Inside `src/encryptor.js` (for example, a cryptographic method for encrypting data):

```js
import forge from 'node-forge';

self.onmessage = function (e) {
  const { command, data } = e.data;

  if (command === "encrypt") {
    const result = encrypt(data.message, data.password);
    self.postMessage(JSON.stringify({ status: "success", command, result: { message: result } }));
  }
}

function encrypt(message, password) {
	// Encryption logic
}
```

If the worker will use a third-party library, it can be imported as an ES module, but don't forget to install it using:

```bash
dart run fnw install <package-name> --dir my_worker
```

*or:*

```bash
cd my_worker
npm install <package-name>
```

#### 3. Build a module worker

```bash
dart run fnw build --dir my_worker --out-dir web/workers
```

_or:_

```bash
cd my_worker
npm run build
```

Creates a built module worker in `web/workers/` with the worker name + module.js (in this example `encryptor_module.js`). It can now be used in Dart code. If you do not specify `--out-dir`, the worker will be built in `my_worker/dist/`

---

#### 4. Use a worker in Flutter Web

```dart
final worker = FlutterNodeWorker(path: "my_worker/dist/encryptor_module.js");

final result = await worker.compute(
  command: "encrypt",
  data: {"message": "Hello", "password": "secret"},
);
```

---

## 🧩 Structure

```text
my_worker/
├── package.json
├── vite.config.js
├── src/
│   └── encryptor.js       // Your worker logic
├── dist/
│   └── encryptor_module.js  // Compiled worker module
```

---

## 📚 API

### `FlutterNodeWorker`

```dart
FlutterNodeWorker({required String path})
```

#### Methods

- `compute({command, data, computeOnce})`  
    Sends a command and data to the worker and returns the result.
    
    - If `computeOnce = true` _(default is `false`)_, the worker will automatically exit after the command is executed - useful for rare operations like generating cryptographic keys on registration.
        
    - If `computeOnce = false`, the worker remains active, which is suitable for frequent tasks such as encrypting chat messages.
        
- `terminate()`  
    Manually terminates the worker, freeing up resources.
    

---

## 📦 CLI commands

- `init` — Generates worker template  
    `dart run fnw init --dir my_worker --name encryptor`
    
- `build` — Builds worker module via Vite
    `dart run fnw build --dir my_worker --out-dir web/workers`
    
- `add` — Adds new worker script
    `dart run fnw add --dir my_worker --name decryptor`
    
- `install` — Installs `npm` package
    `dart run fnw install <package-name> --dir my_worker`
    
- `uninstall` — Removes `npm` package  
    `dart run fnw uninstall <package-name> --dir my_worker`

### CLI Arguments

| Argument    | Abbreviation | Description                                                                   |
| ----------- | ------------ | ----------------------------------------------------------------------------- |
| `--dir`     | `-d`         | The directory in which the command is executed (`init`, `build`, `add`, etc.) |
| `--name`    | `-n`         | Worker name when initializing or adding a new one                             |
| `--out-dir` | `-o`         | The directory where the worker will be compiled                               |

---

## 🛠️ Dependencies

- [Node.js](https://nodejs.org/)
    
- [Vite](https://vitejs.dev/)
    
- [cli_util](https://pub.dev/packages/cli_util)
    
- [args](https://pub.dev/packages/args)
    
- [mustache_template](https://pub.dev/packages/mustache_template)
    
- [dart:js, dart:js_interop](https://dart.dev/web/js-interop)
	
- [path](https://pub.dev/packages/path)
    

---

## 🖼️ Demo

The demo application allows you to encrypt and decrypt a message using a password.
For clarity, an animation has been added demonstrating that the main thread is not blocked - the UI remains responsive even when performing heavy operations.

By opening DevTools → **Sources → Threads**, you can see the active threads, including the Web Worker (`cipher_module.js`), where the calculation takes place.

[CHECK WEB DEMO](https://flutter-node-worker-demo.web.app/)

---

## 🚀 What's Next

- [ ] Cover the project with unit and integration tests

- [ ] Switch from `dart:js` to `dart:js_interop` for safer and more typed work with JavaScript

- [ ] Improve Web Worker error handling

- [ ] Add logging and notifications when the worker crashes

- [ ] Support for custom templates and configurations

---

## 🤝 Support

Open an issue or pull request. Any help is appreciated!

---

## 🤝 Contributors

Thanks to all these amazing people:

[![Contributors](https://contrib.rocks/image?repo=printHelloworldd/flutter-node-worker)](https://github.com/printHelloworldd/flutter-node-worker/graphs/contributors)
