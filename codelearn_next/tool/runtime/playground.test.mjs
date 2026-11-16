import assert from 'node:assert/strict';
import {test} from 'node:test';
import {loadPyodide} from 'pyodide';
import {evaluateLanguage} from './evaluate.mjs';

let python;
const loader = async () => python ??= await loadPyodide();
for (const language of ['python', 'javascript']) {
  const run = (code, input = '') => evaluateLanguage({mode: 'playground', code, input, challenge: {language}}, loader);
  test(`${language}: arbitrary output needs no expected answer`, async () => {
    const result = await run(language === 'python' ? 'print(6 * 7)' : 'console.log(6 * 7)');
    assert.equal(result.passed, true);
    assert.equal(result.output, '42');
    assert.equal(result.diagnostic, undefined);
  });
  test(`${language}: supplied input and no output`, async () => {
    const result = await run(language === 'python' ? 'print(input())' : 'console.log(input)', 'hello');
    assert.equal(result.output, 'hello');
    const empty = await run(language === 'python' ? 'x = 1' : 'const x = 1;');
    assert.equal(empty.passed, true);
    assert.equal(empty.output, '');
  });
  test(`${language}: execution errors are visible`, async () => {
    const result = await run(language === 'python' ? 'raise ValueError("broken")' : 'throw new Error("broken")');
    assert.equal(result.passed, false);
    assert.match(result.diagnostic, /broken/);
  });
}
test('lesson checking still rejects incorrect output', async () => {
  const result = await evaluateLanguage({code: 'console.log("wrong")', challenge: {language: 'javascript', tests: [{expectedOutput: 'right'}]}}, loader);
  assert.equal(result.passed, false);
  assert.equal(result.diagnostic, 'resultMismatch');
});
