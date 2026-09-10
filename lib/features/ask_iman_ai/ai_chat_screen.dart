// lib/features/ask_iman_ai/ai_chat_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

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

  const _ChatMessage({
    required this.role,
    required this.text,
    this.verdict = '',
    this.type = '',
    this.errorCode = '',
    this.citations = const [],
    this.ts = 0,
  });

  bool get isError => errorCode.isNotEmpty;

  bool get isRetryable {
    const nonRetryable = {
      'daily_limit', 'ai_not_configured', 'empty_input', 'too_long',
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
      );

  Map<String, dynamic> toJson() => {
        'role': role,
        'text': text,
        'verdict': verdict,
        'type': type,
        'errorCode': errorCode,
        'citations': citations.map((c) => c.toJson()).toList(),
        'ts': ts,
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
    AskImanAiService.saveHistory(_messages.map((m) => m.toJson()).toList());
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
    if (text.isEmpty || _busy) return;
    setState(() {
      _messages.add(_ChatMessage(role: 'user', text: text, ts: _now()));
      _busy = true;
    });
    _controller.clear();
    _focusNode.unfocus();
    _persist();
    _scrollToBottom();
    await _runAnswer(text);
  }

  Future<void> _retryFailed(int aiIndex) async {
    if (_busy) return;
    // Guard against a stale index captured by the build (list may have been
    // replaced by history reload) — an out-of-range removeAt would crash.
    if (aiIndex < 0 || aiIndex >= _messages.length) return;
    String? userText;
    for (var k = aiIndex - 1; k >= 0; k--) {
      if (_messages[k].role == 'user') {
        userText = _messages[k].text;
        break;
      }
    }
    if (userText == null) return;
    setState(() {
      _messages.removeAt(aiIndex);
      _busy = true;
    });
    await _runAnswer(userText);
  }

  Future<void> _runAnswer(String text) async {
    try {
      final resp = await AskImanAiService.ask(text: text, lang: _lang);
      if (!mounted) return;
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
      if (!mounted) return;
      setState(() {
        _messages.add(_ChatMessage(
          role: 'ai',
          text: 'Something went wrong. Please try again.',
          verdict: 'refused',
          type: 'general_qna',
          errorCode: 'ai_error',
          ts: _now(),
        ));
      });
    } finally {
      if (mounted) {
        setState(() => _busy = false);
        _persist();
        _scrollToBottom();
      }
    }
  }

  int _now() => DateTime.now().millisecondsSinceEpoch;

  Future<void> _handleImage(ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: source, imageQuality: 85);
    if (file == null || !mounted) return;

    final extracted = await AskImanAiService.extractTextFromImage(file);
    if (!mounted) return;

    if (extracted.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No text found in the image. Please try a clearer photo.'),
          backgroundColor: AppColors.primaryDarkest,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ExtractedTextSheet(initial: extracted),
    );
    if (confirmed == true && _controller.text.trim().isNotEmpty) {
      await _send(_controller.text);
    }
  }

  Future<void> _handleMic() async {
    if (_transcribing) return;
    setState(() => _transcribing = true);
    final words = await AskImanAiService.transcribe();
    if (!mounted) return;
    setState(() => _transcribing = false);
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
                          return const _TypeIndicator();
                        }
                        final m = _messages[i];
                        return m.role == 'user'
                            ? _UserBubble(text: m.text)
                            : _AiBubble(
                                message: m,
                                onCopy: _copyMessage,
                                onRetry: m.isRetryable
                                    ? () => _retryFailed(i)
                                    : null,
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
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      decoration: const BoxDecoration(
        color: AppColors.bgWhite,
        border: Border(top: BorderSide(color: AppColors.borderLight)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _InputIcon(
            icon: _transcribing ? Icons.graphic_eq : Icons.mic_none,
            onTap: _handleMic,
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
      ),
    );
  }
}

// ── Small widgets ──────────────────────────────────────────────────────────
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
  const _TypeIndicator();

  @override
  Widget build(BuildContext context) {
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
            child: const SizedBox(
              width: 30,
              height: 12,
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.gold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserBubble extends StatelessWidget {
  final String text;
  const _UserBubble({required this.text});

  @override
  Widget build(BuildContext context) {
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
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14,
            color: AppColors.textWhite,
            height: 1.4,
          ),
        ),
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
                label: const Text('Try again'),
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
            verified ? '✓ Verified  $text' : 'Cannot verify',
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
            const SizedBox(height: 8),
            Text(
              citation.arabic,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontFamily: 'Amiri',
                fontSize: 18,
                color: AppColors.primaryDarkest,
                height: 1.6,
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
      builder: (_) => _CitationDetailsSheet(citation: citation),
    );
  }
}

class _CitationDetailsSheet extends StatelessWidget {
  final AskAICitation citation;
  const _CitationDetailsSheet({required this.citation});

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
              height: 1.7,
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
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
        decoration: const BoxDecoration(
          color: AppColors.bgWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ...body,
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

class _ExtractedTextSheet extends StatefulWidget {
  final String initial;
  const _ExtractedTextSheet({required this.initial});

  @override
  State<_ExtractedTextSheet> createState() => _ExtractedTextSheetState();
}

class _ExtractedTextSheetState extends State<_ExtractedTextSheet> {
  late final TextEditingController _c;
  @override
  void initState() {
    super.initState();
    _c = TextEditingController(text: widget.initial);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
          decoration: const BoxDecoration(
            color: AppColors.bgWhite,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Text found in image',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Confirm the text, then send to verify.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  color: AppColors.textGrey,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _c,
                maxLines: 6,
                minLines: 3,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.bgCream,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textGrey,
                        side: const BorderSide(color: AppColors.borderLight),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primaryDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Send',
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
      ),
    );
  }
}