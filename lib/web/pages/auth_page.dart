// lib/web/pages/auth_page.dart
// ─────────────────────────────────────────────────────────────────────────────
// ASK IMAN WEBSITE — AUTH (Sign In / Sign Up / Pending Approval)
//
// The app's auth screens are already self-contained Figma-styled pages; we
// render them inside the website shell.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../core/services/community_service.dart' show UserRole;
import '../../core/utils/seo_meta.dart';
import '../../features/auth/pending_approval_screen.dart';
import '../../features/auth/sign_in_screen.dart';
import '../../features/auth/sign_up_screen.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    setPageTitle('Sign In · Ask Iman');
    return const SignInScreen();
  }
}

class SignUpPage extends StatelessWidget {
  final UserRole role;
  const SignUpPage({super.key, this.role = UserRole.student});

  @override
  Widget build(BuildContext context) {
    setPageTitle('Join Free · Ask Iman');
    return SignUpScreen(initialRole: role);
  }
}

class PendingApprovalPage extends StatelessWidget {
  final String role;
  const PendingApprovalPage({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    setPageTitle('Pending Approval · Ask Iman');
    return PendingApprovalScreen(role: role);
  }
}
