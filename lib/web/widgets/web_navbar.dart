// lib/web/widgets/web_navbar.dart
// ─────────────────────────────────────────────────────────────────────────────
// ASK IMAN WEBSITE — Sticky top navigation bar
//
// Deep-green bar that turns to glass on scroll. Renders the 5 primary site
// links, language switcher (EN / اردو / پښتو), theme toggle and auth status.
// Collapses into a drawer on mobile/tablet viewports.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/figma_tokens.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/providers/locale_provider.dart';
import '../web_firebase.dart' show webAuthStateChanges;
import '../web_router.dart' show WebRoutes;

class WebNavbar extends StatelessWidget {
  final String currentPath;

  const WebNavbar({super.key, required this.currentPath});

  @override
  Widget build(BuildContext context) {
    return const _NavbarInner();
  }
}

class _NavbarInner extends StatelessWidget {
  const _NavbarInner();

  static const List<({String label, String route})> _links = [
    (label: 'Home', route: '/'),
    (label: 'Quran', route: WebRoutes.quran),
    (label: 'Calendar & Tools', route: WebRoutes.calendarTools),
    (label: 'Community & Charity', route: WebRoutes.community),
    (label: 'About Us', route: WebRoutes.about),
  ];

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();

    final barColor = FigmaTokens.brandDeepGreen;

    return Material(
      color: barColor,
      elevation: 4,
      shadowColor: Colors.black26,
      child: Container(
        height: 68,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            if (w < 900) return _buildMobile(context, path, localeProvider);
            if (w < 1180) return _buildCompact(context, path, localeProvider);
            return _buildDesktop(context, path, themeProvider, localeProvider);
          },
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, curve: Curves.easeOut)
        .slideY(begin: -0.08, end: 0, duration: 400.ms, curve: Curves.easeOut);
  }

  // ── Desktop (≥1180) — full chrome ───────────────────────────────────────
  Widget _buildDesktop(
    BuildContext context,
    String path,
    ThemeProvider themeProvider,
    LocaleProvider localeProvider,
  ) {
    return Row(
      children: [
        _BrandLogo(onTap: () => context.go('/')),
        const SizedBox(width: 24),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              for (final l in _links)
                _NavLink(label: l.label, route: l.route, currentPath: path),
            ],
          ),
        ),
        _LangSwitcher(localeProvider: localeProvider),
        const SizedBox(width: 8),
        _ThemeButton(themeProvider: themeProvider),
        const SizedBox(width: 8),
        _AuthArea(),
      ],
    );
  }

  // ── Compact (900–1179) — logo + links + theme + menu ───────────────────
  // Auth and language switch live in the drawer at this width to avoid
  // horizontal overflow of the fixed-height bar.
  Widget _buildCompact(
    BuildContext context,
    String path,
    LocaleProvider localeProvider,
  ) {
    return Row(
      children: [
        _BrandLogo(onTap: () => context.go('/')),
        const SizedBox(width: 20),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final l in _links)
                  _NavLink(
                    label: l.label,
                    route: l.route,
                    currentPath: path,
                    compact: true,
                  ),
              ],
            ),
          ),
        ),
        Consumer<ThemeProvider>(
          builder: (_, tp, _) => _ThemeButton(themeProvider: tp),
        ),
        IconButton(
          icon: const Icon(Icons.menu_rounded, color: FigmaTokens.textOnDark),
          onPressed: () => _openDrawer(context),
        ),
      ],
    );
  }

  // ── Mobile / tablet (<900) ──────────────────────────────────────────────
  Widget _buildMobile(
    BuildContext context,
    String path,
    LocaleProvider localeProvider,
  ) {
    return Row(
      children: [
        _BrandLogo(onTap: () => context.go('/')),
        const Spacer(),
        _LangSwitcher(localeProvider: localeProvider),
        const SizedBox(width: 4),
        Consumer<ThemeProvider>(
          builder: (_, tp, _) => _ThemeButton(themeProvider: tp),
        ),
        IconButton(
          icon: const Icon(Icons.menu_rounded, color: FigmaTokens.textOnDark),
          onPressed: () => _openDrawer(context),
        ),
      ],
    );
  }

  void _openDrawer(BuildContext context) {
    Scaffold.of(context).openEndDrawer();
  }
}

