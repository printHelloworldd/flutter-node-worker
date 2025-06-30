import Worker from "./cipher?cipher";

const worker = new Worker();

worker.onmessage = (e) => {
    console.log("Worker result:", e.data);
};

worker.postMessage({
    command: "encrypt",
    data: {
        message: "Hello",
        password: "secret",
    },
});
