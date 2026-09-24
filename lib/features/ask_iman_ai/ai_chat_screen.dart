// lib/features/ask_iman_ai/ai_chat_screen.dart
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:just_audio/just_audio.dart';
import 'package:record/record.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/services/ask_iman_ai_service.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/ask_iman_app_bar.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key, this.initialLang});

  final String? initialLang;

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _ChatMessage {
  final String role; // 'user' | 'ai'
  final String text;
  final String verdict;
  final String type;
  final String errorCode;
  final List<AskAICitation> citations;
  final int ts;
  /// OCR'd text from a photo message (ayah/hadith); null for typed messages.
  final String? ocrText;
  /// Path to the recorded voice note (.m4a) this message was spoken from; the
  /// transcript lives in [text]. Null for typed / photo messages.
  final String? audioPath;
  /// Playback length of the recorded voice note.
  final int audioDurationMs;

  const _ChatMessage({
    required this.role,
    required this.text,
    this.verdict = '',
    this.type = '',
    this.errorCode = '',
    this.citations = const [],
    this.ts = 0,
    this.ocrText,
    this.audioPath,
    this.audioDurationMs = 0,
  });

  bool get isError => errorCode.isNotEmpty;

  bool get isRetryable {
    const nonRetryable = {
      'daily_limit', 'ai_not_configured', 'empty_input', 'too_long', 'ocr_failed',
    };
    return errorCode.isNotEmpty && !nonRetryable.contains(errorCode);
  }

  factory _ChatMessage.fromJson(Map<String, dynamic> j) => _ChatMessage(
        role: j['role'] as String? ?? 'ai',
        text: j['text'] as String? ?? '',
        verdict: j['verdict'] as String? ?? '',
        type: j['type'] as String? ?? '',
        errorCode: j['errorCode'] as String? ?? '',
        citations: ((j['citations'] as List?) ?? [])
            .whereType<Map>()
            .map((e) => AskAICitation.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        ts: j['ts'] as int? ?? 0,
        ocrText: j['ocrText'] as String?,
        audioPath: j['audioPath'] as String?,
        audioDurationMs: j['audioDurationMs'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'role': role,
        'text': text,
        'verdict': verdict,
        'type': type,
        'errorCode': errorCode,
        'citations': citations.map((c) => c.toJson()).toList(),
        'ts': ts,
        'ocrText': ocrText,
        'audioPath': audioPath,
        'audioDurationMs': audioDurationMs,
      };
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  late String _lang;
  final List<_ChatMessage> _messages = [];
  bool _busy = false;
  bool _transcribing = false;
  AiPhase? _phase;
  int _generation = 0;
  /// Set by the stop button; the in-flight round unwinds at the next safe
  /// stage boundary (after OCR / transcription / answer) and the pending
  /// answer is discarded.
  bool _stopRequested = false;
  /// Image staged in the composer; it is sent together with the typed text and
  /// OCR'd in the background on send (ChatGPT-style, no preview step).
  XFile? _attachedImage;

  // Voice-note recording state (tap mic = record, long-press = dictate).
  AudioRecorder? _recorder;
  String? _recordingPath;
  bool _recording = false;
  Duration _recElapsed = Duration.zero;
  Timer? _recTimer;

  @override
  void initState() {
    super.initState();
    _lang = (widget.initialLang == 'ur' || widget.initialLang == 'ps')
        ? widget.initialLang!
        : 'en';
    _loadHistory();
  }

  @override
  void dispose() {
    _recTimer?.cancel();
    _recTimer = null;
    final recorder = _recorder;
    final path = _recordingPath;
    if (recorder != null) {
      // Abandon an in-flight recording: stop it and drop the file so nothing
      // leaks on a mid-recording screen close.
      unawaited(() async {
        try {
          await recorder.stop();
          final f = File(path ?? '');
          if (f.path.isNotEmpty && await f.exists()) await f.delete();
        } catch (e) {
          debugPrint('AI: mic dispose cleanup error: $e');
        }
      }());
    }
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final history = await AskImanAiService.loadHistory();
    if (history == null || !mounted) return;
    setState(() {
      _messages
        ..clear()
        ..addAll(history.map(_ChatMessage.fromJson));
    });
    _scrollToBottom(instant: true);
  }

  void _persist() {
    try {
      unawaited(AskImanAiService.saveHistory(
              _messages.map((m) => m.toJson()).toList())
          .catchError((e) {
        debugPrint('AI: history save failed: $e');
      }));
    } catch (e) {
      debugPrint('AI: history encode failed: $e');
    }
  }

  void _scrollToBottom({bool instant = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!_scrollController.hasClients) return;
      final target = _scrollController.position.maxScrollExtent;
      if (instant) {
        _scrollController.jumpTo(target);
      } else {
        _scrollController.animateTo(
          target,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send(String raw) async {
    final text = raw.trim();
    final image = _attachedImage;
    if ((text.isEmpty && image == null) || _busy) return;
    setState(() {
      _messages.add(_ChatMessage(
        role: 'user',
        text: text.isEmpty ? '[Photo]' : text,
        ts: _now(),
      ));
      _busy = true;
    });
    _controller.clear();
    _focusNode.unfocus();
    _persist();
    _scrollToBottom();
    final gen = ++_generation;
    await _runAnswer(text, imageFile: image, generation: gen);
    // Image consumed — clear the attachment after the round-trip.
    if (mounted && identical(_attachedImage, image)) {
      setState(() => _attachedImage = null);
    }
  }

  /// Marker used in the user bubble so a photo message is transparent; kept
  /// deterministic so retry can split question vs OCR text again.
  static const _photoMarker = '\n\n[From photo] ';

  Future<void> _retryFailed(int aiIndex) async {
    if (_busy) return;
    // Guard against a stale index captured by the build (list may have been
    // replaced by history reload) — an out-of-range removeAt would crash.
    if (aiIndex < 0 || aiIndex >= _messages.length) return;
    _ChatMessage? userMsg;
    for (var k = aiIndex - 1; k >= 0; k--) {
      if (_messages[k].role == 'user') {
        userMsg = _messages[k];
        break;
      }
    }
    if (userMsg == null) return;
    setState(() {
      _messages.removeAt(aiIndex);
      _busy = true;
    });
    if (userMsg.audioPath != null && userMsg.audioPath!.isNotEmpty) {
      // Voice note: the transcript lives in the user bubble, but re-running
      // transcription is safer than trusting it — the audio persists on disk.
      final gen = ++_generation;
      await _runAnswer('', audioPath: userMsg.audioPath, generation: gen);
      return;
    }
    // Split the bubble back into question + OCR text (photo messages keep the
    // OCR text in `ocrText`, so only the typed question is re-sent as text).
    String question;
    if (userMsg.ocrText != null && userMsg.text == userMsg.ocrText) {
      question = '';
    } else {
      final i = userMsg.text.lastIndexOf(_photoMarker);
      question = i >= 0 ? userMsg.text.substring(0, i) : userMsg.text;
    }
    final gen = ++_generation;
    await _runAnswer(question, ocrText: userMsg.ocrText, generation: gen);
  }

  Future<void> _runAnswer(String text,
      {String? ocrText, XFile? imageFile, String? audioPath, int? generation}) async {
    // A newer round took over: this (older) one must not mutate the chat.
    bool stale() => generation != null && generation != _generation;
    // A fresh round clears any pending stop request.
    _stopRequested = false;
    try {
      // Fresh photo: run OCR (Gemini Vision → ML Kit fallback) in the
      // background so the user bubble shows exactly what was read and the
      // answer is grounded on it. Retries skip this (ocrText already saved).
      if (imageFile != null && ocrText == null) {
        if (mounted && !stale()) setState(() => _phase = AiPhase.reading);
        final extracted =
            (await AskImanAiService.extractTextFromImage(imageFile)).trim();
        if (!mounted || stale()) return;
        if (_stopRequested) {
          _addStoppedNotice();
          return;
        }
        final last = _messages.isNotEmpty ? _messages.last : null;
        if (extracted.isEmpty) {
          setState(() {
            if (last != null && last.role == 'user') {
              _messages[_messages.length - 1] = _ChatMessage(
                role: 'user',
                text: '[Photo]',
                ocrText: '',
                ts: last.ts,
              );
            }
            _messages.add(_ChatMessage(
              role: 'ai',
              text: AppLocalizations.of(context).translate('aiOcrFailed'),
              verdict: 'refused',
              type: 'general_qna',
              errorCode: 'ocr_failed',
              ts: _now(),
            ));
            _busy = false;
            _phase = null;
          });
          _persist();
          _scrollToBottom();
          return;
        }
        if (last != null && last.role == 'user') {
          setState(() {
            _messages[_messages.length - 1] = _ChatMessage(
              role: 'user',
              text: text.isEmpty ? extracted : '$text$_photoMarker$extracted',
              ocrText: extracted,
              ts: last.ts,
            );
          });
        }
        ocrText = extracted;
      }

      // Fresh voice note: transcribe first (Gemini audio understanding handles
      // English / Urdu / Arabic), then the grounded pipeline answers it like a
      // typed question. Retries re-run transcription — the audio persists.
      String effectiveText = text;
      if (audioPath != null && audioPath.isNotEmpty) {
        if (mounted && !stale()) setState(() => _phase = AiPhase.transcribing);
        final transcript =
            (await AskImanAiService.transcribeAudio(audioPath)).trim();
        if (!mounted || stale()) return;
        if (_stopRequested) {
          _addStoppedNotice();
          return;
        }
        final last = _messages.isNotEmpty ? _messages.last : null;
        if (transcript.isEmpty) {
          setState(() {
            _messages.add(_ChatMessage(
              role: 'ai',
              text: AppLocalizations.of(context).translate('aiAudioFailed'),
              verdict: 'refused',
              type: 'general_qna',
              errorCode: 'audio_failed',
              ts: _now(),
            ));
            _busy = false;
            _phase = null;
          });
          _persist();
          _scrollToBottom();
          return;
        }
        // Surface the transcript in the user bubble so the exchange reads like
        // a typed question (and the grounded pipeline quotes it verbatim).
        if (last != null && last.role == 'user') {
          setState(() {
            _messages[_messages.length - 1] = _ChatMessage(
              role: 'user',
              text: transcript,
              audioPath: audioPath,
              audioDurationMs: last.audioDurationMs,
              ts: last.ts,
            );
          });
        }
        effectiveText = transcript;
      }

      final resp = await AskImanAiService.ask(
        text: effectiveText,
        lang: _lang,
        ocrText: ocrText,
        // Live progress: the typing row switches between read/corpus/verify/
        // think labels so a long retrieval never looks like a frozen app.
        onPhase: (p) {
          if (mounted && !stale()) setState(() => _phase = p);
        },
        // Multi-turn context: previous user/AI exchanges let follow-ups like
        // "why?" or "and what about salah?" build on the last answer.
        history: _messages.map((m) => m.toJson()).toList(),
      );
      if (!mounted || stale()) return;
      if (_stopRequested) {
        _addStoppedNotice();
        return;
      }
      setState(() {
        _messages.add(_ChatMessage(
          role: 'ai',
          text: resp.answer,
          verdict: resp.verdict,
          type: resp.type,
          errorCode: resp.errorCode ?? '',
          citations: resp.citations,
          ts: _now(),
        ));
      });
    } catch (e, st) {
      debugPrint('AI: _runAnswer error: $e\n$st');
      if (!mounted || stale()) return;
      setState(() {
        _messages.add(_ChatMessage(
          role: 'ai',
          text: AppLocalizations.of(context).translate('aiGenericError'),
          verdict: 'refused',
          type: 'general_qna',
          errorCode: 'ai_error',
          ts: _now(),
        ));
      });
    } finally {
      if (mounted && !stale()) {
        setState(() {
          _busy = false;
          _phase = null;
        });
        _persist();
        _scrollToBottom();
      }
    }
  }

  int _now() => DateTime.now().millisecondsSinceEpoch;

  bool _sameDay(int a, int b) {
    final da = DateTime.fromMillisecondsSinceEpoch(a);
    final db = DateTime.fromMillisecondsSinceEpoch(b);
    return da.year == db.year && da.month == db.month && da.day == db.day;
  }

  /// Stop button handler: flags the in-flight round so it unwinds at the next
  /// safe boundary; the pending answer is discarded (retryable).
  void _stopGeneration() {
    if (!_busy) return;
    setState(() => _stopRequested = true);
  }

  void _addStoppedNotice() {
    setState(() {
      _messages.add(_ChatMessage(
        role: 'ai',
        text: AppLocalizations.of(context).translate('aiStopped'),
        verdict: 'refused',
        type: 'general_qna',
        errorCode: 'stopped',
        ts: _now(),
      ));
    });
    _persist();
    _scrollToBottom();
  }

  /// Picks an image and stages it in the composer — the user can type a
  /// question (optional) and send BOTH together, ChatGPT-style. OCR happens in
  /// the background on send, not as a blocking preview step.
  Future<void> _handleImage(ImageSource source) async {
    try {
      // maxWidth/maxHeight normalise camera shots (full-res + EXIF rotation
      // break on-device OCR) and imageQuality keeps the Gemini payload small.
      final picker = ImagePicker();
      final file = await picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 90,
      );
      if (file == null || !mounted) return;
      setState(() => _attachedImage = file);
    } catch (e) {
      debugPrint('AI: image pick error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)
                .translate('aiImagePickError')),
            backgroundColor: AppColors.primaryDarkest,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _removeImage() {
    if (!mounted) return;
    setState(() => _attachedImage = null);
  }

  Future<void> _handleMic() async {
    if (_busy || _recording || _transcribing) return;
    try {
      final recorder = AudioRecorder();
      if (!await recorder.hasPermission()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context)
                .translate('aiMicPermission')),
            backgroundColor: AppColors.primaryDarkest,
            behavior: SnackBarBehavior.floating,
          ));
        }
        return;
      }
      final dir = await AskImanAiService.ensureVoiceNotesDir();
      final path = '$dir${Platform.pathSeparator}voice_'
          '${DateTime.now().millisecondsSinceEpoch}.m4a';
      await recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: path,
      );
      if (!mounted) {
        // Screen closed mid-start: stop + clean up instead of leaking a file.
        await recorder.stop();
        final f = File(path);
        if (await f.exists()) await f.delete();
        return;
      }
      setState(() {
        _recorder = recorder;
        _recordingPath = path;
        _recording = true;
        _recElapsed = Duration.zero;
      });
      _recTimer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted || !_recording) {
          t.cancel();
          return;
        }
        setState(() => _recElapsed += const Duration(seconds: 1));
        if (_recElapsed >= AskImanAiService.maxVoiceDuration) {
          // Hard cap reached — stop and let the user decide to send.
          unawaited(_stopRecording(send: false));
        }
      });
    } catch (e) {
      debugPrint('AI: mic start error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context)
              .translate('aiMicStartError')),
          backgroundColor: AppColors.primaryDarkest,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  Future<void> _stopRecording({required bool send}) async {
    _recTimer?.cancel();
    _recTimer = null;
    final recorder = _recorder;
    final path = _recordingPath;
    final duration = _recElapsed;
    if (recorder != null) {
      try {
        await recorder.stop();
      } catch (e) {
        debugPrint('AI: mic stop error: $e');
      }
    }
    if (!mounted) return;
    setState(() {
      _recorder = null;
      _recordingPath = null;
      _recording = false;
      _recElapsed = Duration.zero;
    });
    if (send && path != null) {
      await _sendVoice(path, duration);
    } else if (path != null) {
      // Cancel: drop the recorded file so it never accumulates in storage.
      try {
        final f = File(path);
        if (await f.exists()) await f.delete();
      } catch (e) {
        debugPrint('AI: voice cleanup error: $e');
      }
    }
  }

  /// Sends the finished voice note: a user bubble that will be filled with the
  /// transcript once Gemini understands it, then a grounded answer.
  Future<void> _sendVoice(String path, Duration duration) async {
    if (_busy) return;
    setState(() {
      _messages.add(_ChatMessage(
        role: 'user',
        text: '[Voice note]',
        audioPath: path,
        audioDurationMs: duration.inMilliseconds,
        ts: _now(),
      ));
      _busy = true;
    });
    _persist();
    _scrollToBottom();
    final gen = ++_generation;
    await _runAnswer('', audioPath: path, generation: gen);
  }

  /// Long-press action: live dictation straight into the composer.
  Future<void> _handleDictate() async {
    if (_busy || _recording || _transcribing) return;
    setState(() => _transcribing = true);
    String? words;
    try {
      words = await AskImanAiService.transcribe();
    } catch (e) {
      // Belt-and-suspenders: transcribe() already swallows errors, but a
      // platform-channel hiccup must never leave the mic stuck or unhandled.
      debugPrint('AI: mic transcription error: $e');
      words = null;
    } finally {
      if (mounted) {
        setState(() => _transcribing = false);
      } else {
        _transcribing = false;
      }
    }
    if (!mounted) return;
    if (words != null && words.isNotEmpty) {
      _controller.text = words;
    }
  }

  Future<void> _handleSuggestion(String s) => _send(s);

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AskImanAppBar(
        title: loc.translate('aiTitle'),
        showBackButton: true,
        actions: [
          TextButton(
            onPressed: () => setState(() => _lang = _lang == 'ur' ? 'en' : 'ur'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.gold,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            child: Text(
              _lang == 'ur' ? 'اردو' : 'EN',
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _DisclaimerStrip(text: loc.translate('aiDisclaimer')),
            Expanded(
              child: _messages.isEmpty && !_busy
                  ? _WelcomeView(
                      title: loc.translate('aiWelcomeTitle'),
                      subtitle: loc.translate('aiWelcomeSub'),
                      onSuggestion: _handleSuggestion,
                      notice: AskImanAiService.isConfigured
                          ? null
                          : loc.translate('aiNotConfiguredNotice'),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                      itemCount: _messages.length + (_busy ? 1 : 0),
                      itemBuilder: (context, i) {
                        if (i == _messages.length) {
                          return _TypeIndicator(phase: _phase);
                        }
                        final m = _messages[i];
                        final showDate =
                            i == 0 || !_sameDay(_messages[i - 1].ts, m.ts);
                        return Column(
                          children: [
                            if (showDate) _DateSeparator(ts: m.ts),
                            m.role == 'user'
                                ? _UserBubble(
                                    text: m.text,
                                    audioPath: m.audioPath,
                                    audioDurationMs: m.audioDurationMs,
                                  )
                                : _AiBubble(
                                    message: m,
                                    onCopy: _copyMessage,
                                    onRetry: m.isRetryable
                                        ? () => _retryFailed(i)
                                        : null,
                                  ),
                            _TimeLabel(ts: m.ts, alignEnd: m.role == 'user'),
                          ],
                        );
                      },
                    ),
            ),
            _buildInputBar(loc),
          ],
        ),
      ),
    );
  }

  void _copyMessage(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(const SnackBar(
        content: Text('Copied!'),
        backgroundColor: AppColors.primaryDarkest,
        duration: Duration(milliseconds: 900),
        behavior: SnackBarBehavior.floating,
      ));
  }

  Widget _buildInputBar(AppLocalizations loc) {
    final attach = _attachedImage;
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      decoration: const BoxDecoration(
        color: AppColors.bgWhite,
        border: Border(top: BorderSide(color: AppColors.borderLight)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (attach != null) ...[
            _AttachmentThumbnail(path: attach.path, onRemove: _removeImage),
            const SizedBox(height: 8),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (_recording) ...[
            Expanded(
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => _stopRecording(send: false),
                    behavior: HitTestBehavior.opaque,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                      child: Icon(Icons.close, color: AppColors.textDark, size: 26),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            AskImanAiService.formatDuration(_recElapsed),
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            loc.translate('aiRecording'),
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 13,
                              color: AppColors.textGrey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _stopRecording(send: true),
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppColors.primaryDark, AppColors.primaryMid],
                  ),
                ),
                child: const Icon(
                  Icons.check,
                  color: AppColors.textWhite,
                  size: 24,
                ),
              ),
            ),
          ] else ...[
            GestureDetector(
              onTap: _handleMic,
              onLongPress: _handleDictate,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10, left: 4, right: 4),
                child: Icon(
                  _transcribing ? Icons.graphic_eq : Icons.mic_none,
                  color: AppColors.textDark,
                  size: 26,
                ),
              ),
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: loc.translate('aiTypeMessage'),
                  hintStyle: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    color: AppColors.textLightGrey,
                  ),
                  filled: true,
                  fillColor: AppColors.bgCream,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  color: AppColors.textDark,
                ),
              ),
            ),
            _InputIcon(
              icon: Icons.photo_library_outlined,
              onTap: () => _handleImage(ImageSource.gallery),
            ),
            _InputIcon(
              icon: Icons.photo_camera_outlined,
              onTap: () => _handleImage(ImageSource.camera),
            ),
            const SizedBox(width: 2),
            if (_busy)
              GestureDetector(
                onTap: _stopGeneration,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppColors.primaryDark, AppColors.primaryMid],
                    ),
                  ),
                  child: const Icon(
                    Icons.stop_rounded,
                    color: AppColors.textWhite,
                    size: 24,
                  ),
                ),
              )
            else
              GestureDetector(
                onTap: () => _send(_controller.text),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppColors.primaryDark, AppColors.primaryMid],
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_upward_rounded,
                    color: AppColors.textWhite,
                    size: 22,
                  ),
                ),
              ),
            ],
          ],
        ),
        ],
      ),
    );
  }
}

