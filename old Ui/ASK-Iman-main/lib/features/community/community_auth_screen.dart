// lib/features/community/community_auth_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
// COMMUNITY GATE — guest mode for streaks
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'streaks/streaks_tab.dart';

// ══════════════════════════════════════════════════════════════════════════════
// COMMUNITY GATE  — top-level router for community tab
// ══════════════════════════════════════════════════════════════════════════════
class CommunityGate extends StatelessWidget {
  const CommunityGate({super.key});

  @override
  Widget build(BuildContext context) {
    // Return StreaksTab directly for guest mode as requested
    return const StreaksTab(currentUser: null);
  }
}
