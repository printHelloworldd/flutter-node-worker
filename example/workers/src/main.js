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

// const worker = new Worker("/src/cipher.js");

// // Храни промисы, чтобы идентифицировать ответ
// let requestId = 0;
// const pendingRequests = new Map();

// worker.onmessage = (e) => {
//   const { id, result, error } = e.data;

//   const resolve = pendingRequests.get(id);
//   if (resolve) {
//     pendingRequests.delete(id);
//     resolve(result);
//   }
// };

// function postToWorker(command, data) {
//   return new Promise((resolve) => {
//     const id = requestId++;
//     pendingRequests.set(id, resolve);

//     worker.postMessage({
//       id,
//       command,
//       data,
//     });
//   });
// }
