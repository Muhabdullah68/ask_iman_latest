// lib/web/services/speech_service_web.dart
// ─────────────────────────────────────────────────────────────────────────────
// ASK IMAN WEBSITE — Speech service (Web Speech API)
//
// Uses the browser's native speechSynthesis with a preferred Arabic voice to
// recite the 99 Names of Allah. No network required; voice availability
// depends on the visitor's browser/OS.
// ─────────────────────────────────────────────────────────────────────────────

// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:html' as html;

bool get isSpeechSupported => true;

html.SpeechSynthesis? _synth() {
  try {
    return html.window.speechSynthesis;
  } catch (_) {
    return null;
  }
}

html.SpeechSynthesisVoice? _arabicVoice;

/// Warm up the voice list (voices load asynchronously on some browsers).
void ensureSpeechVoices() {
  final s = _synth();
  if (s == null) return;
  try {
    _refreshArabicVoice(s);
    s.addEventListener(
      'voiceschanged',
      (html.Event _) => _refreshArabicVoice(s),
    );
  } catch (_) {}
}

void _refreshArabicVoice(html.SpeechSynthesis s) {
  try {
    final voices = s.getVoices();
    if (voices.isEmpty) return;
    _arabicVoice ??= voices.firstWhere(
      (v) => (v.lang ?? '').toLowerCase().startsWith('ar'),
      orElse: () => voices.first,
    );
  } catch (_) {}
}

void speakText(String text, {void Function()? onEnd}) {
  final s = _synth();
  if (s == null) {
    onEnd?.call();
    return;
  }
  try {
    ensureSpeechVoices();
    s.cancel();
    final u = html.SpeechSynthesisUtterance(text);
    if (_arabicVoice != null) {
      u.voice = _arabicVoice;
      u.lang = _arabicVoice!.lang ?? 'ar';
    } else {
      u.lang = 'ar';
    }
    u.rate = 0.7;
    u.pitch = 1.0;
    u.addEventListener('end', (html.Event _) => onEnd?.call());
    u.addEventListener('error', (html.Event _) => onEnd?.call());
    s.speak(u);
  } catch (_) {
    onEnd?.call();
  }
}

void stopSpeech() {
  _synth()?.cancel();
}

void pauseSpeech() {
  _synth()?.pause();
}

void resumeSpeech() {
  _synth()?.resume();
}
