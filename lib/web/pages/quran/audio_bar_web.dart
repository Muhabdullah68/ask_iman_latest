// lib/web/pages/quran/audio_bar_web.dart
// ─────────────────────────────────────────────────────────────────────────────
// ASK IMAN WEBSITE — STICKY QURAN AUDIO BAR
//
// A slim player pinned to the bottom of the Quran Explorer. It listens to the
// shared [QuranAudioService] singleton so any pane (surah, juzz, ayah) keeps
// the bar and its playback state in sync. Hidden until something plays.
//
// Spec: Back/Play/Forward controls, progress bar, speed chip, scroll-to-bottom.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../core/services/quran_audio_service.dart';
import '../../../core/theme/figma_tokens.dart';
import '../../../features/quran/data/surahs_data.dart';

class QuranAudioBar extends StatelessWidget {
  const QuranAudioBar({super.key});

  String _labelFor(QuranAudioService audio) {
    final id = audio.currentId;
    if (id == null) return 'Recitation';
    if (id.startsWith('surah_')) {
      final n = int.tryParse(id.substring(6)) ?? 0;
      if (n > 0 && n <= SurahsData.surahs.length) {
        return 'Surah ${SurahsData.surahs[n - 1]['name']}';
      }
      return 'Surah $n';
    }
    if (id.startsWith('juz_')) return 'Juz ${id.substring(4)}';
    return 'Recitation';
  }

  @override
  Widget build(BuildContext context) {
    final audio = QuranAudioService();
    return ListenableBuilder(
      listenable: audio,
      builder: (context, _) {
        final active = audio.currentId != null || audio.isPlaying;
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: active
              ? _Bar(audio: audio, label: _labelFor(audio))
              : const SizedBox.shrink(),
        );
      },
    );
  }
}

class _Bar extends StatefulWidget {
  final QuranAudioService audio;
  final String label;
  const _Bar({required this.audio, required this.label});

  @override
  State<_Bar> createState() => _BarState();
}

class _BarState extends State<_Bar> {
  double _speed = 1.0;
  static const _speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  void _cycleSpeed() {
    final idx = _speeds.indexOf(_speed);
    setState(() {
      _speed = _speeds[(idx + 1) % _speeds.length];
    });
    widget.audio.player.setSpeed(_speed);
  }

  @override
  Widget build(BuildContext context) {
    final audio = widget.audio;
    final player = audio.player;
    return Container(
      key: ValueKey('audio-bar-${widget.label}'),
      decoration: const BoxDecoration(
        color: FigmaTokens.brandDeepGreen,
        boxShadow: [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 24,
            offset: Offset(0, -6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1180),
            child: Row(
              children: [
                // Back skip
                IconButton(
                  onPressed: () => audio.previous(),
                  icon: const Icon(
                    Icons.skip_previous_rounded,
                    color: FigmaTokens.accentGoldLight,
                    size: 28,
                  ),
                  tooltip: 'Previous',
                ),
                const SizedBox(width: 4),
                // Play / Pause
                ListenableBuilder(
                  listenable: audio,
                  builder: (context, _) => IconButton(
                    onPressed: () => audio.togglePause(),
                    icon: Icon(
                      audio.isPlaying
                          ? Icons.pause_circle_filled_rounded
                          : Icons.play_circle_filled_rounded,
                      color: FigmaTokens.accentGoldLight,
                      size: 38,
                    ),
                    tooltip: audio.isPlaying ? 'Pause' : 'Play',
                  ),
                ),
                const SizedBox(width: 4),
                // Forward skip
                IconButton(
                  onPressed: () => audio.next(),
                  icon: const Icon(
                    Icons.skip_next_rounded,
                    color: FigmaTokens.accentGoldLight,
                    size: 28,
                  ),
                  tooltip: 'Next',
                ),
                const SizedBox(width: 12),
                // Title + reciter
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: FigmaTokens.fontFamilyDisplaySerif,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: FigmaTokens.textOnDark,
                        ),
                      ),
                      Text(
                        'Recitation \u2014 Mishary Rashid',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: FigmaTokens.fontFamilyUiSans,
                          fontSize: 12,
                          color: FigmaTokens.accentGoldLight.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Progress bar
                Expanded(
                  flex: 3,
                  child: StreamBuilder<Duration?>(
                    stream: player.durationStream,
                    builder: (context, dur) {
                      final total = dur.data ?? Duration.zero;
                      return StreamBuilder<Duration>(
                        stream: player.positionStream,
                        builder: (context, pos) {
                          final position = pos.data ?? Duration.zero;
                          final max = total.inMilliseconds.toDouble();
                          return SliderTheme(
                            data: SliderThemeData(
                              trackHeight: 4,
                              activeTrackColor: FigmaTokens.accentGoldAmber,
                              inactiveTrackColor:
                                  Colors.white.withValues(alpha: 0.16),
                              thumbColor: FigmaTokens.accentGoldLight,
                              overlayColor:
                                  FigmaTokens.accentGoldAmber.withValues(alpha: 0.16),
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 7,
                              ),
                            ),
                            child: Slider(
                              value: max > 0
                                  ? position.inMilliseconds
                                          .toDouble()
                                          .clamp(0, max)
                                  : 0,
                              max: max > 0 ? max : 1,
                              onChanged: (v) {
                                if (total != Duration.zero) {
                                  player.seek(Duration(
                                    milliseconds: v.round(),
                                  ));
                                }
                              },
                              onChangeEnd: (v) {
                                if (total != Duration.zero) {
                                  player.seek(Duration(
                                    milliseconds: v.round(),
                                  ));
                                }
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                // Speed chip
                InkWell(
                  onTap: _cycleSpeed,
                  borderRadius: BorderRadius.circular(FigmaTokens.radiusPill),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: FigmaTokens.brandMidGreen,
                      borderRadius:
                          BorderRadius.circular(FigmaTokens.radiusPill),
                    ),
                    child: Text(
                      '${_speed}x',
                      style: const TextStyle(
                        fontFamily: FigmaTokens.fontFamilyUiSans,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: FigmaTokens.textOnDark,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Scroll to bottom
                IconButton(
                  onPressed: () {
                    final scrollCtrl = PrimaryScrollController.of(context);
                    scrollCtrl.animateTo(
                      scrollCtrl.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOut,
                    );
                  },
                  icon: const Icon(
                    Icons.vertical_align_bottom_rounded,
                    color: FigmaTokens.textOnDark,
                    size: 20,
                  ),
                  tooltip: 'Scroll to bottom',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
