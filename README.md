
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
      - [Worker Response Format](#worker-response-format)
    - [3. Build a module worker](#3-build-a-module-worker)
    - [4. Use a worker in Flutter Web](#4-use-a-worker-in-flutter-web)
- [🧩 Structure](#-structure)
- [📚 API](#-api)
  - [`FlutterNodeWorker`](#flutternodeworker)
    - [Methods](#methods)
- [CLI-commands](#cli-commands)
  - [`init` — Generate worker template](#init--generate-worker-template)
  - [`build` — Build worker module via Vite](#build--build-worker-module-via-vite)
  - [`add` — Add new worker script](#add--add-new-worker-script)
  - [`install` — Install npm package to worker](#install--install-npm-package-to-worker)
  - [`uninstall` — Remove npm package](#uninstall--remove-npm-package)
  - [CLI Arguments](#cli-arguments)
- [🛠️ Dependencies](#️-dependencies)
- [🖼️ Demo](#️-demo)
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
dart run flutter_node_worker init --dir my_worker --name encryptor
```

Creates a template in the `my_worker/` folder with the worker name `encryptor`.

Additionally, this will generate a `Makefile` and a Bash script `fnw` in your project root, allowing you to run commands with shorter syntax.

📌 See [CLI-commands](#CLI-commands) below for details on using `dart run`, `./fnw`, or `make`.

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
dart run flutter_node_worker install <package-name> --dir my_worker
```

*or:*

```bash
cd my_worker
npm install <package-name>
```

##### Worker Response Format
> The worker **must return a `String` representation of a `Map`** (i.e., a JSON object).  
> This response **must include a `status` field**, which should be either `"success"` or `"error"`.

Use `JSON.stringify()` to serialize your result before sending it:

```js
// ✅ Correct: sending a valid JSON string with required `status` field
postMessage(JSON.stringify({
  status: "success",
  data: {
    encrypted: "abc123"
  }
}));

// ❌ Incorrect: sending a raw object (will fail in Dart)
postMessage({
  status: "success",
  data: {
    encrypted: "abc123"
  }
}); // ❌ Will cause an error — Dart expects a String

// ❌ Incorrect: missing `status` field
postMessage(JSON.stringify({
  data: {
    encrypted: "abc123"
  }
}));
```

In Dart, this response will be automatically parsed with `jsonDecode()` into a `Map<String, dynamic>`. The `status` field is used to determine whether the operation was successful or resulted in an error.

#### 3. Build a module worker

```bash
dart run flutter_node_worker build --dir my_worker --out-dir ../web/workers
```

_or:_

```bash
cd my_worker
npm run build
```

Creates a built module worker in `web/workers/` with the worker name + module.js (in this example `encryptor_module.js`). It can now be used in Dart code. If you do not specify `--out-dir`, the worker will be built in `my_worker/dist/`. The `--out-dir` should be specified **relative to the worker's directory**, not the project root.  
For example, if your worker is in `my_worker`, use `--out-dir=../web/workers`.

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
	
    - `timeoutDuration` — a `Duration` specifying the maximum amount of time to wait for a response from the worker. If no response is received within this period, a `TimeoutException` will be thrown.
        
- `terminate()`  
    Manually terminates the worker, freeing up resources.
    

---

## CLI-commands

Each command can be run in **one of three ways**:

| Method      | Example                                                              |
| ----------- | -------------------------------------------------------------------- |
| `dart run`  | `dart run flutter_node_worker init --dir my_worker --name encryptor` |
| Bash script | `./fnw init --dir my_worker --name encryptor`                        |
| Makefile    | `make init dir=my_worker name=encryptor`                             |

---

### `init` — Generate worker template

```bash
dart run flutter_node_worker init --dir my_worker --name encryptor
./fnw init --dir my_worker --name encryptor
make init dir=my_worker name=encryptor
```

---

### `build` — Build worker module via Vite

```bash
dart run flutter_node_worker build --dir my_worker --out-dir ../web/workers
./fnw build --dir my_worker --out-dir ../web/workers
make build-worker dir=my_worker out-dir=../web/workers
```

The `--out-dir` should be specified **relative to the worker's directory**, not the project root.  
For example, if your worker is in `my_worker`, use `--out-dir=../web/workers`.

---

### `add` — Add new worker script

```bash
dart run flutter_node_worker add --dir my_worker --name decryptor
./fnw add --dir my_worker --name decryptor
make add dir=my_worker name=decryptor
```

---

### `install` — Install npm package to worker

```bash
dart run flutter_node_worker install uuid --dir my_worker
./fnw install uuid --dir my_worker
make install dir=my_worker pkgs=uuid
```

---

### `uninstall` — Remove npm package

```bash
dart run flutter_node_worker uninstall uuid --dir my_worker
./fnw uninstall uuid --dir my_worker
make uninstall dir=my_worker pkgs=uuid
```

---

### CLI Arguments

| Argument    | Abbreviation | Description                                                                   |
| ----------- | ------------ | ----------------------------------------------------------------------------- |
| `--dir`     | `-d`         | The directory in which the command is executed (`init`, `build`, `add`, etc.) |
| `--name`    | `-n`         | Worker name when initializing or adding a new one                             |
| `--out-dir` | `-o`         | Directory where the compiled module will be placed                            |

---

## 🛠️ Dependencies

- [Node.js](https://nodejs.org/)
    
- [Vite](https://vitejs.dev/)
    
- [cli_util](https://pub.dev/packages/cli_util)
    
- [args](https://pub.dev/packages/args)
    
- [mustache_template](https://pub.dev/packages/mustache_template)
    
- [dart:js_interop](https://dart.dev/web/js-interop)
	
- [path](https://pub.dev/packages/path)

- [talker](https://pub.dev/packages/talker)
    

---

## 🖼️ Demo

The demo application allows you to encrypt and decrypt a message using a password.
For clarity, an animation has been added demonstrating that the main thread is not blocked - the UI remains responsive even when performing heavy operations.

By opening DevTools → **Sources → Threads**, you can see the active threads, including the Web Worker (`cipher_module.js`), where the calculation takes place.

[CHECK WEB DEMO](https://flutter-node-worker-demo.web.app/)

---

## 🤝 Support

Open an issue or pull request. Any help is appreciated!

---

## 🤝 Contributors

Thanks to all these amazing people:

[![Contributors](https://contrib.rocks/image?repo=printHelloworldd/flutter-node-worker)](https://github.com/printHelloworldd/flutter-node-worker/graphs/contributors)
