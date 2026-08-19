// lib/web/widgets/web_shell.dart
// ─────────────────────────────────────────────────────────────────────────────
// ASK IMAN WEBSITE — Shared page shell
//
// Fixed sticky top navbar + scrollable page body + optional mobile drawer.
// Each route renders its page inside this shell so the site chrome stays
// consistent across every page. Pages supply their own hero/footer content.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/figma_tokens.dart';
import 'web_navbar.dart';

class WebShell extends StatelessWidget {
  final Widget child;
  final bool wideBackground;

  const WebShell({
    super.key,
    required this.child,
    this.wideBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    return Scaffold(
      backgroundColor: wideBackground
          ? FigmaTokens.brandDeepGreen
          : Theme.of(context).scaffoldBackgroundColor,
      endDrawer: const WebNavDrawer(),
      body: Column(
        children: [
          WebNavbar(currentPath: path),
          Expanded(child: child),
        ],
      ),
    );
  }
}
