import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/breakpoints.dart';
import '../../core/services/community_service.dart';
import '../../core/services/prayer_service.dart';
import '../../core/services/tutorial_service.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/l10n/app_localizations.dart';
import '../../shared/widgets/ask_iman_app_bar.dart';
import '../../shared/widgets/tooltip_overlay.dart';
import '../../shared/widgets/islamic_background.dart';
import '../../shared/widgets/notif_settings_sheet.dart';
import '../auth/sign_in_screen.dart';

// ─── PROFILE SCREEN ──────────────────────────────────────────────────────────
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, this.embedded = false});

  /// When true the internal app bar is hidden (used by the website shell,
  /// which provides its own site navigation).
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppUser?>(
      stream: CommunityService.instance.watchCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.transparent,
            body: IslamicBackground(
              child: Center(
                child: CircularProgressIndicator(color: AppColors.gold),
              ),
            ),
          );
        }

        final user = snapshot.data;
        if (user == null) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            appBar: embedded ? null : const AskImanAppBar(),
            body: IslamicBackground(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 64,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkTextMuted
                          : AppColors.textGrey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Sign in to view your profile',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkTextSecondary
                            : AppColors.textGrey,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SignInScreen()),
                      ),
                      child: const Text('Sign In'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: embedded ? null : const AskImanAppBar(),
          body: IslamicBackground(
            child: TooltipOverlay(
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
                child: ContentContainer(
                  maxWidth: 1200,
                  child: Column(
                    children: [
                      _buildProfileHeader(context, user),
                      const SizedBox(height: 12),
                      _buildContributionSection(context),
                      const SizedBox(height: 12),
                      _buildActionSection(context, user),
                      const SizedBox(height: 12),
                      _buildAppearanceSection(context),
                      const SizedBox(height: 12),
                      _buildSupportSection(context),
                      _buildLogout(context),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(BuildContext context, AppUser user) {
    final isWide = context.isTablet || context.isDesktop;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: EdgeInsets.all(isWide ? 32 : 24),
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
      child: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 3, child: _profileIdentity(context, user)),
                const SizedBox(width: 24),
                Expanded(flex: 7, child: _profileStats(context, user)),
              ],
            )
          : Column(
              children: [
                _buildAvatar(user, size: 90),
                const SizedBox(height: 16),
                _profileName(user),
                const SizedBox(height: 4),
                _roleBadge(user),
                const SizedBox(height: 8),
                _profileBio(user),
                const SizedBox(height: 20),
                _mobileStatsRow(user),
                const SizedBox(height: 24),
                _editButton(context, user),
              ],
            ),
    );
  }

  Widget _buildAvatar(AppUser user, {required double size}) {
    return Stack(
      children: [
        Container(
          width: size,
          height: size,
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
                      errorBuilder: (_, _, _) => Icon(
                        Icons.person,
                        size: size * 0.55,
                        color: AppColors.textCream,
                      ),
                    )
                  : Icon(
                      Icons.person,
                      size: size * 0.55,
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
            child: Icon(
              Icons.verified_rounded,
              size: size * 0.18,
              color: AppColors.primaryDarkest,
            ),
          ),
        ),
      ],
    );
  }

  Widget _profileName(AppUser user) {
    return Text(
      user.name,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontFamily: 'Cairo',
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: AppColors.textWhite,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _roleBadge(AppUser user) {
    return Container(
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
    );
  }

  Widget _profileBio(AppUser user) {
    return Text(
      user.bio.isEmpty ? 'Stay consistent in your Deen 🌙' : user.bio,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontFamily: 'Cairo',
        fontSize: 13,
        color: AppColors.textGreenMuted,
      ),
    );
  }

  Widget _mobileStatsRow(AppUser user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _headerStat('🔥', '${user.streakCount}', 'STREAK'),
        _verticalDivider(),
        _headerStat('📖', '75%', 'QURAN'),
        _verticalDivider(),
        _headerStat('🕌', '92%', 'NAMAZ'),
      ],
    );
  }

  // Desktop: avatar + identity on the left (30%)
  Widget _profileIdentity(BuildContext context, AppUser user) {
    return Column(
      children: [
        _buildAvatar(user, size: 110),
        const SizedBox(height: 18),
        _profileName(user),
        const SizedBox(height: 6),
        _roleBadge(user),
        const SizedBox(height: 10),
        _profileBio(user),
        const SizedBox(height: 20),
        _editButton(context, user),
      ],
    );
  }

  // Desktop: 4-up stat cards on the right (70%)
  Widget _profileStats(BuildContext context, AppUser user) {
    final stats = <(String, String, String)>[
      ('🔥', '${user.streakCount}', 'STREAK'),
      ('📖', '75%', 'QURAN'),
      ('🕌', '92%', 'NAMAZ'),
      ('👥', '${user.friends.length}', 'COMMUNITY'),
    ];
    return LayoutBuilder(
      builder: (ctx, c) {
        final itemW = (c.maxWidth - 36) / 4;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final s in stats)
              SizedBox(width: itemW, child: _statCard(s.$1, s.$2, s.$3)),
          ],
        );
      },
    );
  }

  Widget _statCard(String emoji, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(height: 4),
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
      ),
    );
  }

  Widget _editButton(BuildContext context, AppUser user) {
    return GestureDetector(
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
      _glassSection(context, 'My Contributions', [
        _actionRow(
          Icons.favorite_outline_rounded,
          'Charity & Causes',
          'Coming Soon',
          isComingSoon: true,
          // Ships in the next app update after Play Store launch.
          // onTap: () => Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (_) => const CharityListScreen()),
          // ),
        ),
        _actionRow(
          Icons.receipt_long_outlined,
          'My Charity',
          'Coming Soon',
          isComingSoon: true,
          // Ships in the next app update after Play Store launch.
          // onTap: () => Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (_) => const MyCharityScreen()),
          // ),
        ),
      ], columns: 2);

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
    if (user.role.name == 'student') {
      actions.add(
        _actionRow(
          Icons.auto_stories,
          'Apply as Teacher',
          'Coming Soon',
          isComingSoon: true,
          // Ships in the next app update after Play Store launch.
          // onTap: () => Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (_) => const SignUpScreen(initialRole: UserRole.teacher),
          //   ),
          // ),
        ),
      );
    }
    return _glassSection(context, 'Personal Journey', actions, columns: 2);
  }

  // ── Appearance Section: 3-segment Theme picker + 3-language picker ─────────
  Widget _buildAppearanceSection(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
          child: Text(
            loc.translate('appearance').toUpperCase(),
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
          padding: const EdgeInsets.all(20),
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
          child: LayoutBuilder(
            builder: (ctx, c) {
              final isWide = context.isTablet || context.isDesktop;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.palette_outlined,
                        color: AppColors.primaryDark,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Theme',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildThemeSegments(ctx),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Icon(
                        Icons.language_rounded,
                        color: AppColors.primaryDark,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        loc.translate('appLanguage'),
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildLanguageSegments(ctx),
                  if (isWide) const SizedBox(height: 6),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildThemeSegments(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return _segmentRow([
          _segment(
            icon: Icons.light_mode_rounded,
            label: 'Light',
            selected: themeProvider.themeMode == ThemeMode.light,
            onTap: () => themeProvider.setThemeMode(ThemeMode.light),
          ),
          _segment(
            icon: Icons.dark_mode_rounded,
            label: 'Dark',
            selected: themeProvider.themeMode == ThemeMode.dark,
            onTap: () => themeProvider.setThemeMode(ThemeMode.dark),
          ),
          _segment(
            icon: Icons.settings_brightness_rounded,
            label: 'System',
            selected: themeProvider.themeMode == ThemeMode.system,
            onTap: () => themeProvider.setThemeMode(ThemeMode.system),
          ),
        ]);
      },
    );
  }

  Widget _buildLanguageSegments(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, _) {
        return _segmentRow([
          _segment(
            icon: null,
            label: loc.translate('english'),
            selected: localeProvider.locale.languageCode == 'en',
            onTap: () => localeProvider.setLocale(const Locale('en')),
          ),
          _segment(
            icon: null,
            label: loc.translate('urdu'),
            selected: localeProvider.locale.languageCode == 'ur',
            onTap: () => localeProvider.setLocale(const Locale('ur')),
          ),
          _segment(
            icon: null,
            label: loc.translate('pashto'),
            selected: localeProvider.locale.languageCode == 'ps',
            onTap: () => localeProvider.setLocale(const Locale('ps')),
          ),
        ]);
      },
    );
  }

  Widget _segmentRow(List<Widget> segments) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.bgCream,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          for (var i = 0; i < segments.length; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            Expanded(child: segments[i]),
          ],
        ],
      ),
    );
  }

  Widget _segment({
    required IconData? icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryDark : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 15,
                color: selected ? AppColors.gold : AppColors.textGrey,
              ),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: selected
                      ? AppColors.gold
                      : AppColors.textGrey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Support & Safety Section ───────────────────────────────────────────────
  Widget _buildSupportSection(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isWide = context.isTablet || context.isDesktop;
    final items = <({
      IconData icon,
      String title,
      String sub,
      VoidCallback onTap,
    })>[
      (
        icon: Icons.report_gmailerrorred_rounded,
        title: loc.translate('reportAnIssue'),
        sub: 'Technical or content feedback',
        onTap: () => _showReportDialog(context),
      ),
      (
        icon: Icons.help_outline_rounded,
        title: loc.translate('helpCentre'),
        sub: 'FAQs and contact support',
        onTap: () => _showHelpCentre(context),
      ),
      (
        icon: Icons.privacy_tip_outlined,
        title: loc.translate('privacyPolicy'),
        sub: 'Data protection and usage',
        onTap: () => _showPrivacyPolicy(context),
      ),
      (
        icon: Icons.info_outline_rounded,
        title: loc.translate('aboutAskIman'),
        sub: 'Version 1.0.4 (Stable)',
        onTap: () => _showAboutDialog(context),
      ),
      (
        icon: Icons.restart_alt_rounded,
        title: 'Reset Tutorial',
        sub: 'Show all onboarding tips again',
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
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
          child: Text(
            loc.translate('supportAndSafety').toUpperCase(),
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
          child: isWide
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: LayoutBuilder(
                    builder: (ctx, c) {
                      final itemW = (c.maxWidth - 3 * 12) / 4;
                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          for (final it in items)
                            SizedBox(
                              width: itemW,
                              child: _supportTile(
                                it.icon,
                                it.title,
                                it.sub,
                                it.onTap,
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                )
              : Column(
                  children: [
                    for (final it in items)
                      _actionRow(
                        it.icon,
                        it.title,
                        it.sub,
                        onTap: it.onTap,
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _supportTile(
    IconData icon,
    String title,
    String sub,
    VoidCallback onTap,
  ) {
    return Material(
      color: AppColors.bgCream,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.primaryDark, size: 22),
              const SizedBox(height: 10),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                sub,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11,
                  color: AppColors.textGrey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _glassSection(
    BuildContext context,
    String title,
    List<Widget> children, {
    int columns = 1,
  }) {
    final isWide = context.isTablet || context.isDesktop;
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
          child: isWide && columns > 1
              ? Padding(
                  padding: const EdgeInsets.all(12),
                  child: LayoutBuilder(
                    builder: (ctx, c) {
                      final itemW = (c.maxWidth - 12) / 2;
                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          for (final child in children)
                            SizedBox(width: itemW, child: child),
                        ],
                      );
                    },
                  ),
                )
              : Column(children: children),
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
  Uint8List? _imageBytes;
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
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      if (mounted) {
        setState(() => _imageBytes = bytes);
      }
    }
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
      if (_imageBytes != null) {
        photoUrl = await CommunityService.instance.uploadBytes(
          _imageBytes!,
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
                child: _imageBytes != null
                    ? Image.memory(_imageBytes!, fit: BoxFit.cover)
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
