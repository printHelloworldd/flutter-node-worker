/// This file serves as a development/testing entry point for the worker.
///
/// It imports the worker script dynamically using the provided [workerName] variable,
/// allowing you to test the worker locally via the command in worker directory:
/// ```
/// npm run dev
/// ```
///
/// The script:
/// - Creates a new instance of the worker.
/// - Listens for messages from the worker and logs the results to the console.
/// - Sends a test message with the command `"say_hello"` and data `{ message: "world" }`
///   to verify the worker's response.
///
/// This template file should be rendered with the actual worker name replacing `{{workerName}}`.

import Worker from "./{{workerName}}?{{workerName}}";

const worker = new Worker();

worker.onmessage = (e) => {
    console.log("Worker result:", e.data);
};

worker.postMessage({
    command: "say_hello",
    data: {
        message: "world"
    },
});