// ── Brand logo ─────────────────────────────────────────────────────────────
class _BrandLogo extends StatelessWidget {
  final VoidCallback onTap;
  const _BrandLogo({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/applogo.png',
              height: 32,
              width: 32,
              errorBuilder: (_, _, _) => const Icon(
                Icons.mosque_rounded,
                color: FigmaTokens.accentGoldAmber,
                size: 28,
              ),
            ),
            const SizedBox(width: 8),
            const Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'ASK ',
                    style: TextStyle(
                      fontFamily: FigmaTokens.fontFamilyDisplaySerif,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: FigmaTokens.accentGoldAmber,
                      letterSpacing: 1.2,
                    ),
                  ),
                  TextSpan(
                    text: 'ایمان',
                    style: TextStyle(
                      fontFamily: 'NotoNastaliq',
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: FigmaTokens.textOnDark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Nav link ───────────────────────────────────────────────────────────────
class _NavLink extends StatefulWidget {
  final String label;
  final String route;
  final String currentPath;
  final bool compact;

  const _NavLink({
    required this.label,
    required this.route,
    required this.currentPath,
    this.compact = false,
  });

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.route == '/'
        ? widget.currentPath == '/'
        : widget.currentPath.startsWith(widget.route);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widget.compact ? 2 : 6),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        cursor: SystemMouseCursors.click,
        child: InkWell(
          onTap: () => context.go(widget.route),
          borderRadius: BorderRadius.circular(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: widget.compact ? 10 : 14,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: active ? FigmaTokens.brandMidGreen : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontFamily: FigmaTokens.fontFamilyUiSans,
                    fontSize: widget.compact ? 13.5 : 14.5,
                    fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                    color: active
                        ? FigmaTokens.accentGoldAmber
                        : _hovered
                            ? FigmaTokens.accentGoldAmber
                            : FigmaTokens.textOnDark.withValues(alpha: 0.88),
                  ),
                  child: Text(widget.label),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                height: 2.5,
                width: active ? (widget.compact ? 20 : 24) : 0,
                decoration: BoxDecoration(
                  gradient: FigmaTokens.progressGradient,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Language switcher ──────────────────────────────────────────────────────
class _LangSwitcher extends StatelessWidget {
  final LocaleProvider localeProvider;
  const _LangSwitcher({required this.localeProvider});

  static const _langs = [
    (code: 'en', label: 'EN'),
    (code: 'ur', label: 'اردو'),
    (code: 'ps', label: 'پښتو'),
  ];

  @override
  Widget build(BuildContext context) {
    final current = localeProvider.locale.languageCode;
    return PopupMenuButton<String>(
      offset: const Offset(0, 44),
      color: FigmaTokens.surfaceCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      onSelected: (code) => localeProvider.setLocale(
        Locale(code),
      ),
      itemBuilder: (_) => [
        for (final l in _langs)
          PopupMenuItem(
            value: l.code,
            child: Row(
              children: [
                SizedBox(
                  width: 44,
                  child: Text(
                    l.label,
                    style: TextStyle(
                      fontFamily: FigmaTokens.fontFamilyUiSans,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: l.code == current
                          ? FigmaTokens.accentGoldAmber
                          : FigmaTokens.textHeading,
                    ),
                  ),
                ),
                if (l.code == current)
                  const Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: FigmaTokens.accentGoldAmber,
                  ),
              ],
            ),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.14),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _langs.firstWhere(
                (l) => l.code == current,
                orElse: () => _langs.first,
              ).label,
              style: const TextStyle(
                fontFamily: FigmaTokens.fontFamilyUiSans,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: FigmaTokens.textOnDark,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.arrow_drop_down_rounded,
              color: FigmaTokens.accentGoldLight,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Theme button ───────────────────────────────────────────────────────────
class _ThemeButton extends StatelessWidget {
  final ThemeProvider themeProvider;
  const _ThemeButton({required this.themeProvider});

  @override
  Widget build(BuildContext context) {
    final isDark = themeProvider.isDarkMode;
    return IconButton(
      onPressed: themeProvider.toggleTheme,
      tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
      icon: Icon(
        isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
        color: FigmaTokens.accentGoldAmber,
        size: 22,
      ),
    );
  }
}

// ── Auth area ──────────────────────────────────────────────────────────────
class _AuthArea extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: webAuthStateChanges(),
      builder: (context, snap) {
        final user = snap.data;
        if (user == null) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () => context.go(WebRoutes.signIn),
                child: const Text(
                  'Sign In',
                  style: TextStyle(
                    fontFamily: FigmaTokens.fontFamilyUiSans,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: FigmaTokens.textOnDark,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Material(
                color: FigmaTokens.accentGoldAmber,
                borderRadius: BorderRadius.circular(999),
                child: InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: () => context.go(WebRoutes.signUp),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    child: const Text(
                      'Join Free',
                      style: TextStyle(
                        fontFamily: FigmaTokens.fontFamilyUiSans,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: FigmaTokens.brandDeepGreen,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        final initial = (user.email?.isNotEmpty ?? false)
            ? user.email!.substring(0, 1).toUpperCase()
            : 'U';
        return InkWell(
          onTap: () => context.go(WebRoutes.profile),
          borderRadius: BorderRadius.circular(999),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: FigmaTokens.accentGoldAmber,
            child: Text(
              initial,
              style: const TextStyle(
                fontFamily: FigmaTokens.fontFamilyUiSans,
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: FigmaTokens.brandDeepGreen,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Drawer (mobile) ────────────────────────────────────────────────────────
class WebNavDrawer extends StatelessWidget {
  const WebNavDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    return Drawer(
      backgroundColor: FigmaTokens.brandDeepGreen,
      shape: const RoundedRectangleBorder(),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.all(20),
              child: _BrandLogo(onTap: _noop),
            ),
            const Divider(color: Colors.white12, height: 1),
            for (final l in _NavbarInner._links)
              ListTile(
                leading: const Icon(
                  Icons.chevron_right_rounded,
                  color: FigmaTokens.accentGoldAmber,
                ),
                title: Text(
                  l.label,
                  style: TextStyle(
                    fontFamily: FigmaTokens.fontFamilyUiSans,
                    fontSize: 15,
                    fontWeight: path.startsWith(l.route)
                        ? FontWeight.w800
                        : FontWeight.w600,
                    color: path.startsWith(l.route)
                        ? FigmaTokens.accentGoldAmber
                        : FigmaTokens.textOnDark,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  context.go(l.route);
                },
              ),
            const Divider(color: Colors.white12, height: 1),
            ListTile(
              leading: const Icon(
                Icons.login_rounded,
                color: FigmaTokens.accentGoldAmber,
              ),
              title: const Text(
                'Sign In',
                style: TextStyle(
                  fontFamily: FigmaTokens.fontFamilyUiSans,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: FigmaTokens.textOnDark,
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
                context.go(WebRoutes.signIn);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.person_add_alt_1_rounded,
                color: FigmaTokens.accentGoldAmber,
              ),
              title: const Text(
                'Join Free',
                style: TextStyle(
                  fontFamily: FigmaTokens.fontFamilyUiSans,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: FigmaTokens.accentGoldAmber,
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
                context.go(WebRoutes.signUp);
              },
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: _LangSwitcher(
                localeProvider: context.watch<LocaleProvider>(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Consumer<ThemeProvider>(
                builder: (_, tp, _) => OutlinedButton.icon(
                  onPressed: tp.toggleTheme,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: FigmaTokens.accentGoldAmber,
                    side: const BorderSide(color: Colors.white24),
                  ),
                  icon: Icon(
                    tp.isDarkMode
                        ? Icons.light_mode_rounded
                        : Icons.dark_mode_rounded,
                    size: 18,
                  ),
                  label: Text(tp.isDarkMode ? 'Light mode' : 'Dark mode'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _noop() {}
}
