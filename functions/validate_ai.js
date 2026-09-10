'use strict';

// Lightweight no-framework test for the corpus matching engine (ai_tools.js).
// Run with: node validate_ai.js  (or: npm test inside functions/)

const assert = require('assert');
const AI = require('./ai_tools');

let passed = 0;

function t(name, fn) {
  try {
    fn();
    passed++;
    console.log('  ok  ' + name);
  } catch (e) {
    console.error('FAIL  ' + name);
    console.error('      ' + (e && e.message));
    process.exitCode = 1;
  }
}

// ── Normalization ──────────────────────────────────────────────────────────
t('Arabic diacritics + hamza variants normalize', () => {
  assert.strictEqual(
    AI.normalizeForMatch('الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ'),
    AI.normalizeForMatch('الحمد لله رب العالمين'),
  );
});

t('alef variants unify', () => {
  assert.strictEqual(
    AI.normalizeForMatch('أوضح إيمان آية'),
    AI.normalizeForMatch('اوضح ايمان اية'),
  );
});

t('English punctuation/whitespace collapse', () => {
  assert.strictEqual(
    AI.normalizeForMatch('  "Allah!  There is NO god but Him,  the Ever-Living."'),
    AI.normalizeForMatch('allah there is no god but him the ever living'),
  );
});

// ── Template Quran corpus (Ayat al-Kursi 2:255-like) ───────────────────────
const KURSI_EN =
  'Allah - there is no deity except Him, the Ever-Living, the Self-Sustaining. ' +
  'Neither drowsiness overtakes Him nor sleep. To Him belongs whatever is in the heavens and whatever is on the earth. ' +
  'Who is it that can intercede with Him except by His permission?';
const KURSI_AR =
  'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ';

const corpusEn = [{ text: KURSI_EN, meta: { id: '2:255' } }];
const corpusAr = [{ text: KURSI_AR, meta: { id: '2:255' } }];

t('verified: partial quote of authentic ayah (English)', () => {
  const hits = AI.findMatches(corpusEn, 'there is no deity except Him, the Ever-Living, the Self-Sustaining', { minScore: AI.isArabicScript('') ? 0 : 0.62 });
  assert.ok(hits.length && hits[0].item.meta.id === '2:255', 'expected Ayat al-Kursi to match');
});

t('verified: Arabic partial quote normalizes (no tashkeel)', () => {
  const hits = AI.findMatches(corpusAr, 'لا إله إلا هو الحي القيوم', { minScore: 0.58 });
  assert.ok(hits.length && hits[0].item.meta.id === '2:255', 'Arabic quote must match');
});

t('verified: Arabic quote WITH tashkeel still matches', () => {
  const hits = AI.findMatches(corpusAr, 'لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ', { minScore: 0.58 });
  assert.ok(hits.length, 'tashkeel should be stripped before matching');
});

t('unverified: fabricated claim fails to match', () => {
  const hits = AI.findMatches(corpusEn, 'Allah says you must eat three apples before every sunrise', { minScore: 0.62 });
  assert.strictEqual(hits.length, 0, 'fabricated text must NOT match');
});

t('unverified: paraphrased/misattributed long text fails to match', () => {
  const hits = AI.findMatches(corpusEn, 'The moon is split in halves every single night as proof of Allah', { minScore: 0.62 });
  assert.strictEqual(hits.length, 0, 'unrelated text must NOT match');
});

// ── Hadith 1 (Bukhari: "Actions are by intentions") ─────────────────────────
const HADITH1 =
  "Narrated 'Umar bin Al-Khattab: I heard Allah's Messenger (PBUH) saying, \"The reward of deeds depends upon the intentions and every person will get the reward according to what he has intended.\"";

t('verified: famous hadith quote matches Bukhari 1', () => {
  const hits = AI.findMatches(
    [{ text: HADITH1, meta: { id: 'bukhari-1' } }],
    'Actions are by intentions, and every person will get what he intended',
    { minScore: 0.55 },
  );
  assert.ok(hits.length && hits[0].item.meta.id === 'bukhari-1', 'Bukhari 1 must match');
});

t('unverified: fake hadith attribution does not match', () => {
  const hits = AI.findMatches(
    [{ text: HADITH1, meta: { id: 'bukhari-1' } }],
    'The Prophet (PBUH) said: whoever drinks wine made from dates in the morning will get 1000 rewards',
    { minScore: 0.55 },
  );
  assert.strictEqual(hits.length, 0, 'fake hadith must NOT match');
});

t('overlap sanity', () => {
  assert.ok(AI.overlapScore('the quick brown fox', 'the quick brown fox') === 1);
  assert.ok(AI.overlapScore('the quick brown fox', 'the lazy dog') < 0.5);
});

t('isArabicScript detection', () => {
  assert.ok(AI.isArabicScript('بسم الله الرحمن الرحيم'));
  assert.ok(!AI.isArabicScript('In the name of Allah'));
});

console.log(`\n${process.exitCode === 1 ? 'FAILED' : 'PASSED'} — ${passed} tests`);