// ── Small widgets ─────────────────────────────────────────────────────────â”€â”€
class _DisclaimerStrip extends StatelessWidget {
  final String text;
  const _DisclaimerStrip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      color: AppColors.goldSurface,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(Icons.info_outline, color: AppColors.goldDark, size: 15),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 11,
                color: AppColors.primaryDarkest,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomeView extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? notice;
  final Future<void> Function(String) onSuggestion;

  const _WelcomeView({
    required this.title,
    required this.subtitle,
    required this.onSuggestion,
    this.notice,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final suggestions = [
      loc.translate('aiSug1'),
      loc.translate('aiSug2'),
      loc.translate('aiSug3'),
    ];
    return ListView(
      children: [
        const SizedBox(height: 24),
        const Center(
          child: Icon(Icons.auto_awesome, color: AppColors.gold, size: 56),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryDark,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13,
                color: AppColors.textGrey,
              ),
            ),
          ),
        ),
        if (notice != null) ...[
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.warning),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      color: AppColors.warning, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      notice!,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12.5,
                        height: 1.4,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 24),
        for (final s in suggestions) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
            child: Material(
              color: AppColors.bgWhite,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => onSuggestion(s),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.help_outline,
                          color: AppColors.primaryMid, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          s,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _TypeIndicator extends StatelessWidget {
  /// Live progress label; null during the first instant of a reply and while
  /// the user is not waiting. Kept short — it sits inside the typing bubble.
  final AiPhase? phase;

  const _TypeIndicator({this.phase});

String? _label(BuildContext context) => switch (phase) {
        AiPhase.reading =>
          AppLocalizations.of(context).translate('aiPhaseReading'),
        AiPhase.transcribing =>
          AppLocalizations.of(context).translate('aiPhaseListening'),
        AiPhase.corpus =>
          AppLocalizations.of(context).translate('aiPhaseCorpus'),
        AiPhase.verifying =>
          AppLocalizations.of(context).translate('aiPhaseVerifying'),
        AiPhase.thinking =>
          AppLocalizations.of(context).translate('aiPhaseThinking'),
        null => null,
      };

  @override
  Widget build(BuildContext context) {
    final label = _label(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.bgWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.gold,
                  ),
                ),
                if (label != null) ...[
                  const SizedBox(width: 10),
                  Text(
                    label,
                    style: TextStyle(
                      color: context.textPrimary,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UserBubble extends StatelessWidget {
  final String text;
  final String? audioPath;
  final int audioDurationMs;
  const _UserBubble(
      {required this.text, this.audioPath, this.audioDurationMs = 0});

  @override
  Widget build(BuildContext context) {
    final audio = audioPath;
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(top: 6, bottom: 6, left: 40),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: const BoxDecoration(
          color: AppColors.primaryDark,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (audio != null && audio.isNotEmpty) ...[
              _VoiceBubble(
                path: audio,
                durationMs: audioDurationMs,
                color: AppColors.textWhite,
                accent: AppColors.gold,
              ),
              const SizedBox(height: 6),
            ],
            Text(
              text,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                color: AppColors.textWhite,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Playable recorded voice note shown inside a chat bubble. Uses just_audio so
/// the file plays on tap; the file persists in app-support so retry/history
/// still work after a restart.
class _VoiceBubble extends StatefulWidget {
  final String path;
  final int durationMs;
  final Color color;
  final Color accent;
  const _VoiceBubble({
    required this.path,
    required this.durationMs,
    required this.color,
    required this.accent,
  });

  @override
  State<_VoiceBubble> createState() => _VoiceBubbleState();
}

class _VoiceBubbleState extends State<_VoiceBubble> {
  AudioPlayer? _player;
  Duration _position = Duration.zero;
  bool _playing = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _player!.positionStream.listen((p) {
      if (mounted) setState(() => _position = p);
    });
    _player!.playerStateStream.listen((s) {
      if (mounted && s.processingState == ProcessingState.completed) {
        setState(() {
          _playing = false;
          _position = Duration.zero;
        });
      }
    });
  }

  @override
  void dispose() {
    _player?.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    final player = _player;
    if (player == null) return;
    try {
      if (_playing) {
        await player.pause();
      } else {
        if (player.playing) {
          await player.play();
        } else {
          await player.setFilePath(widget.path);
          await player.play();
        }
        if (mounted) setState(() => _playing = true);
      }
    } catch (e) {
      debugPrint('AI: voice bubble playback error: $e');
      if (mounted) setState(() => _playing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = Duration(milliseconds: widget.durationMs);
    final elapsed = _position;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 220),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: _togglePlay,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.accent,
              ),
              child: Icon(
                _playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: AppColors.primaryDarkest,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            AskImanAiService.formatDuration(
              _playing && _position > Duration.zero ? elapsed : total,
            ),
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: widget.color,
            ),
          ),
        ],
      ),
    );
  }
}

class _AiBubble extends StatelessWidget {
  final _ChatMessage message;
  final void Function(String) onCopy;
  final VoidCallback? onRetry;
  const _AiBubble({required this.message, required this.onCopy, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.verdict == 'verified')
            _VerdictBanner(verified: true, text: message.citations.firstOrNull?.shortLabel ?? '')
          else if (message.verdict == 'unverified')
            _VerdictBanner(verified: false, text: ''),
          const SizedBox(height: 10),
          Text(
            message.text,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              color: AppColors.textDark,
              height: 1.5,
            ),
          ),
          if (message.citations.isNotEmpty) ...[
            const SizedBox(height: 10),
            for (final c in message.citations) _CitationTile(citation: c),
          ],
          if (onRetry != null) ...[
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 16),
                label: Text(loc.translate('aiTryAgain')),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.goldDark,
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
          ],
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => onCopy(message.text),
              child: const Icon(
                Icons.copy_rounded,
                size: 15,
                color: AppColors.textGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VerdictBanner extends StatelessWidget {
  final bool verified;
  final String text;
  const _VerdictBanner({required this.verified, required this.text});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final color = verified ? AppColors.success : AppColors.warning;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            verified
                ? '✓ ${loc.translate('aiVerified')}  $text'
                : loc.translate('aiCannotVerify'),
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: verified ? const Color(0xFF15803D) : const Color(0xFFB45309),
            ),
          ),
        ),
      ],
    );
  }
}

