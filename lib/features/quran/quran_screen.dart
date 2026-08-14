import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/figma_tokens.dart';
import '../../core/utils/breakpoints.dart';
import '../../core/l10n/app_localizations.dart';
import '../../shared/widgets/ask_iman_app_bar.dart';
import '../../shared/widgets/tooltip_overlay.dart';
import '../../shared/widgets/islamic_background.dart';
import '../../core/services/tutorial_service.dart';
import 'tabs/talawat_tab.dart';
import 'tabs/translation_tab.dart';
import 'tabs/ayah_tab.dart';
import 'tabs/ahadees_tab.dart';
import 'tabs/juzz_tab.dart';
import 'data/surahs_data.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key, this.onNavigateToTab});

  static final GlobalKey<QuranScreenState> screenKey =
      GlobalKey<QuranScreenState>();

  final void Function(int index)? onNavigateToTab;

  @override
  State<QuranScreen> createState() => QuranScreenState();
}

class QuranScreenState extends State<QuranScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tc;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _useUrduTranslation = false;
  String _selectedFont = 'Amiri';
  bool _hasShownInitialPrefs = false;
  bool _isPlaying = false;

  void showPreferencesAutomatically() {
    if (!_hasShownInitialPrefs) {
      _hasShownInitialPrefs = true;
      _showInitialPreferences();
    }
  }

  void animateToTab(int index) {
    if (index >= 0 && index < _tabs.length && _tc.index != index) {
      _tc.animateTo(index);
    }
  }

  static const List<Map<String, String>> _fontOptions = [
    {'name': 'Al Mushaf', 'fontFamily': 'AlMushaf'},
    {'name': 'Al Majeed', 'fontFamily': 'AlMajeed'},
    {'name': 'Indo-Pak (Al Qalam)', 'fontFamily': 'AlQalam'},
    {'name': 'Saleem (PDMS)', 'fontFamily': 'PDMS_Saleem'},
    {'name': 'Hafs Uthmanic Script', 'fontFamily': 'KfgqpcHafs'},
  ];

  static const List<({IconData icon, String label})> _tabs = [
    (icon: Icons.headphones_rounded, label: 'Talawat'),
    (icon: Icons.language_rounded, label: 'Tafseer'),
    (icon: Icons.menu_book_rounded, label: 'Ahadith'),
    (icon: Icons.edit_note_rounded, label: 'Juzz'),
    (icon: Icons.share_rounded, label: 'Share'),
  ];

  @override
  void initState() {
    super.initState();
    _tc = TabController(length: _tabs.length, vsync: this);
    _tc.addListener(() {
      setState(() {});
      Future.delayed(const Duration(milliseconds: 50), () {
        TutorialService.instance.forceRefresh();
      });
    });
    _checkFirstTime();
  }

  Future<void> _checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      final savedFont = prefs.getString('quran_font');
      final validFonts = _fontOptions.map((f) => f['fontFamily']).toList();
      _selectedFont = (savedFont != null && validFonts.contains(savedFont))
          ? savedFont
          : 'AlMushaf';
      _useUrduTranslation = prefs.getBool('quran_urdu') ?? false;
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('quran_font', _selectedFont);
    await prefs.setBool('quran_urdu', _useUrduTranslation);
  }

  void _showInitialPreferences() {
    final loc = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => Container(
          decoration: const BoxDecoration(
            color: FigmaTokens.surfaceCard,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: FigmaTokens.borderHairline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                loc.translate('quranSettings'),
                style: const TextStyle(
                  fontFamily: FigmaTokens.fontFamilyUiSans,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: FigmaTokens.brandDeepGreen,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                loc.translate('arabicFontStyle'),
                style: const TextStyle(
                  fontFamily: FigmaTokens.fontFamilyUiSans,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: FigmaTokens.textMuted,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: FigmaTokens.surfacePanelMint,
                  borderRadius: BorderRadius.circular(FigmaTokens.radiusCardSm),
                  border: Border.all(
                    color: FigmaTokens.accentGoldAmber.withValues(alpha: 0.3),
                  ),
                ),
                child: Center(
                  child: Text(
                    'Ø¨ÙØ³Ù’Ù…Ù Ø§Ù„Ù„ÙŽÙ‘Ù‡Ù Ø§Ù„Ø±ÙŽÙ‘Ø­Ù’Ù…ÙŽÙ†Ù Ø§Ù„Ø±ÙŽÙ‘Ø­ÙÙŠÙ…Ù',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: _selectedFont,
                      fontSize: 24,
                      color: FigmaTokens.brandDeepGreen,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _fontOptions.map((f) {
                  final isSel = _selectedFont == f['fontFamily'];
                  return GestureDetector(
                    onTap: () {
                      setDialogState(() => _selectedFont = f['fontFamily']!);
                      setState(() {});
                      _savePreferences();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSel ? FigmaTokens.accentGoldAmber : FigmaTokens.surfaceCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSel ? FigmaTokens.accentGoldAmber : FigmaTokens.borderHairline,
                        ),
                      ),
                      child: Text(
                        f['name']!,
                        style: TextStyle(
                          fontFamily: FigmaTokens.fontFamilyUiSans,
                          fontWeight: FontWeight.w600,
                          color: isSel ? FigmaTokens.textOnDark : FigmaTokens.textHeading,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              if (_tc.index == 1 || _tc.index == 2 || _tc.index == 2) ...[
                Text(
                  loc.translate('translationLanguage'),
                  style: const TextStyle(
                    fontFamily: FigmaTokens.fontFamilyUiSans,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: FigmaTokens.textMuted,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildLanguageBtn(
                      label: loc.translate('english'),
                      isSel: !_useUrduTranslation,
                      onTap: () {
                        setDialogState(() => _useUrduTranslation = false);
                        setState(() {});
                        _savePreferences();
                      },
                    ),
                    const SizedBox(width: 12),
                    _buildLanguageBtn(
                      label: loc.translate('urdu'),
                      isSel: _useUrduTranslation,
                      onTap: () {
                        setDialogState(() => _useUrduTranslation = true);
                        setState(() {});
                        _savePreferences();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FigmaTokens.brandDeepGreen,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    loc.translate('startReading').toUpperCase(),
                    style: const TextStyle(
                      fontFamily: FigmaTokens.fontFamilyUiSans,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: FigmaTokens.textOnDark,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageBtn({
    required String label,
    required bool isSel,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSel ? FigmaTokens.accentGoldAmber : FigmaTokens.surfaceCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSel ? FigmaTokens.accentGoldAmber : FigmaTokens.borderHairline,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: FigmaTokens.fontFamilyUiSans,
                fontWeight: FontWeight.w600,
                color: isSel ? FigmaTokens.textOnDark : FigmaTokens.textHeading,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tc.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String _searchHint(BuildContext context) {
    final loc = AppLocalizations.of(context);
    switch (_tc.index) {
      case 0:
        return loc.translate('searchSurahOrJuz');
      case 1:
        return loc.translate('searchSurahOrJuz');
      case 2:
        return loc.translate('searchHadithOrTopic');
      case 3:
        return loc.translate('searchSurahOrJuz');
      case 4:
        return loc.translate('searchAyahByTopic');
      default:
        return loc.translate('search');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FigmaTokens.surfaceBackground,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          IslamicBackground(
            patternOpacity: 0.06,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ContentContainer(
                maxWidth: 1200,
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    _buildFigmaHero(context),
                    const SizedBox(height: 28),
                    if (_tc.index < 3 || _tc.index == 3) _buildSearchBar(context),
                    const SizedBox(height: 8),
                    _buildTabBar(context),
                    const SizedBox(height: 8),
                    _buildTabContent(context),
                    const SizedBox(height: 48),
                    _buildFigmaFooter(context),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildStickyAudioBar(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(BuildContext context) {
    return TooltipOverlay(
      id: _getCurrentTutorialId(),
      title: _getCurrentTutorialTitle(context),
      description: _getCurrentTutorialDesc(context),
      arrowDirection: TooltipArrowDirection.up,
      child: IndexedStack(
        index: _tc.index,
        children: [
          _buildTalawatSurahGrid(context),
          TranslationTab(
            searchQuery: _searchQuery,
            useUrduFont: _useUrduTranslation,
            arabicFont: _selectedFont,
          ),
          AhadeesTab(
            searchQuery: _searchQuery,
            arabicFont: _selectedFont,
            useUrduFont: _useUrduTranslation,
          ),
          JuzzTab(searchQuery: _searchQuery),
          AyahTab(),
        ],
      ),
    );
  }

  String _getCurrentTutorialId() {
    switch (_tc.index) {
      case 0:
        return 'tut_quran_talawat';
      case 1:
        return 'tut_quran_translation';
      case 2:
        return 'tut_quran_ahadees';
      case 3:
        return 'tut_quran_ayat';
      case 4:
        return 'tut_quran_tafseer';
      default:
        return 'tut_quran_talawat';
    }
  }

  String _getCurrentTutorialTitle(BuildContext context) {
    final loc = AppLocalizations.of(context);
    switch (_tc.index) {
      case 0:
        return loc.translate('tutQuranTalawatTitle');
      case 1:
        return loc.translate('tutQuranTafseerTitle');
      case 2:
        return loc.translate('tutQuranAhadeesTitle');
      case 3:
        return loc.translate('tutQuranAyatTitle');
      case 4:
        return loc.translate('tutQuranTranslationTitle');
      default:
        return loc.translate('tutQuranTalawatTitle');
    }
  }

  String _getCurrentTutorialDesc(BuildContext context) {
    final loc = AppLocalizations.of(context);
    switch (_tc.index) {
      case 0:
        return loc.translate('tutQuranTalawatDesc');
      case 1:
        return loc.translate('tutQuranTafseerDesc');
      case 2:
        return loc.translate('tutQuranAhadeesDesc');
      case 3:
        return loc.translate('tutQuranAyatDesc');
      case 4:
        return loc.translate('tutQuranTranslationDesc');
      default:
        return loc.translate('tutQuranTalawatDesc');
    }
  }

  PreferredSizeWidget _buildAppBar() {
    return AskImanAppBar(
      showBackButton: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: FigmaTokens.textOnDark),
          onPressed: _showInitialPreferences,
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: FigmaTokens.surfaceCard,
          borderRadius: BorderRadius.circular(FigmaTokens.radiusInput),
          border: Border.all(color: FigmaTokens.borderHairline),
          boxShadow: FigmaTokens.cardShadowSm,
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (v) => setState(() => _searchQuery = v),
          style: const TextStyle(
            color: FigmaTokens.textHeading,
            fontFamily: FigmaTokens.fontFamilyUiSans,
          ),
          decoration: InputDecoration(
            hintText: _searchHint(context),
            hintStyle: TextStyle(
              color: FigmaTokens.textMuted,
              fontFamily: FigmaTokens.fontFamilyUiSans,
              fontSize: 14,
            ),
            prefixIcon: const Icon(
              Icons.search,
              color: FigmaTokens.accentGoldAmber,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    final isWide = context.isTablet || context.isDesktop;
    return TooltipOverlay(
      id: 'tut_quran',
      title: AppLocalizations.of(context).translate('tutQuranTitle'),
      description: AppLocalizations.of(context).translate('tutQuranDesc'),
      arrowDirection: TooltipArrowDirection.down,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          decoration: BoxDecoration(
            color: FigmaTokens.surfaceCard,
            borderRadius: BorderRadius.circular(FigmaTokens.radiusCardSm),
            border: Border.all(color: FigmaTokens.borderHairline),
            boxShadow: FigmaTokens.cardShadowSm,
          ),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
          child: TabBar(
            controller: _tc,
            isScrollable: !isWide,
            indicator: BoxDecoration(
              color: FigmaTokens.accentGoldAmber,
              borderRadius: BorderRadius.circular(12),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            labelColor: FigmaTokens.textOnDark,
            unselectedLabelColor: FigmaTokens.textBody,
            labelStyle: const TextStyle(
              fontFamily: FigmaTokens.fontFamilyUiSans,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
            unselectedLabelStyle: const TextStyle(
              fontFamily: FigmaTokens.fontFamilyUiSans,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            tabs: _tabs.map((t) {
              return Tab(
                icon: Icon(t.icon, size: 20),
                text: t.label,
                height: isWide ? 60 : 72,
                iconMargin: const EdgeInsets.only(bottom: 4),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildFigmaHero(BuildContext context) {
    final isWide = context.isDesktop || context.isTablet;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: FigmaTokens.surfacePanelMint,
          borderRadius: BorderRadius.circular(FigmaTokens.radiusCard),
          boxShadow: [
            BoxShadow(
              color: FigmaTokens.brandDeepGreen.withValues(alpha: 0.08),
              blurRadius: 32,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(FigmaTokens.radiusCard),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/mosque interior.png',
                  fit: BoxFit.cover,
                  opacity: const AlwaysStoppedAnimation(0.08),
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  isWide ? 56 : 24,
                  isWide ? 48 : 32,
                  isWide ? 56 : 24,
                  isWide ? 48 : 32,
                ),
                child: Column(
                  children: [
                    _buildStarOrnament(size: 40),
                    const SizedBox(height: 20),
                    Text(
                      'Ø¨ÙØ³Ù’Ù…Ù Ø§Ù„Ù„ÙŽÙ‘Ù‡Ù Ø§Ù„Ø±ÙŽÙ‘Ø­Ù’Ù…ÙŽÙ°Ù†Ù Ø§Ù„Ø±ÙŽÙ‘Ø­ÙÙŠÙ…Ù',
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontFamily: FigmaTokens.fontFamilyArabicSerif,
                        fontSize: isWide ? 40 : 28,
                        color: FigmaTokens.brandDeepGreen,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Al-QurÊ¾Än al-KarÄ«m',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: FigmaTokens.fontFamilyDisplaySerif,
                        fontSize: isWide ? 44 : 30,
                        fontWeight: FontWeight.w900,
                        color: FigmaTokens.brandDeepGreen,
                        height: 1.15,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildGoldAccentBar(),
                    const SizedBox(height: 24),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _buildHeroStatPill('114', 'Surahs'),
                        _buildHeroStatPill('6,236', 'Verses'),
                        _buildHeroStatPill('30', "Juz'"),
                      ],
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

  Widget _buildGoldAccentBar() => Container(
        width: 4,
        height: 48,
        decoration: BoxDecoration(
          color: FigmaTokens.accentGoldAmber,
          borderRadius: BorderRadius.circular(4),
        ),
      );

  Widget _buildStarOrnament({double size = 36, Color? color}) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _StarOrnamentPainter(color ?? FigmaTokens.accentGoldAmber),
        ),
      );

  Widget _buildHeroStatPill(String value, String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: FigmaTokens.surfaceCard,
          borderRadius: BorderRadius.circular(FigmaTokens.radiusInput),
          border: Border.all(color: FigmaTokens.borderHairline),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontFamily: FigmaTokens.fontFamilyUiSans,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: FigmaTokens.accentGoldAmber,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontFamily: FigmaTokens.fontFamilyUiSans,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: FigmaTokens.textMuted,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      );

  Widget _buildTalawatSurahGrid(BuildContext context) {
    final isWide = context.isTablet || context.isDesktop;
    final crossAxis = isWide ? 2 : 1;
    final surahs = SurahsData.surahs.where((s) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return s['name'].toString().toLowerCase().contains(q) ||
          s['arabic'].toString().contains(q) ||
          s['meaning'].toString().toLowerCase().contains(q) ||
          s['num'].toString() == q;
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 16),
            child: Row(
              children: [
                Text(
                  'All Surahs',
                  style: const TextStyle(
                    fontFamily: FigmaTokens.fontFamilyUiSans,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: FigmaTokens.brandDeepGreen,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: FigmaTokens.accentGoldSurface,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${surahs.length} found',
                    style: const TextStyle(
                      fontFamily: FigmaTokens.fontFamilyUiSans,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: FigmaTokens.accentGoldAmber,
                    ),
                  ),
                ),
              ],
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxis,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: isWide ? 3.2 : 3.6,
            ),
            itemCount: surahs.length,
            itemBuilder: (_, i) => _buildSurahCard(context, surahs[i]),
          ),
        ],
      ),
    );
  }

  Widget _buildSurahCard(BuildContext context, Map<String, dynamic> s) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => Scaffold(
              appBar: AskImanAppBar(
                showBackButton: true,
                title: '${s['arabic']} Â· ${s['name']}',
              ),
              body: TalawatTab(
                searchQuery: _searchQuery,
                useUrduFont: _useUrduTranslation,
                arabicFont: _selectedFont,
              ),
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: FigmaTokens.surfaceCard,
          borderRadius: BorderRadius.circular(FigmaTokens.radiusCard),
          border: Border.all(color: FigmaTokens.borderHairline),
          boxShadow: FigmaTokens.cardShadowSm,
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            Container(
              width: FigmaTokens.accentBarWidth,
              height: 48,
              decoration: BoxDecoration(
                color: FigmaTokens.accentGoldAmber,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: FigmaTokens.surfacePanelMint,
                border: Border.all(color: FigmaTokens.accentGoldAmber.withValues(alpha: 0.3)),
              ),
              child: Center(
                child: Text(
                  '${s['num']}',
                  style: const TextStyle(
                    fontFamily: FigmaTokens.fontFamilyUiSans,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: FigmaTokens.brandDeepGreen,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    s['arabic'] as String,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      fontFamily: FigmaTokens.fontFamilyArabicSerif,
                      fontSize: 22,
                      color: FigmaTokens.brandDeepGreen,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        s['name'] as String,
                        style: const TextStyle(
                          fontFamily: FigmaTokens.fontFamilyUiSans,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: FigmaTokens.textHeading,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Â·',
                        style: TextStyle(
                          color: FigmaTokens.textMuted,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${s['ayahs']} verses',
                        style: const TextStyle(
                          fontFamily: FigmaTokens.fontFamilyUiSans,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: FigmaTokens.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: (s['type'] as String) == 'MAKKI'
                    ? FigmaTokens.brandDeepGreen.withValues(alpha: 0.08)
                    : FigmaTokens.accentGoldSurface,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                s['type'] as String,
                style: TextStyle(
                  fontFamily: FigmaTokens.fontFamilyUiSans,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: (s['type'] as String) == 'MAKKI'
                      ? FigmaTokens.brandMidGreen
                      : FigmaTokens.accentGoldAmber,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: FigmaTokens.accentGoldAmber,
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildStickyAudioBar(BuildContext context) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: FigmaTokens.brandDeepGreen,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: FigmaTokens.brandDeepGreen.withValues(alpha: 0.35),
            blurRadius: 32,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: FigmaTokens.accentGoldAmber.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: FigmaTokens.accentGoldAmber.withValues(alpha: 0.4)),
              ),
              child: Icon(
                Icons.music_note_rounded,
                color: FigmaTokens.accentGoldAmber,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Now Playing',
                    style: TextStyle(
                      fontFamily: FigmaTokens.fontFamilyUiSans,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: FigmaTokens.accentGoldAmber,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Surah Al-Fatihah â€” Mishary al-Afasy',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: FigmaTokens.fontFamilyUiSans,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: FigmaTokens.textOnDark,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _buildAudioIconBtn(Icons.skip_previous_rounded, 22),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => setState(() => _isPlaying = !_isPlaying),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: FigmaTokens.accentGoldAmber,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: FigmaTokens.accentGoldAmber.withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: FigmaTokens.brandDeepGreen,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 8),
            _buildAudioIconBtn(Icons.skip_next_rounded, 22),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioIconBtn(IconData icon, double size) => Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: FigmaTokens.textOnDark.withValues(alpha: 0.08),
          shape: BoxShape.circle,
          border: Border.all(color: FigmaTokens.textOnDark.withValues(alpha: 0.12)),
        ),
        child: Icon(
          icon,
          color: FigmaTokens.textOnDark.withValues(alpha: 0.9),
          size: size,
        ),
      );

  Widget _buildFigmaFooter(BuildContext context) {
    final isWide = context.isDesktop;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: FigmaTokens.brandDeepGreen,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(40, 48, 40, 32),
            child: isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 4, child: _footerBrand()),
                      const SizedBox(width: 32),
                      Expanded(
                        flex: 2,
                        child: _footerCol('Explore', ['Quran', 'Prayer', 'Dhikr', 'Events']),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 2,
                        child: _footerCol('Community', ['Classes', 'Charity', 'Family', 'About Us']),
                      ),
                      const SizedBox(width: 24),
                      Expanded(flex: 3, child: _footerContact()),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _footerBrand(),
                      const SizedBox(height: 32),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _footerCol('Explore', ['Quran', 'Prayer', 'Dhikr', 'Events']),
                          ),
                          Expanded(
                            child: _footerCol(
                              'Community',
                              ['Classes', 'Charity', 'Family', 'About Us'],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      _footerContact(),
                    ],
                  ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            decoration: BoxDecoration(
              color: FigmaTokens.accentGoldAmber.withValues(alpha: 0.12),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                Text(
                  'Â© ${DateTime.now().year} ASK ÄªMÄ€N â€” All rights reserved.',
                  style: const TextStyle(
                    fontFamily: FigmaTokens.fontFamilyUiSans,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: FigmaTokens.accentGoldLight,
                  ),
                ),
                const Spacer(),
                Text(
                  'Built with ðŸ¤² for the Ummah',
                  style: TextStyle(
                    fontFamily: FigmaTokens.fontFamilyUiSans,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: FigmaTokens.textOnDark.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _footerBrand() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'ASK',
                style: const TextStyle(
                  fontFamily: FigmaTokens.fontFamilyDisplaySerif,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: FigmaTokens.accentGoldAmber,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Ø§ÛŒÙ…Ø§Ù†',
                style: TextStyle(
                  fontFamily: 'NotoNastaliq',
                  fontSize: 28,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Guiding hearts to the light of IslÄm â€” one Äyah, one sujÅ«d, one day at a time.',
            style: TextStyle(
              fontFamily: FigmaTokens.fontFamilyUiSans,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.75),
              height: 1.55,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _footerSocial(Icons.facebook_outlined),
              const SizedBox(width: 10),
              _footerSocial(Icons.alternate_email_rounded),
              const SizedBox(width: 10),
              _footerSocial(Icons.ondemand_video_rounded),
              const SizedBox(width: 10),
              _footerSocial(Icons.share_location_rounded),
            ],
          ),
        ],
      );

  Widget _footerSocial(IconData icon) => Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
        ),
        child: Icon(icon, color: FigmaTokens.accentGoldAmber, size: 18),
      );

  Widget _footerCol(String heading, List<String> items) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            heading.toUpperCase(),
            style: const TextStyle(
              fontFamily: FigmaTokens.fontFamilyUiSans,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: FigmaTokens.accentGoldAmber,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 16),
          ...items.map(
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                i,
                style: TextStyle(
                  fontFamily: FigmaTokens.fontFamilyUiSans,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.82),
                ),
              ),
            ),
          ),
        ],
      );

  Widget _footerContact() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'STAY CONNECTED',
            style: TextStyle(
              fontFamily: FigmaTokens.fontFamilyUiSans,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: FigmaTokens.accentGoldAmber,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 16),
          _contactRow(Icons.email_outlined, 'hello@askiman.app'),
          const SizedBox(height: 12),
          _contactRow(Icons.location_on_outlined, 'Serving the Global Ummah'),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    style: const TextStyle(
                      fontFamily: FigmaTokens.fontFamilyUiSans,
                      color: Colors.white,
                      fontSize: 13,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Your email address',
                      hintStyle: TextStyle(
                        fontFamily: FigmaTokens.fontFamilyUiSans,
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 13,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FigmaTokens.accentGoldAmber,
                    foregroundColor: FigmaTokens.brandDeepGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  ),
                  child: const Text(
                    'Join',
                    style: TextStyle(
                      fontFamily: FigmaTokens.fontFamilyUiSans,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );

  Widget _contactRow(IconData icon, String text) => Row(
        children: [
          Icon(icon, color: FigmaTokens.accentGoldAmber, size: 18),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              fontFamily: FigmaTokens.fontFamilyUiSans,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.82),
            ),
          ),
        ],
      );
}

class _StarOrnamentPainter extends CustomPainter {
  final Color color;
  const _StarOrnamentPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;

    const points = 8;
    final outerR = size.width / 2 * 0.92;
    final innerR = size.width / 2 * 0.42;
    final cx = size.width / 2;
    final cy = size.height / 2;

    final path = Path();
    for (int i = 0; i < points * 2; i++) {
      final radius = i.isEven ? outerR : innerR;
      final angle = (i * 3.14159) / points - 3.14159 / 2;
      final x = cx + radius * _cos(angle);
      final y = cy + radius * _sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, paint);

    final innerCircle = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(Offset(cx, cy), size.width / 2 * 0.22, innerCircle);
  }

  double _cos(double r) => r == 0 ? 1.0 : _approxTrig(r, true);
  double _sin(double r) => r == 0 ? 0.0 : _approxTrig(r - 1.5708, true);

  double _approxTrig(double x, bool isCos) {
    final c = [
      1.0,
      -0.0000000239,
      -0.5,
      0.000027526,
      0.0416666,
      -0.00138889,
    ];
    final x2 = x * x;
    double r = 0;
    for (int i = c.length - 1; i >= 0; i--) {
      r = r * x2 + c[i];
    }
    return isCos ? r : x * (1 - x2 * 0.1666667);
  }

  @override
  bool shouldRepaint(covariant _StarOrnamentPainter oldDelegate) =>
      oldDelegate.color != color;
}
