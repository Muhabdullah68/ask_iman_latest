// lib/web/services/speech_service_stub.dart
// ─────────────────────────────────────────────────────────────────────────────
// ASK IMAN WEBSITE — Speech service (non-web fallback)
//
// Used on native platforms where the Web Speech API is unavailable. All calls
// are silent no-ops so the website never depends on TTS availability.
// ─────────────────────────────────────────────────────────────────────────────

bool get isSpeechSupported => false;

void ensureSpeechVoices() {}

void speakText(String text, {void Function()? onEnd}) {
  onEnd?.call();
}

void stopSpeech() {}

void pauseSpeech() {}

void resumeSpeech() {}
