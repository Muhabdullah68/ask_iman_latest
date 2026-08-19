// lib/web/pages/quran/settings_web.dart
// ─────────────────────────────────────────────────────────────────────────────
// ASK IMAN WEBSITE — QURAN · SETTINGS (TYPE/SETTINGS TAB)
//
// Quran reading preferences: Arabic font picker, translation language,
// and display density — styled per Figma design tokens.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../core/theme/figma_tokens.dart';
import 'quran_web_widgets.dart';

class QuranSettingsWeb extends StatefulWidget {
  const QuranSettingsWeb({super.key});

  @override
  State<QuranSettingsWeb> createState() => _QuranSettingsWebState();
}

class _QuranSettingsWebState extends State<QuranSettingsWeb> {
  String _font = 'Amiri Quran (Uthmani)';
  String _lang = 'English';
  String _density = 'Comfortable';

  static const _fonts = [
    'Amiri Quran (Uthmani)',
    'KFGQPC Uthman Taha',
    'Scheherazade New',
    'Amiri (Naskh)',
    'Noto Naskh Arabic',
  ];

  static const _languages = ['English', 'Urdu'];
  static const _densities = ['Compact', 'Comfortable', 'Spacious'];

  @override
  Widget build(BuildContext context) {
    return QuranPaneScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reading Settings',
            style: TextStyle(
              fontFamily: FigmaTokens.fontFamilyDisplaySerif,
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: FigmaTokens.textHeading,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Customize how the Qur\'ān appears to you.',
            style: TextStyle(
              fontFamily: FigmaTokens.fontFamilyUiSans,
              fontSize: 14.5,
              color: FigmaTokens.textBody,
            ),
          ),
          const SizedBox(height: 28),
          _SettingsSection(
            title: 'Arabic Font',
            child: Column(
              children: [
                for (final f in _fonts)
                  _FontPreviewTile(
                    font: f,
                    selected: f == _font,
                    onTap: () => setState(() => _font = f),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SettingsSection(
            title: 'Translation Language',
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final l in _languages)
                  _SettingsPill(
                    label: l,
                    selected: l == _lang,
                    onTap: () => setState(() => _lang = l),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SettingsSection(
            title: 'Display Density',
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final d in _densities)
                  _SettingsPill(
                    label: d,
                    selected: d == _density,
                    onTap: () => setState(() => _density = d),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final Widget child;
  const _SettingsSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: FigmaTokens.surfaceCard,
        borderRadius: BorderRadius.circular(FigmaTokens.radiusCard),
        border: Border.all(color: FigmaTokens.borderHairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: FigmaTokens.fontFamilyUiSans,
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: FigmaTokens.textHeading,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _FontPreviewTile extends StatelessWidget {
  final String font;
  final bool selected;
  final VoidCallback onTap;
  const _FontPreviewTile({
    required this.font,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected ? FigmaTokens.surfacePanelMint : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FigmaTokens.radiusButton),
          side: BorderSide(
            color: selected
                ? FigmaTokens.brandMidGreen
                : FigmaTokens.borderHairline,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(FigmaTokens.radiusButton),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                if (selected)
                  const Icon(Icons.check_circle_rounded, size: 20, color: FigmaTokens.brandMidGreen)
                else
                  Icon(Icons.circle_outlined, size: 20, color: FigmaTokens.textMuted),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        font,
                        style: TextStyle(
                          fontFamily: FigmaTokens.fontFamilyUiSans,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: selected ? FigmaTokens.brandMidGreen : FigmaTokens.textHeading,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ',
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontFamily: FigmaTokens.fontFamilyArabicSerif,
                          fontSize: 18,
                          color: FigmaTokens.textHeading.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _SettingsPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? FigmaTokens.brandMidGreen : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FigmaTokens.radiusPill),
        side: BorderSide(
          color: selected
              ? FigmaTokens.brandMidGreen
              : FigmaTokens.borderHairline,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(FigmaTokens.radiusPill),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: FigmaTokens.fontFamilyUiSans,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: selected ? FigmaTokens.textOnDark : FigmaTokens.textBody,
            ),
          ),
        ),
      ),
    );
  }
}
