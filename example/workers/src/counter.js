self.postMessage(JSON.stringify({ status: "ready" }));

self.onmessage = async function (e) {
  console.log("[worker] Received message:", e.data);

  try {
    const { command, data } = e.data;

    if (command === "say_hello") {
      console.log("[worker] Command is generate_data");

      const result = _sayHello(data.name);

      Responser().success(command, result);

      console.log("[worker] Sent success message");

    } else if (command === "say_goodbye") {
      const result = _sayGoodbye(data.name);

      Responser().success(command, result);
    }
  } catch (error) {
    Responser().error(command, error.message);
  }
};

function _sayHello(name) {
  return `Hello ${name} from Web Worker!`;
}

function _sayGoodbye(name) {
  return `Goodbye ${name} from Web Worker!`;
}
