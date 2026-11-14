import {build} from 'esbuild';
import {mkdir, copyFile} from 'node:fs/promises';

await mkdir('../../assets/runtime/pyodide', {recursive: true});
for (const name of ['pyodide.js', 'pyodide.asm.js', 'pyodide.asm.wasm', 'python_stdlib.zip', 'pyodide-lock.json']) await copyFile(`node_modules/pyodide/${name}`, `../../assets/runtime/pyodide/${name}`);
await build({entryPoints: ['worker.mjs'], bundle: true, minify: true, format: 'iife', platform: 'browser', outfile: '../../assets/runtime/language_worker.js'});
