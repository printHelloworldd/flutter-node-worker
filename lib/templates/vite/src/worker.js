self.postMessage(JSON.stringify({ status: "ready" }));

self.onmessage = async function (e) {
    console.log("[worker] Received message:", e.data);

    try {
        const { command, data } = e.data;

        if (command === "say_hello") {

            console.log(`[worker] Command is ${command}`);

            const result = _sayHello(data.message);

            self.postMessage(JSON.stringify({
                status: "success",
                command: command,
                result: {
                    message: result,
                },
            }));

            console.log("[worker] Sent success message");

        } else if (command === "say_goodbye") {

            console.log(`[worker] Command is ${command}`);

            const result = _sayGoodbye(data.message);

            self.postMessage(JSON.stringify({
                status: "success",
                command: command,
                result: {
                    message: result,
                },
            }));

            console.log("[worker] Sent success message");

        }
    } catch (error) {
        self.postMessage(JSON.stringify({ status: "error", command: e.data.command, message: error.message }));
    }
};

function _sayHello(name) {
    return `Hello ${name} from Web Worker!`;
}

function _sayGoodbye(name) {
    return `Goodbye ${name} from Web Worker!`;
}