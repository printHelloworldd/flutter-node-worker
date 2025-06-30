import forge from 'node-forge';
import { hkdf } from '@noble/hashes/hkdf.js';
import { sha256 } from '@noble/hashes/sha2.js';

self.postMessage(JSON.stringify({ status: "ready" }));

self.addEventListener('error', (e) => {
    self.postMessage(JSON.stringify({ status: 'error', message: e.message }));
});

self.onmessage = async function (e) {
    console.log("[worker] Received message:", e.data);

    try {
        const { command, data } = e.data;

        if (command === "encrypt") {
            console.log("[worker] Command is encrypt");

            const result = _encrypt(data.message, data.password);

            self.postMessage(JSON.stringify({
                status: "success",
                command: command,
                result: {
                    encrypted: result,
                },
            }));

            console.log("[worker] Sent success message");

        } else if (command === "decrypt") {
            console.log("[worker] Command is encrypt");

            const result = _decrypt(data.encryptedMessage, data.password);

            self.postMessage(JSON.stringify({
                status: "success",
                command: command,
                result: {
                    decrypted: result,
                },
            }));

            console.log("[worker] Sent success message");
        }
    } catch (error) {
        self.postMessage(JSON.stringify({ status: "error", command: e.data.command, message: error.message }));
    }
};

function _encrypt(data, password) {
    // generate a random key and IV
    // Note: a key size of 16 bytes will use AES-128, 24 => AES-192, 32 => AES-256
    var key = forge.util.hexToBytes(generateAesKey(password));
    var iv = forge.random.getBytesSync(16);

    /* alternatively, generate a password-based 16-byte key
    var salt = forge.random.getBytesSync(128);
    var key = forge.pkcs5.pbkdf2('password', salt, numIterations, 16);
    */

    // encrypt some bytes using CBC mode
    // (other modes include: ECB, CFB, OFB, CTR, and GCM)
    // Note: CBC and ECB modes use PKCS#7 padding as default
    var cipher = forge.cipher.createCipher('AES-CBC', key);
    cipher.start({ iv: iv });
    cipher.update(forge.util.createBuffer(forge.util.encodeUtf8(data)));
    cipher.finish();
    var encrypted = cipher.output;

    // outputs encrypted hex
    return forge.util.bytesToHex(iv) + "::" + encrypted.toHex();
}

function _decrypt(encryptedData, password) {
    // generate a random key and IV
    // Note: a key size of 16 bytes will use AES-128, 24 => AES-192, 32 => AES-256
    var key = forge.util.hexToBytes(generateAesKey(password));
    var iv = forge.util.hexToBytes(encryptedData.split("::")[0]);
    console.log(iv);
    var encrypted = forge.util.hexToBytes(encryptedData.split("::")[1]);
    console.log(encrypted);

    /* alternatively, generate a password-based 16-byte key
    var salt = forge.random.getBytesSync(128);
    var key = forge.pkcs5.pbkdf2('password', salt, numIterations, 16);
    */

    // decrypt some bytes using CBC mode
    // (other modes include: CFB, OFB, CTR, and GCM)
    var decipher = forge.cipher.createDecipher('AES-CBC', key);
    decipher.start({ iv: iv });
    decipher.update(forge.util.createBuffer(encrypted));
    var result = decipher.finish(); // check 'result' for true/false

    // outputs decrypted hex
    return forge.util.decodeUtf8(forge.util.hexToBytes(decipher.output.toHex()));
}

function generateAesKey(password) {
    // generate a password-based 16-byte key
    // note an optional message digest can be passed as the final parameter
    var salt = deriveSaltFromPassword(password);
    var derivedKey = forge.pkcs5.pbkdf2(password, salt, numIterations, 16);

    return derivedKey;
}

// function generateAesKey(password) {
//     var md = forge.md.sha256.create();
//     md.update(password);
//     const entropy = md.digest().toHex();

//     const key = generatePRNG(entropy, "encryption");

//     return key;
// }

function generatePRNG(entropy, info) {
    const salt = deriveSaltFromPassword(entropy);
    const seedBinary = forge.util.hexToBytes(entropy);

    const hk1 = hkdf(sha256, seedBinary, salt, info, 32);

    return forge.util.bytesToHex(hk1);
}

function deriveSaltFromPassword(data) {
    var md = forge.md.sha256.create();
    md.update(data);
    const salt = md.digest().toHex();

    return salt;
}