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
import '../widgets/web_footer.dart';
import '../../features/profile/profile_screen.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    setPageTitle('Profile — My Account · Ask Iman');
    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: webScrollPhysics,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ProfileScreen(embedded: true),
                          const SizedBox(height: 24),
                        ],
                      ),
                      const SizedBox(height: 56),
                      const WebFooter(),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
