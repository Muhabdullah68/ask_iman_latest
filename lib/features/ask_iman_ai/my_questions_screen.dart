// lib/features/ask_iman_ai/my_questions_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/services/ask_iman_ai_service.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/ask_iman_app_bar.dart';

class MyQuestionsScreen extends StatefulWidget {
  const MyQuestionsScreen({super.key});

  @override
  State<MyQuestionsScreen> createState() => _MyQuestionsScreenState();
}

class _MyQuestionsScreenState extends State<MyQuestionsScreen> {
  List<Map<String, dynamic>> _messages = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final history = await AskImanAiService.loadHistory();
    if (!mounted) return;
    setState(() {
      _messages = history ?? [];
      _loading = false;
    });
  }

  Future<void> _clear() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Clear history?',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          'This removes all your saved questions and answers.',
          style: TextStyle(fontFamily: 'Cairo', fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Clear',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await AskImanAiService.clearHistory();
    setState(() => _messages = []);
  }

  void _copy(String text) {
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

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AskImanAppBar(
        title: loc.translate('aiMyQuestions'),
        showBackButton: true,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.gold),
            )
          : _messages.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.history_rounded,
                        color: AppColors.textLightGrey,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        loc.translate('aiNoHistory'),
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(14),
                  itemCount: _messages.length,
                  itemBuilder: (context, i) {
                    return _HistoryTile(
                      message: _messages[i],
                      onCopy: _copy,
                    );
                  },
                ),
      floatingActionButton: _messages.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: _clear,
              backgroundColor: AppColors.bgWhite,
              foregroundColor: AppColors.error,
              elevation: 2,
              icon: const Icon(Icons.delete_outline, size: 20),
              label: Text(
                loc.translate('aiClearHistory'),
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final Map<String, dynamic> message;
  final void Function(String) onCopy;

  const _HistoryTile({required this.message, required this.onCopy});

  @override
  Widget build(BuildContext context) {
    final role = message['role'] as String? ?? 'ai';
    if (role == 'user') {
      return Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: const BoxDecoration(
          color: AppColors.primaryDark,
          borderRadius: BorderRadius.all(Radius.circular(14)),
        ),
        child: Row(
          children: [
            const Icon(Icons.person_outline, color: AppColors.textWhite, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message['text'] as String? ?? '',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  color: AppColors.textWhite,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final verdict = message['verdict'] as String? ?? '';
    final text = message['text'] as String? ?? '';
    final citations = ((message['citations'] as List?) ?? [])
        .whereType<Map>()
        .map((e) => AskAICitation.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.gold, size: 16),
              const SizedBox(width: 8),
              Text(
                verdict == 'verified'
                    ? '✓ Verified'
                    : (verdict == 'unverified' ? 'Cannot verify' : 'Answer'),
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: verdict == 'verified'
                      ? const Color(0xFF15803D)
                      : (verdict == 'unverified'
                          ? const Color(0xFFB45309)
                          : AppColors.primaryMid),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => onCopy(text),
                child: const Icon(Icons.copy_rounded,
                    size: 16, color: AppColors.textGrey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (citations.isNotEmpty) ...[
            for (final c in citations.take(1))
              Text(
                c.shortLabel,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.goldDark,
                ),
              ),
            const SizedBox(height: 6),
          ],
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              color: AppColors.textDark,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}