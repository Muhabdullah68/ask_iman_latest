import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/l10n/app_localizations.dart';
import '../../shared/widgets/ask_iman_app_bar.dart';
import 'charity_service.dart';
import 'charity_detail_screen.dart';
import 'donate_screen.dart';
import 'request_charity_screen.dart';
import 'my_charity_screen.dart';

class CharityListScreen extends StatefulWidget {
  final bool showScaffold;
  const CharityListScreen({super.key, this.showScaffold = true});

  @override
  State<CharityListScreen> createState() => _CharityListScreenState();
}

class _CharityListScreenState extends State<CharityListScreen>
    with SingleTickerProviderStateMixin {
  final _svc = CharityService.instance;
  late TabController _tabController;
  String _category = 'All';

  static const _categoryImages = <String, String>{
    'Education': 'assets/category_images/education_relief.jpg',
    'Health': 'assets/category_images/Healthcare-Financial-Relief.jpeg',
    'Relief': 'assets/category_images/general_relief.jpg',
    'Food': 'assets/category_images/food_relief.jpg',
    'Water': 'assets/category_images/general_relief.jpg',
    'Orphan': 'assets/category_images/orphane_relief.jpg',
    'Medical': 'assets/category_images/Healthcare-Financial-Relief.jpeg',
    'Mosque': 'assets/category_images/mosque_relief.jpg',
    'General': 'assets/category_images/general_relief.jpg',
    'Other': 'assets/category_images/other_relief.jpg',
  };

  final _categories = [
    'All',
    'Education',
    'Health',
    'Relief',
    'Food',
    'Water',
    'Orphan',
    'Mosque',
    'General',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final body = Column(
      children: [
        _buildHeader(context),
        TabBar(
          controller: _tabController,
          labelColor: AppColors.gold,
          unselectedLabelColor: AppColors.textGrey,
          indicatorColor: AppColors.gold,
          tabs: [
            Tab(text: loc.translate('causes')),
            Tab(text: loc.translate('requests')),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [_buildCausesTab(), _buildRequestsTab()],
          ),
        ),
      ],
    );
    if (!widget.showScaffold) return body;
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AskImanAppBar(title: loc.translate('charity')),
      body: body,
    );
  }

  Widget _buildHeader(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primaryDarkest],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _quickAction(
                icon: Icons.favorite,
                label: loc.translate('donate'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DonateScreen()),
                ),
              ),
              _quickAction(
                icon: Icons.handshake,
                label: loc.translate('askHelp'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RequestCharityScreen(),
                  ),
                ),
              ),
              _quickAction(
                icon: Icons.receipt_long,
                label: loc.translate('myCharity'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MyCharityScreen()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: AppColors.gold,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primaryDarkest, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textWhite,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCausesTab() {
    return _buildCausesBody();
  }

  Widget _buildCausesBody() {
    return Column(
      children: [
        _buildCategoryFilter(),
        Expanded(
          child: StreamBuilder<List<CharityCause>>(
            stream: _svc.watchActiveCauses(
              category: _category == 'All' ? null : _category,
            ),
            builder: (ctx, snap) {
              if (snap.hasError) {
                debugPrint('Charity causes stream error: ${snap.error}');
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppColors.textGrey,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Error loading causes: ${snap.error}',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                );
              }
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.gold),
                );
              }
              final list = snap.data ?? [];
              if (list.isEmpty) {
                return Center(
                  child: Text(
                    'No active causes yet',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      color: AppColors.textGrey,
                      fontSize: 14,
                    ),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: list.length,
                itemBuilder: (_, i) => _buildCauseCard(context, list[i]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        children: _categories.map((cat) {
          final active = _category == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                cat,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: active ? AppColors.primaryDarkest : AppColors.textGrey,
                ),
              ),
              selected: active,
              selectedColor: AppColors.gold,
              backgroundColor: AppColors.primaryDarkest,
              onSelected: (_) => setState(() => _category = cat),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCauseCard(BuildContext context, CharityCause cause) {
    final imageUrl = _categoryImages[cause.category] ??
        _categoryImages['Other']!;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.primaryDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CharityDetailScreen(causeId: cause.id),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 140,
              width: double.infinity,
              child: Image.asset(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: AppColors.primaryDarkest,
                  child: const Center(
                    child: Icon(Icons.image, color: AppColors.textGrey, size: 40),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          cause.title,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textWhite,
                          ),
                        ),
                      ),
                      if (cause.verified)
                        const Icon(Icons.verified, color: AppColors.gold, size: 18),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    cause.category,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      color: AppColors.gold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: cause.progress,
                      backgroundColor: AppColors.primaryDarkest,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.gold,
                      ),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${cause.raised.toStringAsFixed(0)} raised',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textGreenMuted,
                        ),
                      ),
                      Text(
                        '${cause.progressPct}% of \$${cause.goal.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestsTab() {
    return StreamBuilder<List<CharityRequest>>(
      stream: _svc.watchRequests(),
      builder: (ctx, snap) {
        if (snap.hasError) {
          debugPrint('Charity requests stream error: ${snap.error}');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.textGrey,
                ),
                const SizedBox(height: 12),
                Text(
                  'Error loading requests: ${snap.error}',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
          );
        }
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.gold),
          );
        }
        final list = snap.data ?? [];
        if (list.isEmpty) {
          return Center(
            child: Text(
              'No help requests yet',
              style: TextStyle(
                fontFamily: 'Cairo',
                color: AppColors.textGrey,
                fontSize: 14,
              ),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: list.length,
          itemBuilder: (_, i) => _buildRequestCard(list[i]),
        );
      },
    );
  }

  Widget _buildRequestCard(CharityRequest req) {
    final imageUrl = _categoryImages[req.category] ??
        _categoryImages['Other']!;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.primaryDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 140,
            width: double.infinity,
            child: Image.asset(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                color: AppColors.primaryDarkest,
                child: const Center(
                  child: Icon(Icons.image, color: AppColors.textGrey, size: 40),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  req.title,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textWhite,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  req.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    color: AppColors.textGreenMuted,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'From: ${req.userName}',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11,
                    color: AppColors.textGrey,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: req.progress,
                    backgroundColor: AppColors.primaryDarkest,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${req.amountReceived.toStringAsFixed(0)} / \$${req.amountNeeded.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
