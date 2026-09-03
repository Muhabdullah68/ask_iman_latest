import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/ask_iman_app_bar.dart';
import 'charity_service.dart';
import 'donate_screen.dart';

class CharityDetailScreen extends StatelessWidget {
  final String causeId;
  const CharityDetailScreen({super.key, required this.causeId});

  @override
  Widget build(BuildContext context) {
    final svc = CharityService.instance;
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: const AskImanAppBar(title: 'Charity'),
      body: StreamBuilder<CharityCause?>(
        stream: svc.watchCause(causeId),
        builder: (ctx, snap) {
          final cause = snap.data;
          if (cause == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.gold),
            );
          }
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (cause.imageUrl != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.network(
                            cause.imageUrl!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) =>
                                const SizedBox.shrink(),
                          ),
                        ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              cause.title,
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primaryDarkest,
                              ),
                            ),
                          ),
                          if (cause.verified)
                            const Icon(
                              Icons.verified,
                              color: AppColors.gold,
                              size: 22,
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.gold,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              cause.category,
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryDarkest,
                              ),
                            ),
                          ),
                          if (cause.orgName != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              'by ${cause.orgName}',
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 12,
                                color: AppColors.textGrey,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: cause.progress,
                          backgroundColor: AppColors.primaryDark,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.gold,
                          ),
                          minHeight: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '\$${cause.raised.toStringAsFixed(0)} raised',
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryDarkest,
                            ),
                          ),
                          Text(
                            'Goal: \$${cause.goal.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 13,
                              color: AppColors.textGrey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DonateScreen(
                                causeId: cause.id,
                                causeTitle: cause.title,
                              ),
                            ),
                          ),
                          icon: const Icon(Icons.favorite),
                          label: const Text(
                            'Donate Now',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.gold,
                            foregroundColor: AppColors.primaryDarkest,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Description',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDarkest,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        cause.description,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          color: AppColors.textDark,
                          height: 1.6,
                        ),
                      ),
                      if (cause.bankDetails != null) ...[
                        const SizedBox(height: 20),
                        Text(
                          'Bank Details',
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDarkest,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primaryDark,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: SelectableText(
                                  cause.bankDetails!,
                                  style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 12,
                                    color: AppColors.textGreenMuted,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.copy,
                                  color: AppColors.gold,
                                  size: 20,
                                ),
                                onPressed: () {
                                  Clipboard.setData(
                                    ClipboardData(text: cause.bankDetails!),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Copied')),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: _buildDonationsSection(context, causeId),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDonationsSection(BuildContext context, String causeId) {
    final svc = CharityService.instance;
    return StreamBuilder<List<CharityDonation>>(
      stream: svc.watchDonations(causeId),
      builder: (ctx, snap) {
        final donations = snap.data ?? [];
        if (donations.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recent Donations (${donations.length})',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDarkest,
                ),
              ),
              const SizedBox(height: 8),
              ...donations
                  .take(20)
                  .map(
                    (d) => Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryDark,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.favorite, size: 14, color: AppColors.gold),
                          const SizedBox(width: 8),
                          Text(
                            d.anonymous ? 'Anonymous' : d.userName,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12,
                              color: AppColors.textGreenMuted,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '\$${d.amount.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.gold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
