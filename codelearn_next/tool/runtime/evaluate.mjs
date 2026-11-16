import * as Babel from '@babel/standalone';

export function formatValue(value) {
  if (Array.isArray(value)) return `[ ${value.map(formatValue).join(', ')} ]`;
  if (value && typeof value === 'object') return JSON.stringify(value);
  return String(value);
}
export async function evaluateLanguage(request, pythonLoader) {
  const {code, challenge} = request;
  const playground = request.mode === 'playground';
  const tests = playground ? [{input: request.input ?? ''}] : challenge.tests ?? [];
  const language = challenge.language;
  if (typeof code !== 'string' || code.length > 20000 || !code.trim()) return {passed: false, diagnostic: 'unsupportedCode'};
  try {
    if (language === 'python') {
      const python = await pythonLoader();
      let passedCount = 0;
      const outputs = [];
      for (const test of tests) {
        const lines = [];
        python.setStdout({batched: line => lines.push(line)});
        python.globals.set('codelearn_source', code);
        python.globals.set('codelearn_input', String(test.input ?? ''));
        await python.runPythonAsync(`import builtins\ncodelearn_inputs = iter(codelearn_input.split('\\n'))\ncodelearn_original_input = builtins.input\nbuiltins.input = lambda prompt='': next(codelearn_inputs, '')\ntry:\n    exec(compile(codelearn_source, '<lesson>', 'exec'), {'__name__': '__main__'})\nfinally:\n    builtins.input = codelearn_original_input`);
        const output = lines.join('\n');
        outputs.push(output);
        if (normalize(output) === normalize(test.expectedOutput)) passedCount++;
      }
      if (playground) return {passed: true, output: outputs.join('\n')};
      return {passed: tests.length > 0 && passedCount === tests.length, output: [...new Set(outputs)].join('\n'), passedCount, totalCount: tests.length, diagnostic: passedCount === tests.length ? '' : 'resultMismatch'};
    }
    if (['javascript', 'js', 'react', 'jsx'].includes(language)) {
      const reference = challenge.solution ?? '';
      if (/<[A-Za-z][^>]*>|useState|useEffect/.test(reference)) {
        const actualAst = Babel.transform(code, {presets: ['react'], comments: false, compact: true}).code;
        const referenceAst = Babel.transform(reference, {presets: ['react'], comments: false, compact: true}).code;
        const tokens = [...reference.matchAll(/\b(useState|useEffect|useReducer|useContext|useRef|useMemo|ErrorBoundary|UserProfile)\b/g)].map(match => match[0]);
        const markers = tests.every(test => !test.expectedOutput || code.includes(test.expectedOutput) || String(test.input ?? '').includes(test.expectedOutput));
        const passed = actualAst === referenceAst || markers && tokens.every(token => code.includes(token)) && actualAst.includes('React.createElement');
        return {passed, output: actualAst, passedCount: passed ? tests.length : 0, totalCount: tests.length, diagnostic: passed ? '' : 'resultMismatch'};
      }
      let passedCount = 0;
      const outputs = [];
      for (const test of tests) {
        const lines = [];
        const timers = new Set();
        const console = {log: (...args) => lines.push(args.map(formatValue).join(' ')), error: (...args) => lines.push(args.map(formatValue).join(' '))};
        const schedule = (callback, delay = 0, ...args) => {
          const timer = setTimeout(() => { timers.delete(timer); callback(...args); }, Math.min(Math.max(Number(delay) || 0, 0), 500));
          timers.add(timer);
          return timer;
        };
        const run = new Function('console', 'setTimeout', 'input', 'fetch', 'XMLHttpRequest', 'WebSocket', 'Worker', 'importScripts', `return (async () => {${code}\n})()`);
        await run(console, schedule, test.input ?? '', undefined, undefined, undefined, undefined, undefined);
        for (let tick = 0; tick < 30; tick++) {
          await new Promise(resolve => setTimeout(resolve, 20));
          if (!timers.size) break;
        }
        for (const timer of timers) clearTimeout(timer);
        const output = lines.join('\n');
        outputs.push(output);
        if (normalize(output) === normalize(test.expectedOutput)) passedCount++;
      }
      if (playground) return {passed: true, output: outputs.join('\n')};
      return {passed: tests.length > 0 && passedCount === tests.length, output: [...new Set(outputs)].join('\n'), passedCount, totalCount: tests.length, diagnostic: passedCount === tests.length ? '' : 'resultMismatch'};
    }
    return {passed: false, diagnostic: 'unsupportedCode'};
  } catch (error) { return {passed: false, diagnostic: String(error.message ?? error).slice(-3000), totalCount: tests.length}; }
}
export function normalize(value) { return String(value ?? '').replaceAll('\r\n', '\n').trimEnd(); }
