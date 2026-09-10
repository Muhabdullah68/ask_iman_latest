'use strict';

// Pure, dependency-free text matching helpers for the ASK Iman AI corpus search.
// Kept free of firebase imports so it can be unit-tested with `node validate_ai.js`.

const DIACRITICS = /[\u064B-\u065F\u0610-\u061A\u06D6-\u06DC\u06DF-\u06E8\u06EA-\u06ED\u0640\u0670\u0653-\u0655\u06E0\u06E1\u06E2\u06E3\u06E4\u06E5\u06E6\u06E7\u06E8\u06EC\u06ED]/g;
const ALEF_VARIANTS = /[\u0622\u0623\u0625\u0671]/g;
const ALEF_MAP = { '\u0622': '\u0627', '\u0623': '\u0627', '\u0625': '\u0627', '\u0671': '\u0627' };
const NPROP = /[^\p{L}\p{N}\s]/gu;

/**
 * Normalize Arabic/natural text for robust matching:
 * strips diacritics & quranic signs, unifies alef/hamza variants, ya, taa marbuta,
 * collapses punctuation and whitespace, lowercases.
 */
function normalizeForMatch(text) {
  return String(text || '')
    .normalize('NFKC')
    .replace(DIACRITICS, '')
    .replace(ALEF_VARIANTS, (ch) => ALEF_MAP[ch])
    .replace(/\u0649/g, '\u064A') // alef maqsura -> ya
    .replace(/\u0629/g, '\u0647') // taa marbuta -> ha
    .replace(NPROP, ' ')
    .replace(/\s+/g, ' ')
    .trim()
    .toLowerCase();
}

function tokens(text) {
  return normalizeForMatch(text).split(' ').filter(Boolean);
}

/** Fraction of needle tokens present in hay tokens (good for partial quotes). */
function containmentScore(hayText, needleText) {
  const th = tokens(hayText);
  const tn = tokens(needleText);
  if (!th.length || !tn.length) return 0;
  const sh = new Set(th);
  let hit = 0;
  for (const t of tn) if (sh.has(t)) hit++;
  return hit / tn.length;
}

/** Jaccard-ish overlap over smaller token set (good for fuzzy/paraphrased). */
function overlapScore(aText, bText) {
  const ta = tokens(aText);
  const tb = tokens(bText);
  if (!ta.length || !tb.length) return 0;
  const sa = new Set(ta);
  const sb = new Set(tb);
  let inter = 0;
  for (const t of sa) if (sb.has(t)) inter++;
  return inter / Math.min(sa.size, sb.size);
}

/**
 * Combined ranking score for hayText (canonical corpus text) vs needleText (user
 * claim). Penalizes needles much longer than the corpus line (i.e. a fabricated
 * "verse" that goes on well past the real one).
 */
function rankMatch({ hayText, needleText }) {
  const c = containmentScore(hayText, needleText);
  const o = overlapScore(hayText, needleText);
  const n = normalizeForMatch(needleText);
  const h = normalizeForMatch(hayText);
  const lenFactor = n.length <= h.length ? 1 : Math.max(0, 1 - (n.length - h.length) / n.length);
  const score = Math.max(c, o) * lenFactor;
  return { score, containment: c, overlap: o, lenFactor };
}

/**
 * Scan a corpus (items of {text, meta}) for best matches to needleText.
 * minScore tuned per-script by caller.
 */
function findMatches(corpusItems, needleText, { minScore = 0.62, limit = 5 }) {
  const out = [];
  for (const item of corpusItems) {
    const r = rankMatch({ hayText: item.text, needleText });
    if (r.score >= minScore) out.push({ item, ...r });
  }
  out.sort((a, b) => b.score - a.score);
  return out.slice(0, limit);
}

function isArabicScript(text) {
  return /[\u0600-\u06FF]/.test(String(text || ''));
}

module.exports = {
  normalizeForMatch,
  tokens,
  containmentScore,
  overlapScore,
  rankMatch,
  findMatches,
  isArabicScript,
};