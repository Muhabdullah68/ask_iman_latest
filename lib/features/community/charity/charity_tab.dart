// lib/features/community/charity/charity_tab.dart
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/community_service.dart';

class CharityTab extends StatefulWidget {
  final AppUser currentUser;
  const CharityTab({super.key, required this.currentUser});
  @override State<CharityTab> createState() => _CharityTabState();
}

class _CharityTabState extends State<CharityTab> {
  final _svc = CommunityService.instance;
  String _category = 'All';
  final _categories = ['All', 'Education', 'Health', 'Relief'];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroBanner(context),
          _buildStatsRow(),
          _buildActiveHeader(),
          _buildCategoryFilter(),
          StreamBuilder<List<CharityModel>>(
            stream: _svc.watchActiveCharities(
                category: _category == 'All' ? null : _category),
            builder: (ctx, snap) {
              final list = snap.data ?? [];
              return Column(
                children: list.map(_buildCharityCard).toList(),
              );
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHeroBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Empower Change with', style: TextStyle(
            fontFamily: 'Cairo', fontSize: 20,
            fontWeight: FontWeight.w700, color: AppColors.textWhite,
          )),
          const Text('Sadaqah', style: TextStyle(
            fontFamily: 'Cairo', fontSize: 28,
            fontWeight: FontWeight.w900, color: AppColors.gold,
          )),
          const SizedBox(height: 8),
          const Text(
            'Your contributions provide life-changing support to the global Ummah.',
            style: TextStyle(fontFamily: 'Cairo', fontSize: 13,
                color: AppColors.textGreenMuted, height: 1.4),
          ),
          const SizedBox(height: 16),
          // BUG FIX: original had overflow — now uses intrinsic height
          GestureDetector(
            onTap: () => _showCreateCharitySheet(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.gold),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Text('+ Create Charity Campaign', style: TextStyle(
                fontFamily: 'Cairo', fontSize: 13,
                fontWeight: FontWeight.w600, color: AppColors.gold,
              )),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Row(
        children: [
          _statCard('\$122k', 'Total Funds\nRaised'),
          const SizedBox(width: 8),
          _statCard('1,842', 'Active\nDonors'),
          const SizedBox(width: 8),
          _statCard('100%', 'Verified\nRequests'),
        ],
      ),
    );
  }

  Widget _statCard(String val, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.primaryDark,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(val, style: const TextStyle(fontFamily: 'Cairo',
                fontSize: 22, fontWeight: FontWeight.w800,
                color: AppColors.textWhite)),
            Text(label, style: const TextStyle(fontFamily: 'Cairo',
                fontSize: 11, color: AppColors.textGreenMuted, height: 1.3)),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Text('Active Campaigns', style: TextStyle(
        fontFamily: 'Cairo', fontSize: 18,
        fontWeight: FontWeight.w700, color: AppColors.textDark,
      )),
    );
  }

  Widget _buildCategoryFilter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 0, 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: _categories.map((c) {
            final active = _category == c;
            return GestureDetector(
              onTap: () => setState(() => _category = c),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: active ? AppColors.primaryDark : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: active ? AppColors.primaryDark : AppColors.borderLight,
                  ),
                ),
                child: Text(c, style: TextStyle(
                  fontFamily: 'Cairo', fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: active ? AppColors.gold : AppColors.textGrey,
                )),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCharityCard(CharityModel c) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image area
          Container(
            height: 150,
            color: AppColors.primaryDark,
            child: Stack(
              children: [
                const Center(child: Icon(Icons.account_balance_rounded,
                    color: AppColors.primaryLight, size: 56)),
                if (c.verified)
                  Positioned(
                    top: 12, left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified, size: 12,
                              color: AppColors.primaryDarkest),
                          SizedBox(width: 4),
                          Text('Verified', style: TextStyle(
                              fontFamily: 'Cairo', fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryDarkest)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.title, style: const TextStyle(fontFamily: 'Cairo',
                    fontSize: 18, fontWeight: FontWeight.w800,
                    color: AppColors.textDark)),
                const SizedBox(height: 6),
                Text(c.description, style: const TextStyle(
                    fontFamily: 'Cairo', fontSize: 13,
                    color: AppColors.textGrey, height: 1.4)),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Text('\$${c.raised.toStringAsFixed(0)} Raised',
                        style: const TextStyle(fontFamily: 'Cairo',
                            fontSize: 14, fontWeight: FontWeight.w800,
                            color: AppColors.textDark)),
                    const Spacer(),
                    Text('${c.progressPct}% of \$${c.goal.toStringAsFixed(0)}',
                        style: const TextStyle(fontFamily: 'Cairo',
                            fontSize: 12, color: AppColors.textGrey)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: c.progress,
                    backgroundColor: AppColors.borderLight,
                    color: AppColors.primaryDark,
                    minHeight: 7,
                  ),
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () => _showContributeDialog(c),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: const Center(child: Text('Contribute',
                        style: TextStyle(fontFamily: 'Cairo', fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textWhite))),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showContributeDialog(CharityModel c) {
    final amountCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Contribute to ${c.title}',
            style: const TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter amount to contribute (\$):', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textGrey)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.bgWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: TextField(
                controller: amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'e.g. 50',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(fontFamily: 'Cairo', color: AppColors.textGrey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            onPressed: () async {
              final val = double.tryParse(amountCtrl.text) ?? 0.0;
              if (val > 0) {
                await _svc.contributeToCharity(c.id, val);
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('JazakAllah! Thank you for donating \$${val.toStringAsFixed(0)} to ${c.title}.',
                        style: const TextStyle(fontFamily: 'Cairo', color: Colors.white)),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: const Text('Contribute', style: TextStyle(fontFamily: 'Cairo', color: AppColors.gold, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _submitCampaign(Map<String, dynamic> data) async {
    try {
      await _svc.submitCharity(
        title: data['title'],
        description: data['description'],
        category: data['category'],
        goal: data['goal'],
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Campaign submitted for review!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit: $e')),
        );
      }
    }
  }

  void _showCreateCharitySheet(BuildContext context) {
    final titleCtrl = TextEditingController();
    final descCtrl  = TextEditingController();
    final goalCtrl  = TextEditingController();
    String category = 'Education';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgCream,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setBS) => SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
              20, 16, 20, MediaQuery.of(ctx2).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 44, height: 4,
                  decoration: BoxDecoration(color: AppColors.borderLight,
                      borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              const Text('Create Charity Campaign', style: TextStyle(
                fontFamily: 'Cairo', fontSize: 17,
                fontWeight: FontWeight.w700, color: AppColors.textDark,
              )),
              const SizedBox(height: 6),
              const Text('Will be sent to admin for approval.',
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 12,
                      color: AppColors.textGrey)),
              const SizedBox(height: 14),
              _sheetField('Campaign Title', titleCtrl),
              const SizedBox(height: 10),
              _sheetField('Description', descCtrl, maxLines: 3),
              const SizedBox(height: 10),
              _sheetField('Fundraising Goal (\$)', goalCtrl),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: category,
                decoration: InputDecoration(
                  filled: true, fillColor: AppColors.bgWhite,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.borderLight),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                ),
                items: ['Education', 'Health', 'Relief', 'Masjid', 'Orphans']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c,
                    style: const TextStyle(fontFamily: 'Cairo'))))
                    .toList(),
                onChanged: (v) => setBS(() => category = v!),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: () async {
                      final goalText = goalCtrl.text.trim();
                      if (titleCtrl.text.trim().isEmpty || goalText.isEmpty) return;
                      _submitCampaign({
                        'title': titleCtrl.text.trim(),
                        'description': descCtrl.text.trim(),
                        'goal': double.tryParse(goalText) ?? 0.0,
                        'category': category,
                      });
                    },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: const Center(child: Text('Submit for Approval',
                        style: TextStyle(fontFamily: 'Cairo', fontSize: 15,
                            fontWeight: FontWeight.w700, color: AppColors.gold))),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sheetField(String hint, TextEditingController ctrl,
      {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: hint.contains('\$')
            ? TextInputType.number : TextInputType.text,
        style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 14,
              color: AppColors.textLightGrey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 12),
        ),
      ),
    );
  }
}
