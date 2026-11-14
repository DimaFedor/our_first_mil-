import {readFile, readdir, writeFile} from 'node:fs/promises';
import {loadPyodide} from 'pyodide';
import {evaluateLanguage} from './evaluate.mjs';

let python;
const loadPython = async () => python ??= await loadPyodide();
const failures = [];
let total = 0;
for (const file of (await readdir('../../assets/content')).filter(name => name.startsWith('en__'))) {
  const content = JSON.parse(await readFile(`../../assets/content/${file}`, 'utf8'));
  for (const lesson of content.lessons) {
    const challenge = lesson.codingChallenge;
    if (!challenge || !['python', 'javascript'].includes(challenge.language)) continue;
    total++;
    const result = await evaluateLanguage({code: challenge.solution, challenge: {...challenge, tests: challenge.testCases}}, loadPython);
    if (!result.passed) { failures.push({lessonId: lesson.id, ...result, expected: challenge.testCases}); process.stdout.write(`FAILED ${lesson.id}\n`); }
  }
}
await writeFile('../../docs/language-runtime-validation.json', JSON.stringify({total, passed: total - failures.length, failures}, null, 2));
process.stdout.write(`${total - failures.length}/${total} real-language reference solutions passed\n`);
process.exitCode = failures.length ? 1 : 0;