class _CitationTile extends StatelessWidget {
  final AskAICitation citation;
  const _CitationTile({required this.citation});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isAyah = citation.kind == 'ayah';
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.goldSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.goldLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            citation.shortLabel,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryDark,
            ),
          ),
          if (citation.arabic.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              citation.arabic,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontFamily: 'Amiri',
                fontSize: 19,
                color: AppColors.primaryDarkest,
                height: 2.1,
                fontFamilyFallback: [
                  'Scheherazade New',
                  'Traditional Arabic',
                  'serif',
                ],
              ),
              strutStyle: const StrutStyle(
                fontFamily: 'Amiri',
                fontSize: 19,
                height: 2.1,
                forceStrutHeight: true,
              ),
            ),
          ],
          if (citation.text.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              citation.text,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                color: AppColors.textGrey,
                height: 1.45,
              ),
            ),
          ],
          if (!isAyah && citation.grade != null && citation.grade!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Grade: ${citation.grade}',
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: AppColors.primaryMid,
              ),
            ),
          ],
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => _showDetails(context),
              icon: const Icon(Icons.open_in_full, size: 14),
              label: Text(loc.translate('aiDetails')),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.goldDark,
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CitationDetailsSheet(citation: citation),
    );
  }
}

class CitationDetailsSheet extends StatelessWidget {
  final AskAICitation citation;
  const CitationDetailsSheet({super.key, required this.citation});

