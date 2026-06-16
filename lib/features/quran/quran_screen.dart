// lib/features/quran/quran_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/ask_iman_app_bar.dart';
import 'tabs/talawat_tab.dart';
import 'tabs/translation_tab.dart';
import 'tabs/tafseer_tab.dart';
import 'tabs/ayah_tab.dart';
import 'tabs/ahadees_tab.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});
  
  static final GlobalKey<QuranScreenState> screenKey = GlobalKey<QuranScreenState>();
  
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

  void showPreferencesAutomatically() {
    if (!_hasShownInitialPrefs) {
      _hasShownInitialPrefs = true;
      _showInitialPreferences();
    }
  }

  static const List<Map<String, String>> _fontOptions = [
    {'name': 'Indo-Pak (Al Qalam)', 'fontFamily': 'AlQalam'},
    {'name': 'Uthmani (Amiri)', 'fontFamily': 'Amiri'},
    {'name': 'Modern (Cairo)', 'fontFamily': 'Cairo'},
    {'name': 'Urdu (Noto)', 'fontFamily': 'NotoNastaliq'},
  ];

  static const _tabs = [
    'Talawat', 'Tarjuma', 'Tafseer', 'Ayat', 'Ahadees',
  ];

  @override
  void initState() {
    super.initState();
    _tc = TabController(length: _tabs.length, vsync: this);
    _tc.addListener(() => setState(() {}));
    _checkFirstTime();
  }

  Future<void> _checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load saved preferences
    setState(() {
      _selectedFont = prefs.getString('quran_font') ?? 'Amiri';
      _useUrduTranslation = prefs.getBool('quran_urdu') ?? false;
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('quran_font', _selectedFont);
    await prefs.setBool('quran_urdu', _useUrduTranslation);
  }

  void _showInitialPreferences() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
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
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text('Quran Settings', 
                style: TextStyle(
                  fontFamily: 'Cairo', 
                  fontSize: 22, 
                  fontWeight: FontWeight.w800, 
                  color: AppColors.primaryDark
                )
              ),
              const SizedBox(height: 24),
              const Text('Arabic Font Style', 
                style: TextStyle(
                  fontFamily: 'Cairo', 
                  fontSize: 16, 
                  fontWeight: FontWeight.w700,
                  color: AppColors.textGrey
                )
              ),
              const SizedBox(height: 16),
              // Font Preview Line
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.bgCream,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
                ),
                child: Center(
                  child: Text(
                    'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: _selectedFont,
                      fontSize: 24,
                      color: AppColors.primaryDark,
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
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSel ? AppColors.gold : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isSel ? AppColors.gold : Colors.grey[300]!),
                      ),
                      child: Text(
                        f['name']!,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.w600,
                          color: isSel ? Colors.white : AppColors.textDark,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              if (_tc.index == 1 || _tc.index == 2 || _tc.index == 4) ...[
                const Text('Translation Language', 
                  style: TextStyle(
                    fontFamily: 'Cairo', 
                    fontSize: 16, 
                    fontWeight: FontWeight.w700,
                    color: AppColors.textGrey
                  )
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildLanguageBtn(
                      label: 'English',
                      isSel: !_useUrduTranslation,
                      onTap: () {
                        setDialogState(() => _useUrduTranslation = false);
                        setState(() {});
                        _savePreferences();
                      },
                    ),
                    const SizedBox(width: 12),
                    _buildLanguageBtn(
                      label: 'Urdu',
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
                    backgroundColor: AppColors.primaryDark,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('START READING', 
                    style: TextStyle(
                      fontFamily: 'Cairo', 
                      fontSize: 16, 
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    )
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageBtn({required String label, required bool isSel, required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSel ? AppColors.gold : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSel ? AppColors.gold : Colors.grey[300]!),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w600,
                color: isSel ? Colors.white : AppColors.textDark,
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

  String get _searchHint {
    switch (_tc.index) {
      case 0: return 'Search Surah or Juz...';
      case 1: return 'Search Surah or Juz...';
      case 2: return 'Search Surah...';
      case 3: return 'Search Ayah by topic...';
      case 4: return 'Search Hadith or topic...';
      default: return 'Search...';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildTabBar(),
          Expanded(
            child: Container(
              color: Colors.white,
              child: TabBarView(
                controller: _tc,
                physics: const BouncingScrollPhysics(),
                children: [
                  TalawatTab(searchQuery: _searchQuery, useUrduFont: _useUrduTranslation, arabicFont: _selectedFont),
                  TranslationTab(searchQuery: _searchQuery, useUrduFont: _useUrduTranslation, arabicFont: _selectedFont),
                  TafseerTab(searchQuery: _searchQuery, useUrduFont: _useUrduTranslation, arabicFont: _selectedFont),
                  AyahTab(searchQuery: _searchQuery, useUrduFont: _useUrduTranslation, arabicFont: _selectedFont),
                  AhadeesTab(searchQuery: _searchQuery, arabicFont: _selectedFont, useUrduFont: _useUrduTranslation),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AskImanAppBar(
      showBackButton: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: Colors.white),
          onPressed: _showInitialPreferences,
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: AppColors.primaryDark,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(25),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (v) => setState(() => _searchQuery = v),
          style: const TextStyle(color: Colors.white, fontFamily: 'Cairo'),
          decoration: InputDecoration(
            hintText: _searchHint,
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6),
                fontFamily: 'Cairo', fontSize: 14),
            prefixIcon: Icon(Icons.search, color: Colors.white.withValues(alpha: 0.8)),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TabBar(
        controller: _tc,
        isScrollable: true,
        indicatorColor: AppColors.primaryDark,
        indicatorWeight: 3,
        labelColor: AppColors.primaryDark,
        unselectedLabelColor: Colors.grey[600],
        labelStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w500),
        tabs: _tabs.map((t) => Tab(text: t)).toList(),
      ),
    );
  }
}
