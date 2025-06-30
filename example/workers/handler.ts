class Handler { }

class Responser {
    success(command: string, message: Record<string, string>): void { //? Что такое Record
        self.postMessage(JSON.stringify({
            status: "success",
            command: command,
            result: message,
        }));
    }

    error(command: string, message: string): void {
        self.postMessage(JSON.stringify({ status: "error", command: command, message: message }));
    }
}
