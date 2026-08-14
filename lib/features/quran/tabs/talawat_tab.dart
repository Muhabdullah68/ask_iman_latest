// lib/features/quran/tabs/talawat_tab.dart
// ─────────────────────────────────────────────────────────────────────────────
// TALAWAT TAB — Pure Arabic recitation
//
// FIXES & IMPROVEMENTS:
//   1. Bismillah duplication bug FIXED:
//      • API returns Bismillah as ayah 1 for most surahs → we strip it and
//        render it once in the dedicated Bismillah banner.
//      • Surah 1 (Al-Fatihah): ayah 1 IS the Bismillah (it is part of Fatihah),
//        so we show the Bismillah banner AND remove ayah 1 from the flowing block.
//      • Surah 9 (At-Tawbah): no Bismillah shown at all (per Ijma).
//
//   2. Mushaf / Hamariweb-style flowing Quran text:
//      • All ayahs rendered as a single flowing RichText paragraph (Mushaf layout)
//        inside one bordered card — exactly matching the reference screenshot.
//      • Ayah numbers shown as gold ❮n❯ Unicode markers inline.
//      • Bismillah shown in its own separate centred box above the block.
//
//   3. Font: 'Scheherazade New' (Naskh Quranic calligraphy — closest free font
//      to the hamariweb/Mushaf style). Fallback: 'Amiri'.
//      Add to pubspec.yaml:
//        fonts:
//          - family: ScheherazadeNew
//            fonts:
//              - asset: assets/fonts/ScheherazadeNew-Regular.ttf
//      OR use google_fonts: ^6.x and call GoogleFonts.scheherazadeNew(...)
//
//   4. Font size −/+ buttons retained.
//   5. Translation mode: individual ayah cards retained (unchanged UX).
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../core/services/quran_download_service.dart';
import '../../../core/services/quran_audio_service.dart';
import '../widgets/download_dialog.dart';
import '../widgets/pdf_viewer_screen.dart';
import '../data/surahs_data.dart';
import '../data/quran_api_service.dart';
import 'tafseer_tab.dart';

// ── Shared Juz metadata ───────────────────────────────────────────────────────
class JuzMeta {
  final int num;
  final String ar;
  final String name;
  final String start;
  final String end;
  const JuzMeta(this.num, this.ar, this.name, this.start, this.end);
}

const kJuzList = [
  JuzMeta(1, 'آلم', 'Alif Lam Meem', '1:1', '2:141'),
  JuzMeta(2, 'سَيَقُولُ', 'Sayaqool', '2:142', '2:252'),
  JuzMeta(3, 'تِلْكَ ٱلرُّسُلُ', 'Tilkal Rusulu', '2:253', '3:92'),
  JuzMeta(4, 'لَنْ تَنَالُوا', 'Lan tanaloo', '3:93', '4:23'),
  JuzMeta(5, 'وَٱلْمُحْصَنَاتُ', 'Wal Mohsanatu', '4:24', '4:147'),
  JuzMeta(6, 'لَا يُحِبُّ', 'La Yuhibbullah', '4:148', '5:81'),
  JuzMeta(7, 'وَإِذَا سَمِعُوا', 'Wa Iza Samiu', '5:82', '6:110'),
  JuzMeta(8, 'وَلَوْ أَنَّنَا', 'Wa Lau Annana', '6:111', '7:87'),
  JuzMeta(9, 'قَالَ ٱلْمَلَأُ', 'Qalal Malao', '7:88', '8:40'),
  JuzMeta(10, 'وَٱعْلَمُوا', "Wa A'lamu", '8:41', '9:92'),
  JuzMeta(11, 'يَعْتَذِرُونَ', 'Yatazeroon', '9:93', '11:5'),
  JuzMeta(12, 'وَمَا مِنْ دَآبَّة', 'Wa Ma Min Dabbatin', '11:6', '12:52'),
  JuzMeta(13, 'وَمَا أُبَرِّئُ', 'Wa Ma Ubrioo', '12:53', '14:52'),
  JuzMeta(14, 'رُبَمَا', 'Rubama', '15:1', '16:128'),
  JuzMeta(15, 'سُبْحَانَ ٱلَّذِى', 'Subhanalladhi', '17:1', '18:74'),
  JuzMeta(16, 'قَالَ أَلَمْ', 'Qala Alam', '18:75', '20:135'),
  JuzMeta(17, 'ٱقْتَرَبَ', 'Iqtaraba', '21:1', '22:78'),
  JuzMeta(18, 'قَدْ أَفْلَحَ', 'Qadd Aflaha', '23:1', '25:20'),
  JuzMeta(19, 'وَقَالَ ٱلَّذِينَ', 'Wa Qala lladhina', '25:21', '27:55'),
  JuzMeta(20, 'أَمَّنْ خَلَقَ', "A'man Khalaqa", '27:56', '29:45'),
  JuzMeta(21, 'أُتْلُ', 'Utlu Ma Oohiya', '29:46', '33:30'),
  JuzMeta(22, 'وَمَن يَقْنُتْ', 'Wa Man Yaqnut', '33:31', '36:27'),
  JuzMeta(23, 'وَمَآ لِي', 'Wa Mali', '36:28', '39:31'),
  JuzMeta(24, 'فَمَنْ أَظْلَمُ', 'Faman Azlamu', '39:32', '41:46'),
  JuzMeta(25, 'إِلَيْهِ يُرَدُّ', 'Ilayhi Yuruddu', '41:47', '45:37'),
  JuzMeta(26, 'حٰمٓ', 'Ha Meem', '46:1', '51:30'),
  JuzMeta(27, 'قَالَ فَمَا خَطْبُكُم', 'Qala Fama Khatbukum', '51:31', '57:29'),
  JuzMeta(28, 'قَدْ سَمِعَ', 'Qadd Sami Allah', '58:1', '66:12'),
  JuzMeta(29, 'تَبَارَكَ ٱلَّذِى', 'Tabaraka lladhi', '67:1', '77:50'),
  JuzMeta(30, 'عَمَّ', 'Amma', '78:1', '114:6'),
];

