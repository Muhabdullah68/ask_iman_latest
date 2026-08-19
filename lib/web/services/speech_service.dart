// lib/web/services/speech_service.dart
// ─────────────────────────────────────────────────────────────────────────────
// ASK IMAN WEBSITE — Speech service facade (conditional import)
//
// On the web this uses the browser's speechSynthesis; on native platforms it
// is a silent no-op. Import this file anywhere in the website.
// ─────────────────────────────────────────────────────────────────────────────

import 'speech_service_stub.dart'
    if (dart.library.html) 'speech_service_web.dart' as impl;

/// True when the current platform can speak (web with speechSynthesis).
bool get speechSupported => impl.isSpeechSupported;

/// Pre-load the Arabic voice list (call once at app startup on web).
void ensureSpeechVoices() => impl.ensureSpeechVoices();

/// Speak [text]; [onEnd] fires when the utterance finishes or errors.
void speakText(String text, {void Function()? onEnd}) {
  impl.speakText(text, onEnd: onEnd);
}

/// Cancel any in-progress utterance.
void stopSpeech() => impl.stopSpeech();

void pauseSpeech() => impl.pauseSpeech();

void resumeSpeech() => impl.resumeSpeech();
