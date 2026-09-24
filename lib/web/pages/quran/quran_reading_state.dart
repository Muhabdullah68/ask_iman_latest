// lib/web/pages/quran/quran_reading_state.dart
// ─────────────────────────────────────────────────────────────────────────────
// ASK IMAN WEBSITE — SHARED QURAN READING STATE
//
// A process-wide singleton that records which surah / ayah the user is
// currently reading across the Quran tabs (Talawat, Tarjuma, Tafseer,
// Share). Because the site uses tab panes cached inside a single
// QuranPage AND deep-link routes that mount fresh pages, selection state
// must live above any single widget tree — hence the ChangeNotifier
// singleton. The Share tab listens to it so shared links always reflect
// the surah / ayah actually open.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/foundation.dart';

class QuranReadingState extends ChangeNotifier {
  QuranReadingState._();

  static final QuranReadingState instance = QuranReadingState._();

  int surahNum = 1;
  int? ayahNum;

  void setSurah(int surah) {
    surahNum = surah;
    ayahNum = null;
    notifyListeners();
  }

  void selectAyah(int surah, int ayah) {
    surahNum = surah;
    ayahNum = ayah;
    notifyListeners();
  }
}