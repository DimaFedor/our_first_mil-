import {evaluateLanguage} from './evaluate.mjs';

let python;
let dartWorker;
const loadPython = async () => {
  if (!python) {
    importScripts('pyodide/pyodide.js');
    python = await self.loadPyodide({indexURL: 'pyodide/'});
  }
  return python;
};
self.onmessage = async event => {
  const request = typeof event.data === 'string' ? JSON.parse(event.data) : event.data;
  const language = request.challenge?.language;
  if (['python', 'javascript', 'js', 'react', 'jsx'].includes(language)) {
    const result = await evaluateLanguage(request, loadPython);
    self.postMessage(JSON.stringify(result));
  } else {
    dartWorker = new Worker('practice_worker.js');
    dartWorker.onmessage = event => { self.postMessage(event.data); dartWorker.terminate(); };
    dartWorker.onerror = () => self.postMessage(JSON.stringify({passed: false, diagnostic: 'workerUnavailable'}));
    dartWorker.postMessage(JSON.stringify(request));
  }
};
