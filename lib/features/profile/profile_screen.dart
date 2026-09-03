import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/community_service.dart';
import '../../core/services/prayer_service.dart';
import '../../core/services/tutorial_service.dart';
import '../auth/sign_up_screen.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/l10n/app_localizations.dart';
import '../../shared/widgets/ask_iman_app_bar.dart';
import '../../shared/widgets/tooltip_overlay.dart';
import '../ibadah/ibadah_screen.dart';
import '../charity/charity_list_screen.dart';
import '../charity/my_charity_screen.dart';
import '../auth/sign_in_screen.dart';

// ─── PROFILE SCREEN ──────────────────────────────────────────────────────────
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    this.embedded = false,
    this.hideCommunity = false,
  });

  final bool embedded;
  final bool hideCommunity;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppUser?>(
      stream: CommunityService.instance.watchCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.bgCream,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.gold),
            ),
          );
        }

        final user = snapshot.data;
        if (user == null) {
          return Scaffold(
            backgroundColor: AppColors.bgCream,
            appBar: embedded ? null : const AskImanAppBar(),
            body: hideCommunity
                ? _buildGuestProfile(context)
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.person_outline,
                          size: 64,
                          color: AppColors.textGrey,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Sign in to view your profile',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14,
                            color: AppColors.textGrey,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SignInScreen(),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryDark,
                            foregroundColor: AppColors.gold,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(26),
                            ),
                          ),
                          child: const Text(
                            'Sign In',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
          }

        return Scaffold(
          backgroundColor: AppColors.bgCream,
          appBar: embedded ? null : const AskImanAppBar(),
          body: TooltipOverlay(
            id: 'tut_profile',
            title: AppLocalizations.of(
              context,
            ).translate('tutProfileSettingsTitle'),
            description: AppLocalizations.of(
              context,
            ).translate('tutProfileSettingsDesc'),
            arrowDirection: TooltipArrowDirection.down,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _buildProfileHeader(context, user),
                  const SizedBox(height: 12),
                  _buildContributionSection(context),
                  const SizedBox(height: 12),
                  _buildActionSection(context, user),
                  _buildSupportSection(context),
                  _buildLogout(context),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(BuildContext context, AppUser user) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primaryDarkest],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.gold, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Container(
                    color: AppColors.primaryMid,
                    child: user.photoUrl != null
                        ? Image.network(
                            user.photoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const Icon(
                              Icons.person,
                              size: 50,
                              color: AppColors.textCream,
                            ),
                          )
                        : const Icon(
                            Icons.person,
                            size: 50,
                            color: AppColors.textCream,
                          ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.gold,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified_rounded,
                    size: 16,
                    color: AppColors.primaryDarkest,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            user.name,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textWhite,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: _roleColor(user.role.name).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              user.role.name[0].toUpperCase() + user.role.name.substring(1),
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _roleColor(user.role.name),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            user.bio.isEmpty ? 'Stay consistent in your Deen 🌙' : user.bio,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              color: AppColors.textGreenMuted,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _headerStat('🔥', '${user.streakCount}', 'STREAK'),
              _verticalDivider(),
              _headerStat('📖', '75%', 'QURAN'),
              _verticalDivider(),
              _headerStat('🕌', '92%', 'NAMAZ'),
            ],
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => EditProfileScreen(user: user)),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.gold,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Text(
                'EDIT PROFILE',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDarkest,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerStat(String emoji, String value, String label) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textWhite,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: AppColors.textGreenMuted,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'admin':
        return AppColors.gold;
      case 'teacher':
        return const Color(0xFF4CAF50);
      default:
        return AppColors.textGreenMuted;
    }
  }

  Widget _verticalDivider() => Container(
    height: 30,
    width: 1,
    margin: const EdgeInsets.symmetric(horizontal: 16),
    color: AppColors.textGreenMuted.withValues(alpha: 0.2),
  );

  Widget _buildContributionSection(BuildContext context) =>
      _glassSection('My Contributions', [
        _actionRow(
          Icons.favorite_outline_rounded,
          'Charity & Causes',
          'Donate, raise, and request help',
          isComingSoon: hideCommunity,
          onTap: hideCommunity
              ? null
              : () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CharityListScreen(),
                    ),
                  ),
        ),
        _actionRow(
          Icons.receipt_long_outlined,
          'My Charity',
          'Track your donations and causes',
          isComingSoon: hideCommunity,
          onTap: hideCommunity
              ? null
              : () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MyCharityScreen()),
                  ),
        ),
      ]);

  Widget _buildGuestProfile(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.bgWhite,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryDark,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    size: 40,
                    color: AppColors.gold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Welcome, Guest',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDarkest,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'No sign-in needed — progress is saved on this device. '
                  'Sign in anytime to keep it in the cloud.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    color: AppColors.textGrey,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SignInScreen()),
                  ),
                  icon: const Icon(Icons.login, size: 18),
                  label: const Text('Sign in (optional)'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.gold,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          _glassSection('Personal Journey', [
            _actionRow(
              Icons.auto_awesome_outlined,
              'Ask Iman AI',
              'Coming Soon',
              isComingSoon: true,
            ),
            _actionRow(
              Icons.chat_bubble_outline_rounded,
              'Ask a Scholar',
              'Coming Soon',
              isComingSoon: true,
            ),
            _actionRow(
              Icons.history_rounded,
              'My Questions',
              'Coming Soon',
              isComingSoon: true,
            ),
            _actionRow(
              Icons.notifications_active_outlined,
              'Notifications',
              'Manage Adhan alerts',
              onTap: () => _showNotifSettings(context),
            ),
          ]),
          const SizedBox(height: 12),
          _buildSupportSection(context),
        ],
      ),
    );
  }

  Widget _buildActionSection(BuildContext context, AppUser user) {
    final actions = <Widget>[
      _actionRow(
        Icons.auto_awesome_outlined,
        'Ask Iman AI',
        'Coming Soon',
        isComingSoon: true,
      ),
      _actionRow(
        Icons.chat_bubble_outline_rounded,
        'Ask a Scholar',
        'Coming Soon',
        isComingSoon: true,
      ),
      _actionRow(
        Icons.history_rounded,
        'My Questions',
        'Coming Soon',
        isComingSoon: true,
      ),
      _actionRow(
        Icons.notifications_active_outlined,
        'Notifications',
        'Manage Adhan alerts',
        onTap: () => _showNotifSettings(context),
      ),
    ];
    if (!hideCommunity && user.role.name == 'student') {
      actions.add(
        _actionRow(
          Icons.auto_stories,
          'Apply as Teacher',
          'Share your knowledge with the community',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const SignUpScreen(initialRole: UserRole.teacher),
            ),
          ),
        ),
      );
    }
    return _glassSection('Personal Journey', actions);
  }

  Widget _buildSupportSection(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return _glassSection(loc.translate('supportAndSafety'), [
      _actionRow(
        Icons.report_gmailerrorred_rounded,
        loc.translate('reportAnIssue'),
        'Technical or content feedback',
        onTap: () => _showReportDialog(context),
      ),
      _actionRow(
        Icons.help_outline_rounded,
        loc.translate('helpCentre'),
        'FAQs and contact support',
        onTap: () => _showHelpCentre(context),
      ),
      _actionRow(
        Icons.privacy_tip_outlined,
        loc.translate('privacyPolicy'),
        'Data protection and usage',
        onTap: () => _showPrivacyPolicy(context),
      ),
      _actionRow(
        Icons.info_outline_rounded,
        loc.translate('aboutAskIman'),
        'Version 1.0.4 (Stable)',
        onTap: () => _showAboutDialog(context),
      ),
      _actionRow(
        Icons.language_rounded,
        loc.translate('appLanguage'),
        'English / اردو / پښتو',
        onTap: () => _showLanguageDialog(context),
      ),
      _actionRow(
        Icons.restart_alt_rounded,
        'Reset Tutorial',
        'Show all onboarding tips again',
        onTap: () async {
          final tutorial = TutorialService.instance;
          await tutorial.resetAll();
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Tutorial reset!')));
          }
        },
      ),
      _actionRow(
        Icons.dark_mode_outlined,
        loc.translate('appearance'),
        loc.translate('comingSoon'),
        isComingSoon: true,
      ),
    ]);
  }

  Widget _glassSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryDark,
              letterSpacing: 1.5,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.bgWhite,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.borderLight),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _actionRow(
    IconData icon,
    String title,
    String sub, {
    VoidCallback? onTap,
    bool isComingSoon = false,
  }) {
    return ListTile(
      onTap: isComingSoon ? null : onTap,
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: isComingSoon
              ? AppColors.bgCream
              : AppColors.primaryDark.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isComingSoon ? AppColors.textLightGrey : AppColors.primaryDark,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: isComingSoon ? AppColors.textLightGrey : AppColors.textDark,
        ),
      ),
      subtitle: Text(
        sub,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 12,
          color: AppColors.textGrey,
        ),
      ),
      trailing: isComingSoon
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.bgCream,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'SOON',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textGrey,
                ),
              ),
            )
          : const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.textLightGrey,
            ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    );
  }

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.report_gmailerrorred_rounded, color: AppColors.error),
            SizedBox(width: 10),
            Text(
              'Report an Issue',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Found a bug or incorrect content? Please reach out to our team immediately:',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 20),
            _contactTile(
              Icons.email_outlined,
              'askiman78@gmail.com',
              () => _launch('mailto:askiman78@gmail.com'),
            ),
            const SizedBox(height: 12),
            _contactTile(
              Icons.phone_outlined,
              '+92 336 9479196',
              () => _launch('tel:+923369479196'),
            ),
            const SizedBox(height: 12),
            _contactTile(
              Icons.chat_outlined,
              'WhatsApp Support',
              () => _launch('https://wa.me/923369479196'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Close',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactTile(IconData icon, String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.bgWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryDark, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ),
            const Icon(
              Icons.open_in_new_rounded,
              size: 14,
              color: AppColors.textLightGrey,
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpCentre(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: AppColors.bgCream,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Help Centre',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  _faqItem(
                    'How do I track my streaks?',
                    'Streaks are automatically tracked when you log your prayers, Quran reading, or community activity in the Streaks tab.',
                  ),
                  _faqItem(
                    'Is my data private?',
                    'Yes, your spiritual progress and personal data are encrypted and never shared with third parties.',
                  ),
                  _faqItem(
                    'How to use Ask Iman AI?',
                    'Ask Iman AI is currently in beta. Once released, you can ask any religious questions for instant context.',
                  ),
                  _faqItem(
                    'Can I contact a real scholar?',
                    'Yes, through the "Ask a Scholar" feature (Coming Soon), you will be connected to verified Islamic teachers.',
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Still need help?',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _contactTile(
                    Icons.email_outlined,
                    'askiman78@gmail.com',
                    () => _launch('mailto:askiman78@gmail.com'),
                  ),
                  const SizedBox(height: 10),
                  _contactTile(
                    Icons.phone_outlined,
                    '+92 336 9479196',
                    () => _launch('tel:+923369479196'),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: AppColors.bgCream,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Privacy Policy',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  const Text(
                    'At Ask Iman, we value your privacy and spiritual journey. Your data is handled with the utmost care and in accordance with Islamic principles of trust (Amanah).',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      color: AppColors.textDark,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _policySection(
                    'Data Collection',
                    'We only collect data necessary to provide you with a personalized spiritual experience, such as your prayer logs, Quran progress, and profile information.',
                  ),
                  _policySection(
                    'Data Usage',
                    'Your data is used solely to enhance your experience, track your streaks, and provide AI-powered insights. We do not sell or share your personal information with third parties.',
                  ),
                  _policySection(
                    'Security',
                    'We use industry-standard encryption and security measures to protect your data from unauthorized access.',
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Questions or Concerns?',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _contactTile(
                    Icons.email_outlined,
                    'askiman78@gmail.com',
                    () => _launch('mailto:askiman78@gmail.com'),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _policySection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              color: AppColors.textGrey,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _faqItem(String q, String a) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            q,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            a,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              color: AppColors.textGrey,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Image.asset(
              'assets/images/applogo.png',
              height: 70,
              errorBuilder: (_, _, _) =>
                  const Icon(Icons.mosque, color: AppColors.gold, size: 60),
            ),
            const SizedBox(height: 16),
            const Text(
              'Ask Iman',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.primaryDark,
              ),
            ),
            const Text(
              'v1.0.4 (Stable)',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                color: AppColors.goldDark,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Ask Iman is a comprehensive spiritual companion designed to empower your Islamic lifestyle. From real-time prayer tracking and Quranic study to AI-powered guidance, we are here to support your journey to Allah.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13,
                color: AppColors.textGrey,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 12),
            const Text(
              'Contact Us',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'askiman78@gmail.com',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                color: AppColors.primaryDark.withValues(alpha: 0.7),
              ),
            ),
            Text(
              '+92 336 9479196',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                color: AppColors.primaryDark.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Made with ❤️ for the Ummah',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textLightGrey,
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final loc = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.bgCream,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    loc.translate('selectLanguage'),
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _languageTile(
                  loc.translate('english'),
                  '🇬🇧',
                  const Locale('en'),
                  ctx,
                ),
                _languageTile(
                  loc.translate('urdu'),
                  '🇵🇰',
                  const Locale('ur'),
                  ctx,
                ),
                _languageTile(
                  loc.translate('pashto'),
                  '🇦🇫',
                  const Locale('ps'),
                  ctx,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _languageTile(
    String name,
    String flag,
    Locale locale,
    BuildContext context,
  ) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        return ListTile(
          leading: Text(flag, style: const TextStyle(fontSize: 24)),
          title: Text(
            name,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          trailing: localeProvider.locale == locale
              ? const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.primaryDark,
                )
              : null,
          onTap: () {
            localeProvider.setLocale(locale);
            Navigator.pop(context);
          },
        );
      },
    );
  }

  void _showNotifSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.bgCream,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: NotifSettingsSheet(service: PrayerService()),
      ),
    );
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Widget _buildLogout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GestureDetector(
        onTap: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text(
                'Log Out',
                style: TextStyle(fontFamily: 'Cairo'),
              ),
              content: const Text(
                'Are you sure you want to log out?',
                style: TextStyle(fontFamily: 'Cairo'),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text(
                    'Log Out',
                    style: TextStyle(color: AppColors.error),
                  ),
                ),
              ],
            ),
          );
          if (confirm == true) await FirebaseAuth.instance.signOut();
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.error.withValues(alpha: 0.1)),
          ),
          child: const Center(
            child: Text(
              'Log Out',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.error,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── EDIT PROFILE SCREEN ─────────────────────────────────────────────────────
class EditProfileScreen extends StatefulWidget {
  final AppUser user;
  const EditProfileScreen({super.key, required this.user});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _bioCtrl;
  File? _imageFile;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.user.name);
    _bioCtrl = TextEditingController(text: widget.user.bio);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (picked != null) setState(() => _imageFile = File(picked.path));
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Name cannot be empty')));
      return;
    }
    setState(() => _loading = true);
    try {
      String? photoUrl = widget.user.photoUrl;
      if (_imageFile != null) {
        photoUrl = await CommunityService.instance.uploadImage(
          _imageFile!,
          'profiles/${widget.user.uid}',
        );
      }
      await CommunityService.instance.updateUserProfile(
        name: name,
        bio: _bioCtrl.text.trim(),
        photoUrl: photoUrl,
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: const AskImanAppBar(showBackButton: true),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildAvatarEdit(),
                const SizedBox(height: 32),
                _input('Full Name', _nameCtrl),
                const SizedBox(height: 20),
                _input('Bio / Status', _bioCtrl, lines: 3),
                const SizedBox(height: 32),
                _buildActionButtons(),
              ],
            ),
          ),
          if (_loading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.gold),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatarEdit() {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.gold, width: 3),
            ),
            child: ClipOval(
              child: Container(
                color: AppColors.primaryMid,
                child: _imageFile != null
                    ? Image.file(_imageFile!, fit: BoxFit.cover)
                    : widget.user.photoUrl != null
                    ? Image.network(widget.user.photoUrl!, fit: BoxFit.cover)
                    : const Icon(
                        Icons.person,
                        size: 60,
                        color: AppColors.textCream,
                      ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.gold,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  size: 20,
                  color: AppColors.primaryDarkest,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _input(String label, TextEditingController ctrl, {int lines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryDark,
              letterSpacing: 1.0,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: AppColors.primaryDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: ctrl,
            maxLines: lines,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        GestureDetector(
          onTap: _submit,
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryDark.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'Save Changes',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.gold,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancel',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w700,
              color: AppColors.textGrey,
            ),
          ),
        ),
      ],
    );
  }
}
