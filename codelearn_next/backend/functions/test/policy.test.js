import {test} from 'node:test';
import assert from 'node:assert/strict';
import {applyReward, validateOperation} from '../src/policy.js';

const lesson = {xp: 20, version: 1};
test('server determines XP from catalog rather than user payload', () => {
  const result = applyReward({}, 'completion', {version: 1, xp: 999999}, {day: '2026-11-14', lesson, courseCompleted: false});
  assert.equal(result.xp, 40);
  assert.equal(result.profile.streak, 1);
});
test('daily check-in never changes learning streak', () => {
  const result = applyReward({streak: 3}, 'daily', {day: '2026-11-14'}, {day: '2026-11-14'});
  assert.equal(result.profile.streak, 3);
  assert.equal(result.profile.wallet.credits, 20);
});
test('daily claim cannot be replayed', () => {
  const first = applyReward({}, 'daily', {day: '2026-11-14'}, {day: '2026-11-14'});
  const replay = applyReward(first.profile, 'daily', {day: '2026-11-14'}, {day: '2026-11-14'});
  assert.equal(replay.xp, 0);
  assert.equal(replay.profile.wallet.credits, 20);
});
test('purchases reject insufficient credits and duplicate cosmetics', () => {
  assert.throws(() => applyReward({}, 'purchase', {itemId: 'frame'}, {}), /insufficientCredits/);
  assert.throws(() => applyReward({wallet: {credits: 200, hasFrame: true}}, 'purchase', {itemId: 'frame'}, {}), /owned/);
});
test('shields protect exactly one missed calendar day', () => {
  const result = applyReward({streak: 5, lastLearningDay: '2026-11-12', wallet: {shields: 1}}, 'completion', {version: 1}, {day: '2026-11-14', lesson});
  assert.equal(result.profile.streak, 6);
  assert.equal(result.profile.wallet.shields, 0);
});
test('operation validation rejects traversal and oversized payloads', () => {
  assert.throws(() => validateOperation({id: '../bad', type: 'daily', payload: {}}));
  assert.throws(() => validateOperation({id: 'ok', type: 'profile', payload: {bio: 'x'.repeat(90000)}}));
});
