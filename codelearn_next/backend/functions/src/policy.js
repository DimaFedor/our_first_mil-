export const shop = Object.freeze({
  booster: {cost: 80, field: 'boosts', quantity: 3},
  shield: {cost: 95, field: 'shields', quantity: 1},
  hints: {cost: 55, field: 'hints', quantity: 5},
  frame: {cost: 140, field: 'hasFrame', quantity: true},
});

export function applyReward(profile, type, payload, context) {
  const next = structuredClone(profile);
  const wallet = next.wallet ??= {};
  let xp = 0;
  let credits = 0;
  if (type === 'daily') {
    if (wallet.dailyClaim === context.day) return {profile, xp, credits};
    if (payload.day !== context.day) throw new Error('expiredDaily');
    wallet.dailyClaim = context.day;
    xp = 15;
    credits = 20;
  } else if (type === 'completion') {
    const lesson = context.lesson;
    if (!lesson || payload.version !== lesson.version) throw new Error('invalidLesson');
    const boosts = Number(wallet.boosts ?? 0);
    xp = lesson.xp + (boosts > 0 ? Math.round(lesson.xp * .25) : 0);
    if (boosts > 0) wallet.boosts = boosts - 1;
    credits = 8;
    const distance = next.lastLearningDay ? Math.round((Date.parse(context.day) - Date.parse(next.lastLearningDay)) / 86400000) : null;
    if (distance === null) next.streak = 1;
    else if (distance === 1) next.streak = Number(next.streak ?? 0) + 1;
    else if (distance === 2 && Number(wallet.shields ?? 0) > 0) { next.streak = Number(next.streak ?? 0) + 1; wallet.shields--; }
    else if (distance > 1) next.streak = 1;
    next.lastLearningDay = context.day;
    next.completionCount = Number(next.completionCount ?? 0) + 1;
    if (context.courseCompleted) { xp += 60; credits += 50; }
    const achievements = new Set(next.achievements ?? []);
    const rules = {firstLesson: next.completionCount >= 1, fiveLessons: next.completionCount >= 5, tenLessons: next.completionCount >= 10, firstCourse: context.courseCompleted, weekStreak: next.streak >= 7, xpMilestone: Number(next.xp ?? 0) + xp >= 1000};
    for (const [id, unlocked] of Object.entries(rules)) if (unlocked && !achievements.has(id)) { achievements.add(id); xp += 20; }
    next.achievements = [...achievements];
  } else if (type === 'purchase') {
    const item = shop[payload.itemId];
    if (!item) throw new Error('invalidItem');
    if (Number(wallet.credits ?? 0) < item.cost) throw new Error('insufficientCredits');
    if (payload.itemId === 'frame' && wallet.hasFrame) throw new Error('owned');
    credits = -item.cost;
    wallet[item.field] = item.quantity === true ? true : Number(wallet[item.field] ?? 0) + item.quantity;
  } else if (type === 'hint') {
    if (Number(wallet.hints ?? 0) < 1) throw new Error('hintEmpty');
    wallet.hints--;
  } else throw new Error('invalidOperation');
  next.xp = Number(next.xp ?? 0) + xp;
  wallet.credits = Number(wallet.credits ?? 0) + credits;
  return {profile: next, xp, credits};
}

export function validateOperation(value) {
  if (!value || typeof value !== 'object' || !/^[a-zA-Z0-9:_-]{1,180}$/.test(value.id ?? '') || !['completion', 'daily', 'purchase', 'hint', 'profile', 'portfolio', 'portfolioDelete', 'support'].includes(value.type) || !value.payload || typeof value.payload !== 'object' || Array.isArray(value.payload) || JSON.stringify(value.payload).length > 80000) throw new Error('invalidOperation');
  return {id: value.id, type: value.type, payload: value.payload};
}