  @override
  Widget build(BuildContext context) {
    final isAyah = citation.kind == 'ayah';
    final body = <Widget>[
      Text(
        citation.book,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.goldDark,
          letterSpacing: 0.6,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        citation.shortLabel,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppColors.primaryDark,
        ),
      ),
      if (citation.arabic.isNotEmpty) ...[
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.bgCream,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            citation.arabic,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontSize: 22,
              color: AppColors.primaryDarkest,
              height: 2.0,
              fontFamilyFallback: [
                'Scheherazade New',
                'Traditional Arabic',
                'serif',
              ],
            ),
            strutStyle: const StrutStyle(
              fontFamily: 'Amiri',
              fontSize: 22,
              height: 2.0,
              forceStrutHeight: true,
            ),
          ),
        ),
      ],
      if (citation.text.isNotEmpty) ...[
        const SizedBox(height: 12),
        Text(
          citation.text,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 13,
            color: AppColors.textGrey,
            height: 1.5,
          ),
        ),
      ],
      if (!isAyah && citation.grade != null && citation.grade!.isNotEmpty) ...[
        const SizedBox(height: 10),
        Text(
          'Grade: ${citation.grade}',
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12,
            fontStyle: FontStyle.italic,
            color: AppColors.primaryMid,
          ),
        ),
      ],
    ];

    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.78,
        ),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
        decoration: const BoxDecoration(
          color: AppColors.bgWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Scrollable body: long Arabic + translation must never overflow
            // the sheet — the detail content scrolls while the actions below
            // stay pinned and reachable.
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: body,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      final text = [citation.arabic, citation.text, citation.shortLabel]
                          .where((e) => e.isNotEmpty)
                          .join('\n\n');
                      Clipboard.setData(ClipboardData(text: text));
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('Copy'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryDark,
                      side: const BorderSide(color: AppColors.primaryMid),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InputIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _InputIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, color: AppColors.primaryMid, size: 22),
      splashRadius: 22,
      padding: const EdgeInsets.all(6),
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
    );
  }
}

