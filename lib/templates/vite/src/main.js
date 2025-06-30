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
