// lib/web/pages/profile_page.dart
// ─────────────────────────────────────────────────────────────────────────────
// ASK IMAN WEBSITE — PROFILE
//
// Embeds the app's ProfileScreen (settings, progress, saved content) inside
// the website shell with its internal app bar hidden.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../core/utils/seo_meta.dart';
import '../widgets/web_animations.dart';
import '../../features/profile/profile_screen.dart';
import '../widgets/web_footer.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    setPageTitle('Profile — My Account · Ask Iman');
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: webScrollPhysics,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ProfileScreen(embedded: true),
                const SizedBox(height: 24),
                const WebFooter(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
