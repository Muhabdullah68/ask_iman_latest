// lib/web/pages/quran/juz_data.dart
// ─────────────────────────────────────────────────────────────────────────────
// ASK IMAN WEBSITE — JUZ (SUPARA) REFERENCE DATA
//
// Single source of truth for the 30 juz of the Qur'an on the web. The start
// position of every juz is stored as an authoritative (surah, ayah) pair so
// the juz bookshelf, tafseer navigator and juz audio all agree on the same
// boundaries.
// ─────────────────────────────────────────────────────────────────────────────

/// Start (surah, ayah) of each of the 30 juz (1-indexed).
const List<(int, int)> juzStartAyat = [
  (1, 1),
  (2, 142),
  (2, 253),
  (3, 93),
  (4, 24),
  (4, 148),
  (5, 82),
  (6, 111),
  (7, 88),
  (8, 41),
  (9, 93),
  (11, 6),
  (12, 53),
  (15, 1),
  (17, 1),
  (18, 75),
  (21, 1),
  (23, 1),
  (25, 21),
  (27, 56),
  (29, 46),
  (33, 31),
  (36, 28),
  (39, 32),
  (41, 47),
  (46, 1),
  (51, 31),
  (58, 1),
  (67, 1),
  (78, 1),
];

/// The surah in which juz [n] begins (1 is the first juz).
int juzStartSurah(int n) => juzStartAyat[n - 1].$1;

/// The ayah at which juz [n] begins.
int juzStartAyah(int n) => juzStartAyat[n - 1].$2;

/// Surah numbers recited in juz [n] (from its start surah up to, but not
/// including, the start surah of the next juz — or 114 at the end).
List<int> surahsInJuz(int n) {
  final start = juzStartSurah(n);
  final end = n < juzStartAyat.length ? juzStartSurah(n + 1) - 1 : 114;
  return List.generate(end - start + 1, (i) => start + i);
}

const List<String> _arabicDigits = [
  '٠',
  '١',
  '٢',
  '٣',
  '٤',
  '٥',
  '٦',
  '٧',
  '٨',
  '٩',
];

/// Renders [n] with Arabic-Indic digits (e.g. 12 → "١٢").
String arabicNumeral(int n) {
  return n.toString().split('').map((d) => _arabicDigits[int.parse(d)]).join();
}