/// Staged photo in the composer: small preview + remove button. The image is
/// OCR'd in the background when the user sends, never as a blocking step.
class _AttachmentThumbnail extends StatelessWidget {
  final String path;
  final VoidCallback onRemove;
  const _AttachmentThumbnail({required this.path, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 64,
            height: 64,
            child: Image.file(File(path), fit: BoxFit.cover),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            loc.translate('aiPhotoAttached'),
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              color: context.textSecondary,
            ),
          ),
        ),
        IconButton(
          onPressed: onRemove,
          icon: const Icon(Icons.close_rounded, size: 20),
          color: AppColors.textGrey,
          tooltip: loc.translate('aiRemovePhoto'),
        ),
      ],
    );
  }
}

/// Centered date pill rendered before the first message of a new day
/// ("Today", "Yesterday", or a short date). Hidden for legacy messages
/// saved before timestamps existed.
class _DateSeparator extends StatelessWidget {
  final int ts;
  const _DateSeparator({required this.ts});

  @override
  Widget build(BuildContext context) {
    if (ts <= 0) return const SizedBox.shrink();
    final loc = AppLocalizations.of(context);
    final now = DateTime.now();
    final d = DateTime.fromMillisecondsSinceEpoch(ts);
    final diff = DateTime(now.year, now.month, now.day)
        .difference(DateTime(d.year, d.month, d.day))
        .inDays;
    final label = diff == 0
        ? loc.translate('today')
        : diff == 1
            ? loc.translate('yesterday')
            : DateFormat('d MMM y').format(d);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.goldSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.goldLight),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.goldDark,
            ),
          ),
        ),
      ),
    );
  }
}

/// Tiny per-message time label under a chat bubble.
class _TimeLabel extends StatelessWidget {
  final int ts;
  final bool alignEnd;
  const _TimeLabel({required this.ts, required this.alignEnd});

  @override
  Widget build(BuildContext context) {
    if (ts <= 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 2, bottom: 2),
      child: Align(
        alignment: alignEnd ? Alignment.centerRight : Alignment.centerLeft,
        child: Text(
          DateFormat('h:mm a')
              .format(DateTime.fromMillisecondsSinceEpoch(ts)),
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 10,
            color: AppColors.textLightGrey,
          ),
        ),
      ),
    );
  }
}
