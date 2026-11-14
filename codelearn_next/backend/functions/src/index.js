import {readFileSync} from 'node:fs';
import {initializeApp} from 'firebase-admin/app';
import {getFirestore} from 'firebase-admin/firestore';
import {HttpsError, onCall} from 'firebase-functions/v2/https';
import {applyReward, validateOperation} from './policy.js';

const manifest = JSON.parse(readFileSync(new URL('../content/manifest.json', import.meta.url), 'utf8'));
const supportedTypes = new Set(['completion', 'daily', 'purchase', 'hint']);
initializeApp();
const database = getFirestore();

export const applyLearningOperation = onCall({maxInstances: 20}, async request => {
  if (!request.auth) throw new HttpsError('unauthenticated', 'Sign in first.');
  let operation;
  try { operation = validateOperation(request.data); }
  catch { throw new HttpsError('invalid-argument', 'Invalid learning operation.'); }
  const {id, type, payload} = operation;
  const learner = database.collection('learners').doc(request.auth.uid);
  const receipt = learner.collection('operations').doc(id);
  try {
    return await database.runTransaction(async transaction => {
      const receiptRow = await transaction.get(receipt);
      if (receiptRow.exists) return {applied: false};
      const profileRow = await transaction.get(learner);
      const profile = profileRow.data() ?? {};
      const date = new Date();
      const at = date.toISOString();
      const day = at.slice(0, 10);
      if (supportedTypes.has(type)) {
        const lesson = manifest[payload.lessonId];
        let courseCount = 0;
        let completion;
        let course;
        if (type === 'completion') {
          if (!lesson || lesson.courseId !== payload.courseId || lesson.version !== payload.version) throw new Error('invalidLesson');
          completion = learner.collection('completions').doc(lesson.id);
          const existing = await transaction.get(completion);
          if (existing.exists) { transaction.set(receipt, {type, at}); return {applied: false}; }
          course = learner.collection('courseProgress').doc(lesson.courseId);
          const courseRow = await transaction.get(course);
          courseCount = Number(courseRow.data()?.count ?? 0) + 1;
        }
        if (type === 'hint' && !lesson) throw new Error('invalidLesson');
        const result = applyReward(profile, type, payload, {day, lesson, courseCompleted: lesson && courseCount === lesson.courseSize});
        transaction.set(learner, result.profile);
        if (completion) transaction.set(completion, {lessonId: lesson.id, courseId: lesson.courseId, xp: lesson.xp, version: lesson.version, at});
        if (course) transaction.set(course, {count: courseCount});
        transaction.set(learner.collection('ledger').doc(id), {type, xp: result.xp, credits: result.credits, at});
      } else if (type === 'profile') {
        const allowed = {};
        if (typeof payload.name === 'string') allowed.name = payload.name.slice(0, 60);
        if (typeof payload.bio === 'string') allowed.bio = payload.bio.slice(0, 250);
        if (Number.isInteger(payload.avatar) && payload.avatar >= 1 && payload.avatar <= 10) allowed.avatar = payload.avatar;
        if (typeof payload.focus === 'string' && /^[a-z-]+$/.test(payload.focus)) allowed.focus = payload.focus;
        if (Number.isInteger(payload.dailyMinutes) && payload.dailyMinutes >= 5 && payload.dailyMinutes <= 60) allowed.dailyMinutes = payload.dailyMinutes;
        transaction.set(learner, allowed, {merge: true});
      } else if (type === 'portfolio') {
        if (!/^[a-zA-Z0-9:_-]{1,180}$/.test(payload.id ?? '') || typeof payload.code !== 'string' || !payload.code.trim() || typeof payload.title !== 'string' || !payload.title.trim()) throw new Error('invalidPortfolio');
        transaction.set(learner.collection('portfolio').doc(payload.id), {id: payload.id, title: payload.title.slice(0, 200), code: payload.code.slice(0, 50000), notes: String(payload.notes ?? '').slice(0, 5000), language: String(payload.language ?? '').slice(0, 40), errorTags: Array.isArray(payload.errorTags) ? payload.errorTags.filter(tag => typeof tag === 'string').slice(0, 20) : [], at});
      } else if (type === 'portfolioDelete') {
        if (!/^[a-zA-Z0-9:_-]{1,180}$/.test(payload.id ?? '')) throw new Error('invalidPortfolio');
        transaction.delete(learner.collection('portfolio').doc(payload.id));
      } else if (type === 'support') {
        if (typeof payload.message !== 'string' || payload.message.trim().length < 5 || payload.message.length > 4000) throw new Error('invalidMessage');
        transaction.set(learner.collection('support').doc(id), {message: payload.message, at, status: 'open'});
      }
      transaction.set(receipt, {type, at});
      return {applied: true};
    });
  } catch (error) { throw new HttpsError('failed-precondition', error.message); }
});

export const getLearningSnapshot = onCall({maxInstances: 20}, async request => {
  if (!request.auth) throw new HttpsError('unauthenticated', 'Sign in first.');
  const learner = database.collection('learners').doc(request.auth.uid);
  const [profile, completions, portfolio] = await Promise.all([learner.get(), learner.collection('completions').get(), learner.collection('portfolio').orderBy('at', 'desc').limit(100).get()]);
  return {profile: profile.data() ?? {}, completions: completions.docs.map(row => row.data()), portfolio: portfolio.docs.map(row => row.data())};
});