// ── Arabic font helper ────────────────────────────────────────────────────────
// Uses ScheherazadeNew if available in assets, else falls back to Amiri.
// To enable ScheherazadeNew: add font asset in pubspec.yaml (see header).
const _kQuranicFont = 'AlMushaf'; // Default Quranic font (Al Mushaf)

// ── Bismillah text (Uthmani script) ──────────────────────────────────────────
const _kBismillah = 'بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ';

// ── Determines whether a given ayah text IS the Bismillah ────────────────────
// The API returns Bismillah as ayah 1 for most surahs (stripped of tashkeel
// variation). We compare normalised.
bool _isBismillahText(String text) {
  // Normalise: remove tatweel, strip diacritics range (including Uthmani specific), collapse spaces, and normalise Alefs
  String norm(String s) => s
      .replaceAll(RegExp(r'[ٱأإآ]'), 'ا') // Normalise Alef variants
      .replaceAll('\u0640', '') // tatweel
      .replaceAll(
        RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]'),
        '',
      ) // tashkeel + Uthmani markers
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  const bCore = 'بسم الله الرحمن الرحيم';
  final nText = norm(text);
  final nCore = norm(bCore);
  return nText.startsWith(nCore) || nText.contains(nCore);
}

// ══════════════════════════════════════════════════════════════════════════════
// TALAWAT TAB
// ══════════════════════════════════════════════════════════════════════════════
class TalawatTab extends StatefulWidget {
  final String searchQuery;
  final bool useUrduFont;
  final String? arabicFont;
  const TalawatTab({
    super.key,
    this.searchQuery = '',
    this.useUrduFont = false,
    this.arabicFont,
  });
  @override
  State<TalawatTab> createState() => _TalawatTabState();
}

class _TalawatTabState extends State<TalawatTab>
    with SingleTickerProviderStateMixin {
  late TabController _sub;

  @override
  void initState() {
    super.initState();
    _sub = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _sub.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          SharedSubTabBar(controller: _sub),
          Expanded(
            child: TabBarView(
              controller: _sub,
              children: [
                _SurahListView(
                  mode: ReadMode.talawat,
                  searchQuery: widget.searchQuery,
                  useUrduFont: widget.useUrduFont,
                  arabicFont: widget.arabicFont,
                ),
                _JuzListView(
                  mode: ReadMode.talawat,
                  searchQuery: widget.searchQuery,
                  useUrduFont: widget.useUrduFont,
                  arabicFont: widget.arabicFont,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Shared sub-tab bar (Surah / Juzz)
// ══════════════════════════════════════════════════════════════════════════════
class SharedSubTabBar extends StatelessWidget {
  final TabController controller;
  const SharedSubTabBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: TabBar(
        controller: controller,
        indicator: BoxDecoration(
          color: AppColors.primaryDark,
          borderRadius: BorderRadius.circular(24),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        tabs: const [
          Tab(text: 'Surah'),
          Tab(text: 'Juzz'),
        ],
        labelStyle: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textGrey,
        dividerColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Reading mode
// ══════════════════════════════════════════════════════════════════════════════
enum ReadMode { talawat, tarjuma, tafseer }

class TalawatSubListView extends StatelessWidget {
  final ReadMode mode;
  final String searchQuery;
  final bool useUrduFont;
  final String? arabicFont;
  final bool isJuz;
  final void Function(Map<String, dynamic>)? onSurahTap;

  const TalawatSubListView({
    super.key,
    required this.mode,
    this.searchQuery = '',
    this.useUrduFont = false,
    this.arabicFont,
    required this.isJuz,
    this.onSurahTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isJuz) {
      return _JuzListView(
        mode: mode,
        searchQuery: searchQuery,
        useUrduFont: useUrduFont,
        arabicFont: arabicFont,
      );
    } else {
      return _SurahListView(
        mode: mode,
        searchQuery: searchQuery,
        useUrduFont: useUrduFont,
        arabicFont: arabicFont,
        onTap: onSurahTap,
      );
    }
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Surah list
// ══════════════════════════════════════════════════════════════════════════════
class _SurahListView extends StatefulWidget {
  final ReadMode mode;
  final String searchQuery;
  final bool useUrduFont;
  final String? arabicFont;
  final void Function(Map<String, dynamic>)? onTap;
  const _SurahListView({
    required this.mode,
    this.searchQuery = '',
    this.useUrduFont = false,
    this.arabicFont,
    this.onTap,
  });

  @override
  State<_SurahListView> createState() => _SurahListViewState();
}

class _SurahListViewState extends State<_SurahListView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List<Map<String, dynamic>> get _filtered {
    if (widget.searchQuery.isEmpty) return SurahsData.surahs;
    final q = widget.searchQuery.toLowerCase();
    return SurahsData.surahs
        .where(
          (s) =>
              (s['name'] as String).toLowerCase().contains(q) ||
              '${s['num']}'.contains(q) ||
              (s['arabic'] as String).contains(q) ||
              (s['meaning'] as String).toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final list = _filtered;
    if (list.isEmpty) return _EmptySearchState(query: widget.searchQuery);

    Widget tile(int i) {
      final s = list[i];
      return SharedSurahCard(
        surah: s,
        useUrduFont: widget.useUrduFont,
        arabicFont: widget.arabicFont,
        onTap: () {
          if (widget.onTap != null) {
            widget.onTap!(s);
          } else if (widget.mode == ReadMode.tafseer) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TafseerReaderScreen(
                  surah: s,
                  book: const {
                    'name': 'Ibn Kathir',
                    'arabic': 'تفسير ابن كثير',
                  },
                  isUrdu: widget.useUrduFont,
                  arabicFont: widget.arabicFont,
                ),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ArabicReadScreen(
                  surah: s,
                  showTranslation: widget.mode == ReadMode.tarjuma,
                  useUrduFont: widget.useUrduFont,
                  arabicFont: widget.arabicFont,
                ),
              ),
            );
          }
        },
      );
    }

    final isWide = context.isTablet || context.isDesktop;
    return isWide
        ? GridView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 8,
              mainAxisExtent: 80,
            ),
            itemCount: list.length,
            itemBuilder: (_, i) => tile(i),
          )
        : ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: list.length,
            itemBuilder: (_, i) => tile(i),
          );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Juz list
// ══════════════════════════════════════════════════════════════════════════════
class _JuzListView extends StatefulWidget {
  final ReadMode mode;
  final String searchQuery;
  final bool useUrduFont;
  final String? arabicFont;
  const _JuzListView({
    required this.mode,
    this.searchQuery = '',
    this.useUrduFont = false,
    this.arabicFont,
  });

  @override
  State<_JuzListView> createState() => _JuzListViewState();
}

class _JuzListViewState extends State<_JuzListView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List<JuzMeta> get _filtered {
    if (widget.searchQuery.isEmpty) return kJuzList;
    final q = widget.searchQuery.toLowerCase();
    return kJuzList
        .where(
          (j) =>
              j.name.toLowerCase().contains(q) ||
              j.ar.contains(q) ||
              '${j.num}'.contains(q) ||
              'juz ${j.num}'.contains(q) ||
              'para ${j.num}'.contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final list = _filtered;
    if (list.isEmpty) return _EmptySearchState(query: widget.searchQuery);

    Widget tile(int i) => SharedJuzCard(
          meta: list[i],
          useUrduFont: widget.useUrduFont,
          arabicFont: widget.arabicFont,
          onTap: () {
            if (widget.mode == ReadMode.tafseer) {
              // Juz tafseer logic can be added here if needed
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ArabicReadScreen.juz(
                    meta: list[i],
                    showTranslation: widget.mode == ReadMode.tarjuma,
                    useUrduFont: widget.useUrduFont,
                    arabicFont: widget.arabicFont,
                  ),
                ),
              );
            }
          },
        );

    final isWide = context.isTablet || context.isDesktop;
    return isWide
        ? GridView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 8,
              mainAxisExtent: 80,
            ),
            itemCount: list.length,
            itemBuilder: (_, i) => tile(i),
          )
        : ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: list.length,
            itemBuilder: (_, i) => tile(i),
          );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Empty search state
// ══════════════════════════════════════════════════════════════════════════════
class _EmptySearchState extends StatelessWidget {
  final String query;
  const _EmptySearchState({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off,
            size: 56,
            color: AppColors.textLightGrey,
          ),
          const SizedBox(height: 12),
          Text(
            'No results for "$query"',
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textGrey,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try a different Surah name or number',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              color: AppColors.textLightGrey,
            ),
          ),
        ],
      ),
    );
  }
}

