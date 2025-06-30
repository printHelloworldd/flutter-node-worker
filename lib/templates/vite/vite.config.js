import { defineConfig } from "vite";
import { resolve } from 'path';

export default defineConfig(({ command, mode, isSsrBuild, isPreview }) => {
    if (command === "serve") {
        return {
            // dev specific config
        }
    } else {
        // command === "build"
        return {
            define: {
                global: "globalThis" // важно для node-forge
            },
            resolve: {
                alias: {
                    buffer: "buffer", // чтобы node-forge мог использовать Buffer
                },
            },
            optimizeDeps: {
                include: [],
                esbuildOptions: {
                    // Node.js global to browser globalThis
                    define: {
                        global: "globalThis"
                        // global: {},
                    },
                    // Enable esbuild polyfill plugins
                    // plugins: [
                    //     NodeGlobalsPolyfillPlugin({
                    //         buffer: true
                    //     })
                    // ]
                }
            },
            build: {
                outDir: process.env.OUTDIR || "dist",
                rollupOptions: {
                    input: resolve(__dirname, process.env.ENTRY || 'src/cipher.js'),
                    output: {
                        entryFileNames: () => process.env.FILENAME || 'output.js', // имя итогового файла
                        format: "es" // важно: чтобы работал `type: "module"`
                    }
                },
                emptyOutDir: false, // <- не удаляем dist между сборками
                target: "esnext", // чтобы не было ошибок с modern JS
                minify: false, // отключи на время отладки
                sourcemap: true, // удобно для отладки
            }
        }
    }
})