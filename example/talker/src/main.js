import Worker from "./worker?worker";

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