// Helper function to get surah PDF asset path
String getSurahPdfAssetPath(Map<String, dynamic> surah) {
  final slug = surah['pdfSlug'] as String;
  return 'assets/pdf/surah_pdfs/_islam_pdfsurat_Arabic_Surah-$slug-in-Arabic.pdf';
}

// ══════════════════════════════════════════════════════════════════════════════
// SHARED SURAH CARD
// ══════════════════════════════════════════════════════════════════════════════
class SharedSurahCard extends StatelessWidget {
  final Map<String, dynamic> surah;
  final VoidCallback onTap;
  final bool useUrduFont;
  final String? arabicFont;
  const SharedSurahCard({
    super.key,
    required this.surah,
    required this.onTap,
    this.useUrduFont = false,
    this.arabicFont,
  });

  @override
  Widget build(BuildContext context) {
    final isMakki = surah['type'] == 'MAKKI';
    // Use valid fonts only
    final validFonts = [
      'AlMushaf',
      'AlMajeed',
      'AlQalam',
      'PDMS_Saleem',
      'KfgqpcHafs',
    ];
    final actualArabicFont =
        (arabicFont != null && validFonts.contains(arabicFont))
        ? arabicFont!
        : _kQuranicFont;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 6),
        decoration: BoxDecoration(
          color: AppColors.bgWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.gold.withValues(alpha: 0.35),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withValues(alpha: 0.07),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Golden number badge
              Container(
                width: 44,
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                child: Center(
                  child: Text(
                    '${surah['num']}',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDarkest,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        surah['name'] as String,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isMakki
                                  ? AppColors.gold.withValues(alpha: 0.18)
                                  : AppColors.primaryLight.withValues(
                                      alpha: 0.15,
                                    ),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: isMakki
                                    ? AppColors.gold.withValues(alpha: 0.4)
                                    : AppColors.primaryLight.withValues(
                                        alpha: 0.3,
                                      ),
                              ),
                            ),
                            child: Text(
                              surah['type'] as String,
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: isMakki
                                    ? AppColors.goldDark
                                    : AppColors.primaryLight,
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '• ${surah['ayahs']} Ayahs',
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 11,
                              color: AppColors.textGrey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListenableBuilder(
                      listenable: QuranAudioService(),
                      builder: (context, _) {
                        final audio = QuranAudioService();
                        final isPlaying =
                            audio.isPlaying &&
                            audio.currentId == 'surah_${surah['num']}';
                        return IconButton(
                          icon: Icon(
                            isPlaying
                                ? Icons.pause_circle_filled_rounded
                                : Icons.play_circle_filled_rounded,
                            color: AppColors.primaryDark,
                            size: 26,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            if (isPlaying) {
                              audio.togglePause();
                            } else {
                              audio.playSurah(surah['num'], surah['name']);
                            }
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 6),
                    ListenableBuilder(
                      listenable: QuranDownloadService(),
                      builder: (context, _) {
                        final service = QuranDownloadService();
                        final id = 'surah_${surah['num']}';

                        // Build audio status widget
                        Widget buildAudioStatus() {
                          final audioDownloaded = service.isDownloaded(
                            id,
                            DownloadType.audio,
                          );
                          final audioProgress = service.getProgress(
                            id,
                            DownloadType.audio,
                          );

                          if (audioProgress?.isDownloading == true) {
                            return SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                value: audioProgress!.progress,
                                color: AppColors.gold,
                                strokeWidth: 2,
                              ),
                            );
                          } else if (audioProgress?.error != null) {
                            return const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 16,
                            );
                          } else if (audioDownloaded) {
                            return const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 16,
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        }

                        // Build PDF status widget
                        Widget buildPdfStatus() {
                          final pdfAssetPath = getSurahPdfAssetPath(surah);
                          final pdfDownloaded = service.isDownloaded(
                            id,
                            DownloadType.pdf,
                          );
                          final pdfProgress = service.getProgress(
                            id,
                            DownloadType.pdf,
                          );

                          if (pdfProgress?.isDownloading == true) {
                            return SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                value: pdfProgress!.progress,
                                color: AppColors.gold,
                                strokeWidth: 2,
                              ),
                            );
                          } else if (pdfProgress?.error != null) {
                            return const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 16,
                            );
                          } else {
                            // Check if PDF is available before showing button
                            if (!SurahsData.isPdfAvailable(surah)) {
                              return const Icon(
                                Icons.picture_as_pdf_rounded,
                                color: AppColors.textGrey,
                                size: 18,
                              );
                            }

                            return InkWell(
                              onTap: () async {
                                if (pdfDownloaded) {
                                  final path = await service.getFilePath(
                                    id,
                                    DownloadType.pdf,
                                  );
                                  if (context.mounted) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => PdfViewerScreen(
                                          title: surah['name'],
                                          localPath: path,
                                        ),
                                      ),
                                    );
                                  }
                                } else {
                                  if (context.mounted) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => PdfViewerScreen(
                                          title: surah['name'],
                                          assetPath: pdfAssetPath,
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                              child: const Icon(
                                Icons.picture_as_pdf_rounded,
                                color: AppColors.goldDark,
                                size: 18,
                              ),
                            );
                          }
                        }

                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.music_note,
                                  size: 12,
                                  color: AppColors.textGrey,
                                ),
                                const SizedBox(height: 1),
                                buildAudioStatus(),
                              ],
                            ),
                            const SizedBox(width: 10),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.picture_as_pdf,
                                  size: 12,
                                  color: AppColors.textGrey,
                                ),
                                const SizedBox(height: 1),
                                buildPdfStatus(),
                              ],
                            ),
                            const SizedBox(width: 6),
                            IconButton(
                              icon: const Icon(
                                Icons.download_for_offline_rounded,
                                color: AppColors.textGrey,
                              ),
                              iconSize: 22,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  backgroundColor: Colors.transparent,
                                  builder: (_) => DownloadDialog(
                                    id: id,
                                    title: surah['name'],
                                    audioUrl:
                                        'https://server7.mp3quran.net/basit/${'${surah['num']}'.padLeft(3, '0')}.mp3',
                                    pdfAssetPath: getSurahPdfAssetPath(surah),
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      surah['arabic'] as String,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontFamily: actualArabicFont,
                        fontSize: useUrduFont ? 15 : 18,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      (surah['meaning'] as String).split(' ').take(2).join(' '),
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 8,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SHARED JUZ CARD
// ══════════════════════════════════════════════════════════════════════════════
class SharedJuzCard extends StatelessWidget {
  final JuzMeta meta;
  final VoidCallback onTap;
  final bool useUrduFont;
  final String? arabicFont;
  const SharedJuzCard({
    super.key,
    required this.meta,
    required this.onTap,
    this.useUrduFont = false,
    this.arabicFont,
  });

  @override
  Widget build(BuildContext context) {
    // Use valid fonts only
    final validFonts = [
      'AlMushaf',
      'AlMajeed',
      'AlQalam',
      'PDMS_Saleem',
      'KfgqpcHafs',
    ];
    final actualArabicFont =
        (arabicFont != null && validFonts.contains(arabicFont))
        ? arabicFont!
        : _kQuranicFont;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 6),
        decoration: BoxDecoration(
          color: AppColors.bgWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.gold.withValues(alpha: 0.35),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withValues(alpha: 0.07),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 52,
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Juz',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 8,
                        color: AppColors.primaryDarkest,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${meta.num}',
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDarkest,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meta.name,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: AppColors.gold.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          '${meta.start} → ${meta.end}',
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 10,
                            color: AppColors.goldDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListenableBuilder(
                      listenable: QuranAudioService(),
                      builder: (context, _) {
                        final audio = QuranAudioService();
                        final isPlaying =
                            audio.isPlaying &&
                            audio.currentId == 'juz_${meta.num}';
                        return IconButton(
                          icon: Icon(
                            isPlaying
                                ? Icons.pause_circle_filled_rounded
                                : Icons.play_circle_filled_rounded,
                            color: AppColors.primaryDark,
                            size: 26,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            if (isPlaying) {
                              audio.togglePause();
                            } else {
                              // Extract surahs from start and end strings (e.g. "1:1" -> 1)
                              final startSurah = int.parse(
                                meta.start.split(':')[0],
                              );
                              final endSurah = int.parse(
                                meta.end.split(':')[0],
                              );
                              final surahs = List.generate(
                                endSurah - startSurah + 1,
                                (i) => startSurah + i,
                              );
                              audio.playJuzz(meta.num, meta.name, surahs);
                            }
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 6),
                    ListenableBuilder(
                      listenable: QuranDownloadService(),
                      builder: (context, _) {
                        final service = QuranDownloadService();
                        final id = 'juz_${meta.num}';

                        Widget buildAudioStatus() {
                          final isDownloaded = service.isDownloaded(
                            id,
                            DownloadType.audio,
                          );
                          final progress = service.getProgress(
                            id,
                            DownloadType.audio,
                          );

                          if (progress?.isDownloading == true) {
                            return SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                value: progress!.progress,
                                strokeWidth: 2,
                                color: AppColors.gold,
                              ),
                            );
                          } else if (progress?.error != null) {
                            return const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 16,
                            );
                          } else if (isDownloaded) {
                            return const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 16,
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        }

                        Widget buildPdfStatus() {
                          final isDownloaded = service.isDownloaded(
                            id,
                            DownloadType.pdf,
                          );
                          final progress = service.getProgress(
                            id,
                            DownloadType.pdf,
                          );

                          if (progress?.isDownloading == true) {
                            return SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                value: progress!.progress,
                                strokeWidth: 2,
                                color: AppColors.gold,
                              ),
                            );
                          } else if (progress?.error != null) {
                            return const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 16,
                            );
                          } else if (isDownloaded) {
                            return InkWell(
                              onTap: () async {
                                final path = await service.getFilePath(
                                  id,
                                  DownloadType.pdf,
                                );
                                if (context.mounted) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PdfViewerScreen(
                                        title: 'Juz ${meta.num}',
                                        localPath: path,
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: const Icon(
                                Icons.picture_as_pdf_rounded,
                                color: AppColors.goldDark,
                                size: 18,
                              ),
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        }

                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.music_note,
                                  size: 12,
                                  color: AppColors.textGrey,
                                ),
                                const SizedBox(height: 1),
                                buildAudioStatus(),
                              ],
                            ),
                            const SizedBox(width: 10),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.picture_as_pdf,
                                  size: 12,
                                  color: AppColors.textGrey,
                                ),
                                const SizedBox(height: 1),
                                buildPdfStatus(),
                              ],
                            ),
                            const SizedBox(width: 6),
                            IconButton(
                              icon: const Icon(
                                Icons.download_for_offline_rounded,
                                color: AppColors.textGrey,
                              ),
                              iconSize: 22,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  backgroundColor: Colors.transparent,
                                  builder: (_) => DownloadDialog(
                                    id: id,
                                    title: 'Juz ${meta.num}',
                                    audioUrl:
                                        'https://server7.mp3quran.net/basit/juz_${'${meta.num}'.padLeft(2, '0')}.mp3',
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      meta.ar,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontFamily: actualArabicFont,
                        fontSize: useUrduFont ? 13 : 17,
                        color: AppColors.goldDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// ARABIC READ SCREEN
// ══════════════════════════════════════════════════════════════════════════════
class ArabicReadScreen extends StatefulWidget {
  final Map<String, dynamic>? surah;
  final JuzMeta? juzMeta;
  final bool isJuzMode;
  final bool showTranslation;
  final bool useUrduFont;
  final String? arabicFont;

  const ArabicReadScreen({
    super.key,
    required this.surah,
    required this.showTranslation,
    this.useUrduFont = false,
    this.arabicFont,
  }) : juzMeta = null,
       isJuzMode = false;

  const ArabicReadScreen.juz({
    super.key,
    required JuzMeta meta,
    required this.showTranslation,
    this.useUrduFont = false,
    this.arabicFont,
  }) : juzMeta = meta,
       surah = null,
       isJuzMode = true;

  @override
  State<ArabicReadScreen> createState() => _ArabicReadScreenState();
}

class _ArabicReadScreenState extends State<ArabicReadScreen> {
  List<JuzSurahGroup>? _juzGroups;
  List<Map<String, String>>? _surahAyahs;
  bool _loading = true;
  String? _error;
  double _fontSize = 28; // Larger default size
  bool _showUrdu = false; // EN/UR toggle for translation mode
  late String _currentArabicFont;

  @override
  void initState() {
    super.initState();
    final validFonts = [
      'AlMushaf',
      'AlMajeed',
      'AlQalam',
      'PDMS_Saleem',
      'KfgqpcHafs',
    ];
    if (widget.arabicFont != null && validFonts.contains(widget.arabicFont)) {
      _currentArabicFont = widget.arabicFont!;
    } else {
      _currentArabicFont = _kQuranicFont;
    }
    _showUrdu = widget.useUrduFont; // Initialize with preference
    _load();
  }

  @override
  void didUpdateWidget(ArabicReadScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.useUrduFont != oldWidget.useUrduFont ||
        widget.arabicFont != oldWidget.arabicFont) {
      setState(() {
        final validFonts = [
          'AlMushaf',
          'AlMajeed',
          'AlQalam',
          'PDMS_Saleem',
          'KfgqpcHafs',
        ];
        if (widget.arabicFont != null &&
            validFonts.contains(widget.arabicFont)) {
          _currentArabicFont = widget.arabicFont!;
        } else {
          _currentArabicFont = _kQuranicFont;
        }
        _showUrdu = widget.useUrduFont;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (widget.isJuzMode) {
        final data = await QuranApiService.fetchJuz(widget.juzMeta!.num);
        if (!mounted) return;
        if (data == null) throw Exception();
        setState(() {
          _juzGroups = data;
          _loading = false;
        });
      } else {
        final num = widget.surah!['num'] as int;
        // Local cache first (instant), then fetch full (Arabic+EN+UR+audio)
        List<Map<String, String>>? data = await QuranApiService.getLocalAyahs(
          num,
        );
        data ??= await QuranApiService.fetchSurahFull(num);
        data ??= await QuranApiService.fetchSurah(num);
        if (!mounted) return;
        if (data == null) throw Exception();
        setState(() {
          _surahAyahs = data;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Could not load. Check your connection.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.quranBgLightGreen,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            if (_loading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.gold),
                ),
              )
            else if (_error != null)
              _buildError()
            else
              Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    final title = widget.isJuzMode
        ? 'Juz ${widget.juzMeta!.num} — ${widget.juzMeta!.name}'
        : widget.surah!['name'] as String;
    final subtitle = widget.isJuzMode
        ? (widget.showTranslation ? 'Arabic + Translation' : 'Uthmani Script')
        : '${widget.surah!['ayahs']} Ayahs • ${widget.surah!['type']}';

    return Container(
      color: AppColors.primaryDark,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primaryMid.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: AppColors.textWhite,
                size: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textWhite,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11,
                    color: AppColors.textGreenMuted,
                  ),
                ),
              ],
            ),
          ),
          // EN / UR toggle — only in translation mode
          if (widget.showTranslation) ...[
            _langBtn('EN', !_showUrdu),
            const SizedBox(width: 4),
            _langBtn('اردو', _showUrdu),
            const SizedBox(width: 8),
          ],
          // PDF button — only for single surah mode
          if (!widget.isJuzMode) ...[
            if (SurahsData.isPdfAvailable(widget.surah!)) ...[
              GestureDetector(
                onTap: () {
                  final pdfAssetPath = getSurahPdfAssetPath(widget.surah!);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PdfViewerScreen(
                        title: widget.surah!['name'] as String,
                        assetPath: pdfAssetPath,
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.primaryMid,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.picture_as_pdf,
                    color: AppColors.gold,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 6),
            ],
          ],
          // Font selector button
          GestureDetector(
            onTap: _showFontPicker,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.primaryMid,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.text_fields,
                color: AppColors.gold,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 6),
          _fontBtn('−', () {
            if (_fontSize > 20) setState(() => _fontSize -= 2);
          }),
          const SizedBox(width: 6),
          _fontBtn('+', () {
            if (_fontSize < 48) setState(() => _fontSize += 2);
          }),
        ],
      ),
    );
  }

  void _showFontPicker() async {
    final prefs = await SharedPreferences.getInstance();
    final fonts = [
      {'name': 'Al Mushaf', 'id': 'AlMushaf'},
      {'name': 'Al Majeed', 'id': 'AlMajeed'},
      {'name': 'Indo-Pak (Al Qalam)', 'id': 'AlQalam'},
      {'name': 'Saleem (PDMS)', 'id': 'PDMS_Saleem'},
      {'name': 'Hafs Uthmanic Script', 'id': 'KfgqpcHafs'},
    ];

    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.bgWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose Arabic Font',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: fonts.map((f) {
                final isSel = _currentArabicFont == f['id'];
                return GestureDetector(
                  onTap: () async {
                    setState(() => _currentArabicFont = f['id']!);
                    await prefs.setString('quran_font', f['id']!);
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSel
                          ? AppColors.gold
                          : AppColors.primaryDark.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      f['name']!,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            // PDF button (only for single surah mode)
            if (!widget.isJuzMode &&
                SurahsData.isPdfAvailable(widget.surah!)) ...[
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  Navigator.pop(ctx);
                  final pdfAssetPath = getSurahPdfAssetPath(widget.surah!);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PdfViewerScreen(
                        title: widget.surah!['name'] as String,
                        assetPath: pdfAssetPath,
                      ),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primaryDark.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.picture_as_pdf,
                        color: AppColors.primaryDark,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Open PDF',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _langBtn(String label, bool active) => GestureDetector(
    onTap: () => setState(() => _showUrdu = (label == 'اردو')),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: active ? AppColors.gold : AppColors.primaryMid,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: active ? AppColors.primaryDarkest : AppColors.textGreenMuted,
        ),
      ),
    ),
  );

  Widget _fontBtn(String label, VoidCallback fn) => GestureDetector(
    onTap: fn,
    child: Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: AppColors.primaryMid,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.gold,
            height: 1.0,
          ),
        ),
      ),
    ),
  );

  Widget _buildError() => Expanded(
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, size: 48, color: AppColors.textLightGrey),
          const SizedBox(height: 12),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              color: AppColors.textGrey,
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _load,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.gold,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDarkest,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  // ── Main content router ───────────────────────────────────────────────────
  Widget _buildContent() {
    if (widget.isJuzMode) {
      return ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 32),
        itemCount: _juzGroups!.length + 1,
        itemBuilder: (_, i) {
          if (i == _juzGroups!.length) return _nextJuzBtn();
          return _buildSurahBlock(_juzGroups![i]);
        },
      );
    }

    // ── Single surah mode ─────────────────────────────────────────────────
    final surahNum = widget.surah!['num'] as int;
    final ayahs = _surahAyahs!;

    // Strip leading Bismillah ayah returned by API (it is NOT a counted ayah
    // for most surahs — the API prepends it). Exception: Surah 9 has no bismillah.
    final bool hasBismillahBanner = surahNum != 9;
    List<Map<String, String>> displayAyahs = ayahs;

    // For all surahs with bismillah banner,
    // if the first ayah is bismillah, remove it from the flowing text
    // then adjust all remaining ayah numbers so they start at 1
    if (hasBismillahBanner && ayahs.isNotEmpty) {
      final first = ayahs.first;
      final isApiPrepended =
          first['num'] == '0' ||
          (first['num'] == '1' && _isBismillahText(first['a'] ?? ''));

      if (isApiPrepended) {
        // Remove the prepended bismillah — it will be shown by the banner
        displayAyahs = ayahs.sublist(1);

        // Adjust ALL remaining ayah numbers (subtract 1) so they start from 1
        displayAyahs = displayAyahs.map((ayah) {
          final originalNum = int.parse(ayah['num']!);
          return {...ayah, 'num': (originalNum - 1).toString()};
        }).toList();
      }
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        children: [
          // ── Bismillah banner (centred, bordered) ──────────────────────────
          if (hasBismillahBanner) _buildBismillahBanner(),

          const SizedBox(height: 12),

          // ── Ayah content ──────────────────────────────────────────────────
          if (widget.showTranslation)
            ...displayAyahs.map(
              (a) => _buildAyahCard(
                a['a']!,
                a['t']!,
                a['num']!,
                surahNum,
                urduTrans: a['tu'] ?? '',
                audioUrl: a['audio'] ?? '',
                showUrdu: _showUrdu, // Fixed: use _showUrdu state
              ),
            )
          else
            _buildMushaafBlock(displayAyahs, surahNum),
        ],
      ),
    );
  }

  // ── Surah block inside Juz mode ───────────────────────────────────────────
  Widget _buildSurahBlock(JuzSurahGroup g) {
    final bool hasBismillah = g.surahNum != 9;
    final bool startsFromAyah1 =
        g.ayahs.isNotEmpty && g.ayahs.first['num'] == '1';

    List<Map<String, String>> displayAyahs = g.ayahs;
    if (hasBismillah && startsFromAyah1 && g.ayahs.isNotEmpty) {
      final first = g.ayahs.first;
      if (_isBismillahText(first['a'] ?? '')) {
        displayAyahs = g.ayahs.sublist(1);

        // Adjust ALL remaining ayah numbers (subtract 1) so they start from 1
        displayAyahs = displayAyahs.map((ayah) {
          final originalNum = int.parse(ayah['num']!);
          return {...ayah, 'num': (originalNum - 1).toString()};
        }).toList();
      }
    }

    return Column(
      children: [
        // Surah header strip
        Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryDark, AppColors.primaryDarkest],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${g.surahNum}',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDarkest,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                g.surahName,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textWhite,
                ),
              ),
              const Spacer(),
              Text(
                g.surahArabic,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontFamily: _currentArabicFont,
                  fontSize: 20,
                  color: AppColors.gold,
                ),
              ),
            ],
          ),
        ),

        // Bismillah banner for first ayah of surah
        if (hasBismillah && startsFromAyah1) ...[
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildBismillahBanner(),
          ),
        ],

        const SizedBox(height: 10),

        // Ayah content
        if (widget.showTranslation)
          ...displayAyahs.map(
            (a) => _buildAyahCard(
              a['a']!,
              a['t']!,
              a['num']!,
              g.surahNum,
              urduTrans: a['tu'] ?? '',
              audioUrl: a['audio'] ?? '',
              showUrdu: _showUrdu, // Fixed: use _showUrdu state
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildMushaafBlock(displayAyahs, g.surahNum),
          ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // BISMILLAH BANNER — centred, standalone bordered box (matches screenshot)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildBismillahBanner() {
    final isAlQalam = _currentArabicFont == 'AlQalam';
    final isPDMS = _currentArabicFont == 'PDMS_Saleem';
    final isHafs = _currentArabicFont == 'KfgqpcHafs';
    final isAlMushaf = _currentArabicFont == 'AlMushaf';
    final isAlMajeed = _currentArabicFont == 'AlMajeed';

    double actualFontSize = _fontSize;
    double actualHeight = 2.3; // Increased
    double horizontalPadding = 26; // Increased

    if (isAlQalam) {
      actualFontSize = _fontSize * 1.3;
      actualHeight = 2.0; // Increased
      horizontalPadding = 28;
    } else if (isPDMS) {
      actualFontSize = _fontSize;
      actualHeight = 2.75; // Increased
      horizontalPadding = 28;
    } else if (isHafs) {
      actualFontSize = _fontSize * 1.1;
      actualHeight = 3.1; // Increased
      horizontalPadding = 32;
    } else if (isAlMushaf) {
      actualFontSize = _fontSize * 1.05;
      actualHeight = 3.0; // Increased
      horizontalPadding = 30;
    } else if (isAlMajeed) {
      actualFontSize = _fontSize * 1.0;
      actualHeight = 2.85; // Increased
      horizontalPadding = 28;
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: 18,
        horizontal: horizontalPadding,
      ),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.6),
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        _kBismillah,
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: _currentArabicFont,
          fontSize: actualFontSize + 2,
          color: AppColors.primaryDark,
          height: actualHeight,
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // MUSHAF BLOCK — all ayahs as ONE flowing RichText paragraph (matches
  // the hamariweb / screenshot layout). Ayah numbers inline in gold ﴿n﴾.
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildMushaafBlock(List<Map<String, String>> ayahs, int surahNum) {
    if (ayahs.isEmpty) return const SizedBox.shrink();

    final isAlQalam = _currentArabicFont == 'AlQalam';
    final isPDMS = _currentArabicFont == 'PDMS_Saleem';
    final isHafs = _currentArabicFont == 'KfgqpcHafs';
    final isAlMushaf = _currentArabicFont == 'AlMushaf';
    final isAlMajeed = _currentArabicFont == 'AlMajeed';

    double actualFontSize = _fontSize;
    double actualHeight = 2.55; // Increased by ~8%
    double ayahMarkerSizeRatio = 0.80;
    double horizontalPadding = 28; // Increased
    double verticalPadding = 22; // Increased
    double letterSpacing = 0;

    if (isAlQalam) {
      actualFontSize = _fontSize * 1.3;
      actualHeight = 1.85; // Increased
      letterSpacing = 0.5;
      horizontalPadding = 30;
    } else if (isPDMS) {
      actualFontSize = _fontSize;
      actualHeight = 2.75; // Increased
      horizontalPadding = 30;
    } else if (isHafs) {
      actualFontSize = _fontSize * 1.1;
      actualHeight = 3.45; // Increased
      ayahMarkerSizeRatio = 0.85;
      horizontalPadding = 32;
      verticalPadding = 26;
    } else if (isAlMushaf) {
      actualFontSize = _fontSize * 1.05;
      actualHeight = 3.25; // Increased
      ayahMarkerSizeRatio = 0.82;
      horizontalPadding = 30;
      verticalPadding = 24;
    } else if (isAlMajeed) {
      actualFontSize = _fontSize * 1.0;
      actualHeight = 3.15; // Increased
      ayahMarkerSizeRatio = 0.83;
      horizontalPadding = 28;
      verticalPadding = 23;
    }

    final spans = <InlineSpan>[];
    for (int i = 0; i < ayahs.length; i++) {
      final ayahNum = ayahs[i]['num']!;
      if (i > 0) {
        spans.add(const TextSpan(text: '\u00A0'));
      }

      // Ayah text
      spans.add(
        TextSpan(
          text: ayahs[i]['a']!,
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              QuranAudioService().playAyah(surahNum, int.parse(ayahNum));
            },
          style: TextStyle(
            fontFamily: _currentArabicFont,
            fontSize: actualFontSize,
            color: AppColors.textDark,
            height: actualHeight,
            letterSpacing: letterSpacing,
          ),
        ),
      );
      // Ayah number marker  ﴿n﴾  in gold with proper spacing
      spans.add(
        TextSpan(
          text: ' \u06DD${ayahs[i]['num']!}\u06DE ',
          style: TextStyle(
            fontFamily: isAlQalam ? 'Amiri' : _currentArabicFont,
            fontSize: actualFontSize * ayahMarkerSizeRatio,
            color: AppColors.goldDark,
            fontWeight: FontWeight.w700,
            height: actualHeight,
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.55),
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: RichText(
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
        text: TextSpan(children: spans),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // AYAH CARD — translation mode (individual cards, unchanged UX)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildAyahCard(
    String arabic,
    String trans,
    String num,
    int surahNum, {
    String urduTrans = '',
    String audioUrl = '',
    bool showUrdu = false,
  }) {
    final displayTrans = (showUrdu && urduTrans.isNotEmpty) ? urduTrans : trans;
    final isUrdu = showUrdu && urduTrans.isNotEmpty;

    final isAlQalam = _currentArabicFont == 'AlQalam';
    final isPDMS = _currentArabicFont == 'PDMS_Saleem';
    final isHafs = _currentArabicFont == 'KfgqpcHafs';
    final isAlMushaf = _currentArabicFont == 'AlMushaf';
    final isAlMajeed = _currentArabicFont == 'AlMajeed';

    double actualFontSize = _fontSize;
    double actualHeight = 2.3; // Increased by ~8%
    double horizontalPadding = 20; // Increased
    double letterSpacing = 0;

    if (isAlQalam) {
      actualFontSize = _fontSize * 1.3;
      actualHeight = 1.85; // Increased
      letterSpacing = 0.5;
      horizontalPadding = 22;
    } else if (isPDMS) {
      actualFontSize = _fontSize;
      actualHeight = 2.55; // Increased
      horizontalPadding = 22;
    } else if (isHafs) {
      actualFontSize = _fontSize * 1.1;
      actualHeight = 3.0; // Increased
      horizontalPadding = 24;
    } else if (isAlMushaf) {
      actualFontSize = _fontSize * 1.05;
      actualHeight = 2.8; // Increased
      horizontalPadding = 22;
    } else if (isAlMajeed) {
      actualFontSize = _fontSize * 1.0;
      actualHeight = 2.7; // Increased
      horizontalPadding = 21;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.35),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Arabic text row
          Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              14,
              horizontalPadding,
              8,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gold ayah number circle
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: AppColors.gold,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      num,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDarkest,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$arabic \u06DD$num\u06DE ',
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: _currentArabicFont,
                      fontSize: actualFontSize,
                      color: AppColors.textDark,
                      height: actualHeight,
                      letterSpacing: letterSpacing,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Container(
              height: 1,
              color: AppColors.gold.withValues(alpha: 0.25),
            ),
          ),
          // Translation row
          Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              8,
              horizontalPadding,
              4,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$surahNum:$num ',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.goldDark,
                  ),
                ),
                Expanded(
                  child: Text(
                    displayTrans,
                    textDirection: isUrdu
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                    style: TextStyle(
                      fontFamily: isUrdu ? 'NotoNastaliq' : 'Cairo',
                      fontSize: isUrdu ? 13 : 13,
                      color: AppColors.textGrey,
                      height: 1.85, // Increased by ~8%
                      fontStyle: isUrdu ? FontStyle.normal : FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Audio play row
          Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              2,
              horizontalPadding,
              10,
            ),
            child: ListenableBuilder(
              listenable: QuranAudioService(),
              builder: (context, _) {
                final audio = QuranAudioService();
                final isThisAyahPlaying =
                    audio.isPlaying && audio.currentId == 'ayah_$surahNum-$num';
                return GestureDetector(
                  onTap: () {
                    if (isThisAyahPlaying) {
                      audio.stop();
                    } else {
                      audio.playAyah(surahNum, int.parse(num));
                    }
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isThisAyahPlaying
                              ? AppColors.gold
                              : AppColors.primaryDark,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isThisAyahPlaying
                              ? Icons.stop_rounded
                              : Icons.play_arrow_rounded,
                          color: isThisAyahPlaying
                              ? AppColors.primaryDarkest
                              : AppColors.gold,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isThisAyahPlaying
                            ? 'Stop Recitation'
                            : 'Play Recitation',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11,
                          color: isThisAyahPlaying
                              ? AppColors.gold
                              : AppColors.textGrey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Next Juz button ───────────────────────────────────────────────────────
  Widget _nextJuzBtn() {
    if (!widget.isJuzMode || widget.juzMeta!.num >= 30) {
      return const SizedBox(height: 40);
    }
    final next = kJuzList[widget.juzMeta!.num];
    return Padding(
      padding: const EdgeInsets.all(20),
      child: GestureDetector(
        onTap: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ArabicReadScreen.juz(
              meta: next,
              showTranslation: widget.showTranslation,
            ),
          ),
        ),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryDark, AppColors.primaryMid],
            ),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Next Juz',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textWhite,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${widget.juzMeta!.num + 1}',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDarkest,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.arrow_forward,
                color: AppColors.textWhite,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
