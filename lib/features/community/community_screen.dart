import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/services/community_service.dart';
import '../../core/theme/figma_tokens.dart';
import '../../core/utils/breakpoints.dart';
import '../../core/utils/seo_meta.dart';
import '../../shared/widgets/islamic_background.dart';
import '../../shared/widgets/ask_iman_app_bar.dart';
import '../auth/sign_in_screen.dart';
import 'streaks/streaks_tab.dart';
import 'classes/classes_tab.dart';
import 'friends/family_and_friends_tab.dart';
import 'groups/groups_tab.dart';
import '../charity/charity_list_screen.dart';
import 'admin/admin_dashboard.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key, this.embedded = false});

  /// When true the internal app bar is hidden (used by the website shell,
  /// which provides its own site navigation).
  final bool embedded;

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with SingleTickerProviderStateMixin {
  final _svc = CommunityService.instance;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Streaks is excluded from the website (see changes.txt); the shell
    // embeds this screen with `embedded: true`.
    _tabController = TabController(length: widget.embedded ? 4 : 5, vsync: this);
    setPageTitle('Community — Classes, Groups & Charity · Ask Iman');
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return _buildGuestView();

    return Scaffold(
      backgroundColor: FigmaTokens.surfaceBackground,
      appBar: widget.embedded ? null : const AskImanAppBar(),
      body: StreamBuilder<AppUser?>(
        stream: _svc.watchCurrentUser(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return _buildCommunityContent(snapshot.data!);
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: FigmaTokens.accentGoldAmber),
            );
          }
          final authUser = FirebaseAuth.instance.currentUser;
          final fallback = AppUser(
            uid: authUser!.uid,
            name: authUser.email?.split('@').first ?? 'User',
            email: authUser.email ?? '',
            role: UserRole.student,
            isApproved: false,
          );
          return _buildCommunityContent(fallback);
        },
      ),
    );
  }

  Widget _buildGuestView() {
    return Scaffold(
      backgroundColor: FigmaTokens.surfaceBackground,
      appBar: widget.embedded ? null : const AskImanAppBar(),
      body: IslamicBackground(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildGuestBanner(),
              _buildHeroSection(isGuest: true),
              _buildActiveCampaignsSection(),
              _buildTransparencyPanel(),
              _buildCommunityTilesSection(),
              _buildFigmaFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuestBanner() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SignInScreen()),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        color: FigmaTokens.accentGoldAmber,
        child: const Text(
          'Sign in to access all community features',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: FigmaTokens.brandDeepGreen,
          ),
        ),
      ),
    );
  }

  Widget _buildCommunityContent(AppUser user) {
    return IslamicBackground(
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeaderRow(user),
            _buildHeroSection(isGuest: false, user: user),
            _buildActiveCampaignsSection(),
            _buildTransparencyPanel(),
            _buildCommunityTilesSection(),
            _buildLegacyTabs(user),
            _buildFigmaFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderRow(AppUser user) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Community',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: FigmaTokens.textHeading,
                  ),
                ),
                Text(
                  user.role == UserRole.teacher
                      ? 'Manage your classes and connect'
                      : 'Learn, connect, and grow together',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    color: FigmaTokens.textBody,
                  ),
                ),
              ],
            ),
          ),
          if (!kIsWeb && user.role == UserRole.admin)
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminDashboard()),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: FigmaTokens.accentGoldAmber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Admin',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: FigmaTokens.accentGoldAmber,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeroSection({required bool isGuest, AppUser? user}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(FigmaTokens.radiusCard),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            FigmaTokens.brandDeepGreen,
            Color(0xFF0A2A1E),
          ],
        ),
        boxShadow: FigmaTokens.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(FigmaTokens.radiusCard),
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.12,
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                        'https://images.unsplash.com/photo-1585036156161-1330a0f25f7a?w=1600',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(FigmaTokens.spacing8),
              child: ResponsiveBuilder(
                mobile: (context) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroLeftColumn(isGuest, user),
                    const SizedBox(height: FigmaTokens.spacing6),
                    _buildHeroRightColumn(),
                  ],
                ),
                tablet: (context) => Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildHeroLeftColumn(isGuest, user)),
                    const SizedBox(width: FigmaTokens.spacing8),
                    _buildHeroRightColumn(),
                  ],
                ),
                desktop: (context) => Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildHeroLeftColumn(isGuest, user)),
                    const SizedBox(width: FigmaTokens.spacing12),
                    _buildHeroRightColumn(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroLeftColumn(bool isGuest, AppUser? user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: FigmaTokens.spacing2),
        const Text(
          'GLOBAL OUTREACH',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 44,
            fontWeight: FontWeight.w900,
            color: FigmaTokens.textOnDark,
            height: 1.1,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: FigmaTokens.spacing4),
        const Text(
          'Communities thrive when hearts give together.',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: FigmaTokens.textCreamLight,
            height: 1.5,
          ),
        ),
        const SizedBox(height: FigmaTokens.spacing8),
        Wrap(
          spacing: FigmaTokens.spacing4,
          runSpacing: FigmaTokens.spacing4,
          children: [
            _buildDonateNowButton(),
            _buildVerifyDonationButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroRightColumn() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 220),
      padding: const EdgeInsets.all(FigmaTokens.spacing6),
      decoration: BoxDecoration(
        border: Border.all(
          color: FigmaTokens.accentGoldAmber.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(FigmaTokens.radiusCardSm),
      ),
      child: const Column(
        children: [
          Text(
            'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 22,
              fontWeight: FontWeight.w400,
              color: FigmaTokens.accentGoldLight,
              height: 1.8,
            ),
          ),
          SizedBox(height: FigmaTokens.spacing4),
          Text(
            'In the name of Allah, the Most Gracious, the Most Merciful',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: FigmaTokens.textCreamLight,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonateNowButton() {
    return GestureDetector(
      onTap: () {
        _tabController.animateTo(4);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: FigmaTokens.spacing6,
          vertical: FigmaTokens.spacing4,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF134832),
              FigmaTokens.brandDeepGreen,
            ],
          ),
          borderRadius: BorderRadius.circular(FigmaTokens.radiusButton),
          boxShadow: [
            BoxShadow(
              color: FigmaTokens.brandDeepGreen.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.favorite_rounded,
              color: FigmaTokens.accentGoldLight,
              size: 18,
            ),
            SizedBox(width: FigmaTokens.spacing2),
            Text(
              'Donate Now',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: FigmaTokens.textOnDark,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerifyDonationButton() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: FigmaTokens.spacing6,
          vertical: FigmaTokens.spacing4,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(FigmaTokens.radiusButton),
          border: Border.all(
            color: FigmaTokens.accentGoldAmber,
            width: 1.5,
          ),
          color: Colors.transparent,
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.verified_user_rounded,
              color: FigmaTokens.accentGoldAmber,
              size: 18,
            ),
            SizedBox(width: FigmaTokens.spacing2),
            Text(
              'Verify a Donation',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: FigmaTokens.accentGoldAmber,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveCampaignsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: FigmaTokens.spacing6,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ACTIVE CAMPAIGNS',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: FigmaTokens.accentGoldAmber,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: FigmaTokens.spacing3),
          const Text(
            'Active Opportunities',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: FigmaTokens.textHeading,
              height: 1.2,
            ),
          ),
          const SizedBox(height: FigmaTokens.spacing6),
          _buildCampaignGrid(),
        ],
      ),
    );
  }

  Widget _buildCampaignGrid() {
    final campaigns = _getMockCampaigns();
    return ResponsiveBuilder(
      mobile: (context) => Column(
        children: [
          for (var c in campaigns) ...[
            _buildCampaignCard(c),
            const SizedBox(height: FigmaTokens.spacing5),
          ],
        ],
      ),
      tablet: (context) => Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildCampaignCard(campaigns[0])),
              const SizedBox(width: FigmaTokens.spacing5),
              Expanded(child: _buildCampaignCard(campaigns[1])),
            ],
          ),
          const SizedBox(height: FigmaTokens.spacing5),
          if (campaigns.length > 2)
            Row(
              children: [
                Expanded(child: _buildCampaignCard(campaigns[2])),
                const SizedBox(width: FigmaTokens.spacing5),
                Expanded(child: Container()),
              ],
            ),
        ],
      ),
      desktop: (context) => Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildCampaignCard(campaigns[0])),
              const SizedBox(width: FigmaTokens.spacing5),
              Expanded(child: _buildCampaignCard(campaigns[1])),
              const SizedBox(width: FigmaTokens.spacing5),
              Expanded(child: _buildCampaignCard(campaigns[2])),
            ],
          ),
        ],
      ),
    );
  }

  List<_CampaignData> _getMockCampaigns() {
    return [
      _CampaignData(
        title: 'Ramadan Food Packs — Gaza',
        category: 'Zakat · Food',
        imageUrl:
            'https://images.unsplash.com/photo-1532634922-8fe0b757fb13?w=800',
        goal: 25000,
        raised: 18750,
        donors: 142,
      ),
      _CampaignData(
        title: 'Quran School — Orphans Fund',
        category: 'Sadaqah · Education',
        imageUrl:
            'https://images.unsplash.com/photo-1542816417-0983c9c9ad53?w=800',
        goal: 15000,
        raised: 9300,
        donors: 87,
      ),
      _CampaignData(
        title: 'Winter Blankets — Syria',
        category: 'Zakat · Emergency',
        imageUrl:
            'https://images.unsplash.com/photo-1585417521757-51217ba95166?w=800',
        goal: 10000,
        raised: 7200,
        donors: 63,
      ),
    ];
  }

  Widget _buildCampaignCard(_CampaignData data) {
    final pct = data.goal > 0 ? (data.raised / data.goal).clamp(0.0, 1.0) : 0.0;
    final pctInt = (pct * 100).round();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(FigmaTokens.radiusCard),
        boxShadow: FigmaTokens.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(FigmaTokens.radiusCard),
        child: AspectRatio(
          aspectRatio: 3.2 / 4,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.network(
                  data.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: FigmaTokens.brandDeepGreen,
                  ),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xB3000000),
                        Color(0xB8000000),
                        Color(0xCC000000),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(FigmaTokens.spacing5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: FigmaTokens.spacing3,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: FigmaTokens.accentGoldAmber,
                        borderRadius:
                            BorderRadius.circular(FigmaTokens.radiusPill),
                      ),
                      child: Text(
                        'COLLECTION',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: FigmaTokens.brandDeepGreen,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: FigmaTokens.spacing2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: FigmaTokens.spacing3,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius:
                            BorderRadius.circular(FigmaTokens.radiusPill),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        data.category,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: FigmaTokens.accentGoldLight,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      data.title,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: FigmaTokens.textOnDark,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: FigmaTokens.spacing5),
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(FigmaTokens.radiusPill),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 8,
                        backgroundColor:
                            Colors.white.withValues(alpha: 0.15),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          FigmaTokens.accentGoldAmber,
                        ),
                      ),
                    ),
                    const SizedBox(height: FigmaTokens.spacing3),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: FigmaTokens.spacing3,
                            vertical: FigmaTokens.spacing1,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                FigmaTokens.brandAccentSageStart,
                                FigmaTokens.brandAccentSageEnd,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(
                              FigmaTokens.radiusPill,
                            ),
                          ),
                          child: Text(
                            '$pctInt% raised',
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: FigmaTokens.textOnDark,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            const Icon(
                              Icons.people_alt_rounded,
                              size: 14,
                              color: FigmaTokens.accentGoldLight,
                            ),
                            const SizedBox(width: FigmaTokens.spacing1),
                            Text(
                              '${data.donors} donors',
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: FigmaTokens.textCreamLight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: FigmaTokens.spacing1),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransparencyPanel() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: FigmaTokens.spacing8,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: FigmaTokens.surfacePanelMint,
          borderRadius: BorderRadius.circular(FigmaTokens.radiusCard),
          border: Border.all(
            color: FigmaTokens.accentGoldAmber.withValues(alpha: 0.15),
          ),
          boxShadow: FigmaTokens.cardShadowSm,
        ),
        child: ResponsiveBuilder(
          mobile: (context) => Padding(
            padding: const EdgeInsets.all(FigmaTokens.spacing8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTransparencyLeft(),
                const SizedBox(height: FigmaTokens.spacing8),
                _buildTransparencyRight(),
              ],
            ),
          ),
          tablet: (context) => Padding(
            padding: const EdgeInsets.all(FigmaTokens.spacing8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildTransparencyLeft()),
                const SizedBox(width: FigmaTokens.spacing8),
                Expanded(child: _buildTransparencyRight()),
              ],
            ),
          ),
          desktop: (context) => Padding(
            padding: const EdgeInsets.all(FigmaTokens.spacing12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildTransparencyLeft()),
                const SizedBox(width: FigmaTokens.spacing12),
                Expanded(child: _buildTransparencyRight()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransparencyLeft() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 4,
          height: 48,
          decoration: BoxDecoration(
            color: FigmaTokens.accentGoldAmber,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: FigmaTokens.spacing5),
        const Text(
          '100% Zakat-compliant',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 36,
            fontWeight: FontWeight.w900,
            color: FigmaTokens.brandDeepGreen,
            height: 1.15,
          ),
        ),
        const SizedBox(height: FigmaTokens.spacing3),
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: '· ',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: FigmaTokens.accentGoldAmber,
                ),
              ),
              TextSpan(
                text: 'Verified every quarter',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: FigmaTokens.brandDeepGreen,
                  height: 1.15,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: FigmaTokens.spacing6),
        const Text(
          'Every rupee is tracked, receipted, and reviewed by an independent Shariah board. No hidden fees, ever.',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: FigmaTokens.textBody,
            height: 1.7,
          ),
        ),
      ],
    );
  }

  Widget _buildTransparencyRight() {
    final indicators = [
      _TrustIndicator(
        icon: Icons.gavel_rounded,
        title: 'Independent Shariah Audit',
        subtitle: 'Reviewed quarterly by qualified scholars',
      ),
      _TrustIndicator(
        icon: Icons.receipt_long_rounded,
        title: 'Full Receipt Trail',
        subtitle: 'Every donation generates a verifiable receipt',
      ),
      _TrustIndicator(
        icon: Icons.account_balance_wallet_rounded,
        title: 'Zero Admin Fees',
        subtitle: '100% of funds reach the intended cause',
      ),
      _TrustIndicator(
        icon: Icons.public_rounded,
        title: 'Public Ledger',
        subtitle: 'Real-time allocation visible to all donors',
      ),
    ];

    return Column(
      children: [
        for (var i = 0; i < indicators.length; i++) ...[
          _buildTrustIndicator(indicators[i]),
          if (i < indicators.length - 1)
            const SizedBox(height: FigmaTokens.spacing4),
        ],
      ],
    );
  }

  Widget _buildTrustIndicator(_TrustIndicator data) {
    return Container(
      padding: const EdgeInsets.all(FigmaTokens.spacing5),
      decoration: BoxDecoration(
        color: FigmaTokens.surfaceCard,
        borderRadius: BorderRadius.circular(FigmaTokens.radiusCardSm),
        border: Border.all(
          color: FigmaTokens.borderHairline,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: FigmaTokens.brandAccentSageStart.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    data.icon,
                    size: 20,
                    color: FigmaTokens.brandAccentSageStart,
                  ),
                ),
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: FigmaTokens.brandAccentSageStart,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: FigmaTokens.surfaceCard,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 12,
                      color: FigmaTokens.textOnDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: FigmaTokens.spacing4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: FigmaTokens.textHeading,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data.subtitle,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: FigmaTokens.textBody,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityTilesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: FigmaTokens.spacing8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'COMMUNITY HUB',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: FigmaTokens.accentGoldAmber,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: FigmaTokens.spacing3),
          const Text(
            'Your Sacred Journey Spaces',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: FigmaTokens.textHeading,
              height: 1.2,
            ),
          ),
          const SizedBox(height: FigmaTokens.spacing6),
          _buildTilesGrid(),
        ],
      ),
    );
  }

  Widget _buildTilesGrid() {
    final tiles = [
      _CommunityTile(
        icon: Icons.menu_book_rounded,
        title: 'Classes',
        subtitle: 'Live Islamic courses & halaqat',
        onTap: () => _tabController.animateTo(1),
      ),
      _CommunityTile(
        icon: Icons.groups_rounded,
        title: 'Groups',
        subtitle: 'Study circles & communities',
        onTap: () => _tabController.animateTo(3),
      ),
      _CommunityTile(
        icon: Icons.chat_bubble_rounded,
        title: 'Chat',
        subtitle: 'Message friends & teachers',
        onTap: () => _tabController.animateTo(2),
      ),
      _CommunityTile(
        icon: Icons.family_restroom_rounded,
        title: 'Family Hub',
        subtitle: 'Family learning & activity',
        onTap: () => _tabController.animateTo(2),
      ),
    ];

    return ResponsiveBuilder(
      mobile: (context) => Column(
        children: [
          for (var i = 0; i < tiles.length; i += 2) ...[
            Row(
              children: [
                Expanded(child: _buildTileCard(tiles[i])),
                const SizedBox(width: FigmaTokens.spacing5),
                Expanded(
                  child: i + 1 < tiles.length
                      ? _buildTileCard(tiles[i + 1])
                      : Container(),
                ),
              ],
            ),
            if (i + 2 < tiles.length)
              const SizedBox(height: FigmaTokens.spacing5),
          ],
        ],
      ),
      tablet: (context) => Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildTileCard(tiles[0])),
              const SizedBox(width: FigmaTokens.spacing5),
              Expanded(child: _buildTileCard(tiles[1])),
            ],
          ),
          const SizedBox(height: FigmaTokens.spacing5),
          Row(
            children: [
              Expanded(child: _buildTileCard(tiles[2])),
              const SizedBox(width: FigmaTokens.spacing5),
              Expanded(child: _buildTileCard(tiles[3])),
            ],
          ),
        ],
      ),
      desktop: (context) => Row(
        children: [
          Expanded(child: _buildTileCard(tiles[0])),
          const SizedBox(width: FigmaTokens.spacing5),
          Expanded(child: _buildTileCard(tiles[1])),
          const SizedBox(width: FigmaTokens.spacing5),
          Expanded(child: _buildTileCard(tiles[2])),
          const SizedBox(width: FigmaTokens.spacing5),
          Expanded(child: _buildTileCard(tiles[3])),
        ],
      ),
    );
  }

  Widget _buildTileCard(_CommunityTile tile) {
    return GestureDetector(
      onTap: tile.onTap,
      child: Container(
        padding: const EdgeInsets.all(FigmaTokens.spacing6),
        decoration: BoxDecoration(
          color: FigmaTokens.surfaceCard,
          borderRadius: BorderRadius.circular(FigmaTokens.radiusCard),
          border: Border.all(
            color: FigmaTokens.borderHairline,
          ),
          boxShadow: FigmaTokens.cardShadowSm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    FigmaTokens.brandAccentSageStart,
                    FigmaTokens.brandAccentSageEnd,
                  ],
                ),
                borderRadius: BorderRadius.circular(FigmaTokens.radiusCardSm),
                boxShadow: [
                  BoxShadow(
                    color: FigmaTokens.brandAccentSageStart.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(
                tile.icon,
                size: 28,
                color: FigmaTokens.accentGoldLight,
              ),
            ),
            const SizedBox(height: FigmaTokens.spacing5),
            Text(
              tile.title,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: FigmaTokens.textHeading,
              ),
            ),
            const SizedBox(height: FigmaTokens.spacing2),
            Text(
              tile.subtitle,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: FigmaTokens.textBody,
                height: 1.5,
              ),
            ),
            const SizedBox(height: FigmaTokens.spacing4),
            Row(
              children: [
                Text(
                  'Enter',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: FigmaTokens.accentGoldAmber,
                  ),
                ),
                const SizedBox(width: FigmaTokens.spacing1),
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 14,
                  color: FigmaTokens.accentGoldAmber,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegacyTabs(AppUser user) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, FigmaTokens.spacing8, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          color: FigmaTokens.surfaceCard,
          borderRadius: BorderRadius.circular(FigmaTokens.radiusCard),
          border: Border.all(color: FigmaTokens.borderHairline),
          boxShadow: FigmaTokens.cardShadowSm,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                FigmaTokens.spacing2,
                FigmaTokens.spacing3,
                FigmaTokens.spacing2,
                0,
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: FigmaTokens.accentGoldAmber,
                unselectedLabelColor: FigmaTokens.textMuted,
                indicatorColor: FigmaTokens.accentGoldAmber,
                labelStyle: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                tabs: [
                  if (!widget.embedded) const Tab(text: 'Streaks'),
                  const Tab(text: 'Classes'),
                  const Tab(text: 'Family & Friends'),
                  const Tab(text: 'Groups'),
                  const Tab(text: 'Charity'),
                ],
              ),
            ),
            SizedBox(
              height: 520,
              child: TabBarView(
                controller: _tabController,
                children: [
                  if (!widget.embedded) StreaksTab(currentUser: user),
                  ClassesTab(currentUser: user),
                  FamilyAndFriendsTab(currentUser: user),
                  GroupsTab(currentUser: user),
                  const CharityListScreen(showScaffold: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFigmaFooter() {
    return Padding(
      padding: const EdgeInsets.only(top: FigmaTokens.spacing12),
      child: Column(
        children: [
          Container(
            color: FigmaTokens.brandDeepGreen,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: FigmaTokens.spacing12,
            ),
            child: ResponsiveBuilder(
              mobile: (context) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFooterBrand(),
                  const SizedBox(height: FigmaTokens.spacing8),
                  _buildFooterColumn(
                    title: 'Programs',
                    items: [
                      'Hifz Academy',
                      'Arabic Mastery',
                      'Tafsir Circles',
                      'Youth Programs',
                    ],
                  ),
                  const SizedBox(height: FigmaTokens.spacing6),
                  _buildFooterColumn(
                    title: 'Community',
                    items: [
                      'Classes',
                      'Groups',
                      'Family Hub',
                      'Events',
                    ],
                  ),
                  const SizedBox(height: FigmaTokens.spacing6),
                  _buildFooterColumn(
                    title: 'Support',
                    items: [
                      'Help Center',
                      'Contact Scholars',
                      'Privacy Policy',
                      'Terms of Use',
                    ],
                  ),
                ],
              ),
              tablet: (context) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFooterBrand(),
                  const SizedBox(height: FigmaTokens.spacing8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildFooterColumn(
                          title: 'Programs',
                          items: [
                            'Hifz Academy',
                            'Arabic Mastery',
                            'Tafsir Circles',
                            'Youth Programs',
                          ],
                        ),
                      ),
                      Expanded(
                        child: _buildFooterColumn(
                          title: 'Community',
                          items: [
                            'Classes',
                            'Groups',
                            'Family Hub',
                            'Events',
                          ],
                        ),
                      ),
                      Expanded(
                        child: _buildFooterColumn(
                          title: 'Support',
                          items: [
                            'Help Center',
                            'Contact Scholars',
                            'Privacy Policy',
                            'Terms of Use',
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              desktop: (context) => Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _buildFooterBrand()),
                  const SizedBox(width: FigmaTokens.spacing8),
                  Expanded(
                    child: _buildFooterColumn(
                      title: 'Programs',
                      items: [
                        'Hifz Academy',
                        'Arabic Mastery',
                        'Tafsir Circles',
                        'Youth Programs',
                      ],
                    ),
                  ),
                  const SizedBox(width: FigmaTokens.spacing8),
                  Expanded(
                    child: _buildFooterColumn(
                      title: 'Community',
                      items: [
                        'Classes',
                        'Groups',
                        'Family Hub',
                        'Events',
                      ],
                    ),
                  ),
                  const SizedBox(width: FigmaTokens.spacing8),
                  Expanded(
                    child: _buildFooterColumn(
                      title: 'Support',
                      items: [
                        'Help Center',
                        'Contact Scholars',
                        'Privacy Policy',
                        'Terms of Use',
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  FigmaTokens.accentGoldAmber,
                  FigmaTokens.accentGoldLight,
                  FigmaTokens.accentGoldAmber,
                ],
              ),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: FigmaTokens.spacing4,
            ),
            child: const Center(
              child: Text(
                '© 2026 Ask Iman — All rights reserved. BarakAllahu feekum.',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: FigmaTokens.brandDeepGreen,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterBrand() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: FigmaTokens.accentGoldAmber.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.mosque_rounded,
                color: FigmaTokens.accentGoldAmber,
                size: 26,
              ),
            ),
            const SizedBox(width: FigmaTokens.spacing3),
            RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'ASK ',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: FigmaTokens.accentGoldAmber,
                      letterSpacing: 1,
                    ),
                  ),
                  TextSpan(
                    text: 'ایمان',
                    style: TextStyle(
                      fontFamily: 'NotoNastaliq',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: FigmaTokens.textOnDark,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: FigmaTokens.spacing5),
        const Text(
          'Nurturing souls, connecting hearts, and preserving authentic Islamic learning for the global Ummah.',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xB3FFFFFF),
            height: 1.7,
          ),
        ),
        const SizedBox(height: FigmaTokens.spacing5),
        Row(
          children: [
            _buildSocialIcon(Icons.facebook_rounded),
            const SizedBox(width: FigmaTokens.spacing3),
            _buildSocialIcon(Icons.chat_rounded),
            const SizedBox(width: FigmaTokens.spacing3),
            _buildSocialIcon(Icons.ondemand_video_rounded),
            const SizedBox(width: FigmaTokens.spacing3),
            _buildSocialIcon(Icons.share_rounded),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialIcon(IconData icon) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
        ),
      ),
      child: Icon(
        icon,
        size: 16,
        color: FigmaTokens.accentGoldLight,
      ),
    );
  }

  Widget _buildFooterColumn({
    required String title,
    required List<String> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: FigmaTokens.accentGoldAmber,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: FigmaTokens.spacing4),
        for (var item in items) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Text(
              item,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xE6FFFFFF),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _CampaignData {
  final String title;
  final String category;
  final String imageUrl;
  final double goal;
  final double raised;
  final int donors;

  const _CampaignData({
    required this.title,
    required this.category,
    required this.imageUrl,
    required this.goal,
    required this.raised,
    required this.donors,
  });
}

class _TrustIndicator {
  final IconData icon;
  final String title;
  final String subtitle;

  const _TrustIndicator({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

class _CommunityTile {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _CommunityTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}
