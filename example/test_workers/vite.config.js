import { defineConfig } from "vite";
import { resolve } from 'path';

export default defineConfig(({ command, mode, isSsrBuild, isPreview }) => {
    const isDev = command === "serve";

    if (command === "serve") {
        return {
            // dev specific config
        }
    } else {
        // command === "build"
        return {
            define: {
                global: "globalThis"
            },
            resolve: {
                alias: {
                    buffer: "buffer",
                },
            },
            optimizeDeps: {
                include: [],
                esbuildOptions: {
                    // Node.js global to browser globalThis
                    define: {
                        global: "globalThis"
                    },
                }
            },
            build: {
                outDir: process.env.OUTDIR || "dist",
                rollupOptions: {
                    input: resolve(__dirname, process.env.ENTRY || 'src/cipher.js'),
                    output: {
                        entryFileNames: () => process.env.FILENAME || 'output.js',
                        format: "es"
                    }
                },
                emptyOutDir: false,
                target: "esnext",
                minify: !isDev,
                sourcemap: !isDev,
            }
        }
    }
})