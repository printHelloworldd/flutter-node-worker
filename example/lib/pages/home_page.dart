import 'package:flutter/material.dart';
import 'package:fmw/flutter_node_webworker.dart';
import 'package:lottie/lottie.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final inputTextController = TextEditingController();
  final passwordController = TextEditingController();

  String output = "Output is empty";

  final worker = FlutterNodeWebworker(path: "/workers/cipher_module.js");

  Future<String> encryptText(String text, String psw) async {
    final result = await worker.compute(
      command: "encrypt",
      data: {"message": text, "password": psw},
      computeOnce: false,
    );

    return result?["encrypted"] ?? "Couldn't encrypt the text";
  }

  Future<String> decryptText(String encrypted, String psw) async {
    final result = await worker.compute(
      command: "decrypt",
      data: {"encryptedMessage": encrypted, "password": psw},
      computeOnce: false,
    );

    if (result != null && result["decrypted"] != "") {
      return result["decrypted"];
    } else {
      return "Couldn't decrypt the text";
    }
  }

  @override
  void dispose() {
    super.dispose();
    worker.terminate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 200,
                child: Lottie.asset('assets/Animation.json'),
              ),
              TextField(
                controller: inputTextController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: "Enter here text to encrypt or decrypt",
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: "Password",
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  TextButton(
                    onPressed: () async {
                      final String encrypted = await encryptText(
                        inputTextController.text,
                        passwordController.text,
                      );

                      setState(() {
                        output = encrypted;
                      });
                    },
                    child: Text(
                      "Encrypt",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final String decrypted = await decryptText(
                        inputTextController.text,
                        passwordController.text,
                      );

                      setState(() {
                        output = decrypted;
                      });
                    },
                    child: Text(
                      "Decrypt",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32),
              Row(
                children: [
                  Expanded(child: Divider(thickness: 1, height: 1)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text("Output"),
                  ),
                  Expanded(child: Divider(thickness: 1, height: 1)),
                ],
              ),
              SizedBox(height: 16),
              Text(output, style: TextStyle(color: Colors.grey)),
              SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  setState(() {
                    inputTextController.text = output;
                  });
                },
                child: Text(
                  "Paste into input textfield",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
