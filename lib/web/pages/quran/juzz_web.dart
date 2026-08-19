// lib/web/pages/quran/juzz_web.dart
// ─────────────────────────────────────────────────────────────────────────────
// ASK IMAN WEBSITE — QURAN · JUZZ (SUB-VIEW)
//
// Now a sub-view rendered inside the Talawat tab when JUZ mode is active via
// the toggle pill. No longer a standalone top-level tab.
// Read by the thirty ajz\u0101' (parts): pick a juz, then read each surah in that
// juz with Arabic, translation and per-ayah audio.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../core/services/quran_audio_service.dart';
import '../../../core/theme/figma_tokens.dart';
import '../../../features/quran/data/quran_api_service.dart';
import 'quran_web_widgets.dart';

class JuzzWeb extends StatefulWidget {
  const JuzzWeb({super.key});

  @override
  State<JuzzWeb> createState() => _JuzzWebState();
}

class _JuzzWebState extends State<JuzzWeb> {
  int? _selected;
  List<JuzSurahGroup>? _groups;
  bool _loading = false;
  bool _urdu = false;

  Future<void> _load(int juz) async {
    setState(() {
      _selected = juz;
      _loading = true;
      _groups = null;
    });
    final data = await QuranApiService.fetchJuz(juz);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _groups = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _selected == null ? _buildGrid(context) : _buildReader(context);
  }

  Widget _buildGrid(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Read by Juz',
          style: TextStyle(
            fontFamily: FigmaTokens.fontFamilyDisplaySerif,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: FigmaTokens.textHeading,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'The Qur\u0101n is divided into 30 ajz\u0101\u2019. Pick a juz to read its surahs continuously.',
          style: TextStyle(
            fontFamily: FigmaTokens.fontFamilyUiSans,
            fontSize: 14,
            color: FigmaTokens.textBody,
          ),
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final cols = constraints.maxWidth >= 900
                ? 5
                : constraints.maxWidth >= 620
                    ? 4
                    : constraints.maxWidth >= 420
                        ? 3
                        : 2;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 30,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: cols >= 4 ? 0.9 : 1.2,
              ),
              itemBuilder: (context, i) => _JuzCard(
                juz: i + 1,
                onTap: () => _load(i + 1),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildReader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () => setState(() {
                _selected = null;
                _groups = null;
              }),
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text('All Juz'),
              style: OutlinedButton.styleFrom(
                foregroundColor: FigmaTokens.brandMidGreen,
                side: BorderSide(
                  color: FigmaTokens.brandMidGreen.withValues(alpha: 0.5),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(FigmaTokens.radiusButton),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Juz $_selected',
                style: const TextStyle(
                  fontFamily: FigmaTokens.fontFamilyDisplaySerif,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: FigmaTokens.textHeading,
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _MiniPill(
                  label: 'EN',
                  selected: !_urdu,
                  onTap: () => setState(() => _urdu = false),
                ),
                const SizedBox(width: 4),
                _MiniPill(
                  label: '\u0627\u0631\u062f\u0648',
                  selected: _urdu,
                  onTap: () => setState(() => _urdu = true),
                ),
              ],
            ),
            if (_selected != null) ...[
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: () => QuranAudioService().playJuzz(
                  _selected!,
                  '$_selected',
                  (_groups ?? []).map((g) => g.surahNum).toList(),
                ),
                icon: const Icon(Icons.play_arrow_rounded, size: 18),
                label: Text('Play Juz $_selected'),
                style: FilledButton.styleFrom(
                  backgroundColor: FigmaTokens.brandMidGreen,
                  foregroundColor: FigmaTokens.textOnDark,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(FigmaTokens.radiusButton),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        if (_loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_groups == null)
          const _JuzzError()
        else
          for (final group in _groups!)
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: FigmaTokens.surfacePanelMint,
                      borderRadius: BorderRadius.circular(
                        FigmaTokens.radiusCardSm,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${group.surahNum}. ${group.surahName}',
                            style: const TextStyle(
                              fontFamily: FigmaTokens.fontFamilyDisplaySerif,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: FigmaTokens.textHeading,
                            ),
                          ),
                        ),
                        Text(
                          group.surahArabic,
                          style: const TextStyle(
                            fontFamily: FigmaTokens.fontFamilyArabicSerif,
                            fontSize: 19,
                            color: FigmaTokens.brandDeepGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  for (final a in group.ayahs)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: AyahCard(
                        surahNum: group.surahNum,
                        ayahNum: int.parse(a['num']!),
                        arabic: a['a']!,
                        translation:
                            _urdu ? (a['tu'] ?? a['t']!) : a['t']!,
                        urdu: _urdu,
                      ),
                    ),
                ],
              ),
            ),
      ],
    );
  }
}

class _JuzCard extends StatelessWidget {
  final int juz;
  final VoidCallback onTap;
  const _JuzCard({required this.juz, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: FigmaTokens.surfaceCard,
      borderRadius: BorderRadius.circular(FigmaTokens.radiusCard),
      child: InkWell(
        onTap: onTap,
        hoverColor: FigmaTokens.surfacePanelMint,
        borderRadius: BorderRadius.circular(FigmaTokens.radiusCard),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(FigmaTokens.radiusCard),
            border: Border.all(color: FigmaTokens.borderHairline),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: FigmaTokens.primaryButtonGradient,
                ),
                child: Text(
                  '$juz',
                  style: const TextStyle(
                    fontFamily: FigmaTokens.fontFamilyDisplaySerif,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: FigmaTokens.accentGoldLight,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Juz $juz',
                style: const TextStyle(
                  fontFamily: FigmaTokens.fontFamilyUiSans,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: FigmaTokens.textHeading,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _MiniPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(FigmaTokens.radiusPill),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? FigmaTokens.brandMidGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(FigmaTokens.radiusPill),
          border: Border.all(
            color: selected
                ? FigmaTokens.brandMidGreen
                : FigmaTokens.brandMidGreen.withValues(alpha: 0.4),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: FigmaTokens.fontFamilyUiSans,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: selected
                ? FigmaTokens.textOnDark
                : FigmaTokens.brandMidGreen,
          ),
        ),
      ),
    );
  }
}

class _JuzzError extends StatelessWidget {
  const _JuzzError();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: FigmaTokens.surfaceCard,
        borderRadius: BorderRadius.circular(FigmaTokens.radiusCard),
      ),
      child: const Column(
        children: [
          Icon(Icons.cloud_off_rounded, size: 40, color: FigmaTokens.textMuted),
          SizedBox(height: 12),
          Text(
            'Could not load this juz. Check your connection and try again.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: FigmaTokens.fontFamilyUiSans,
              fontSize: 14,
              color: FigmaTokens.textBody,
            ),
          ),
        ],
      ),
    );
  }
}
