import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/ask_iman_app_bar.dart';
import '../auth/sign_in_screen.dart';
import 'charity_service.dart';
import 'charity_detail_screen.dart';

class MyCharityScreen extends StatelessWidget {
  const MyCharityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final svc = CharityService.instance;
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return Scaffold(
        backgroundColor: AppColors.bgCream,
        appBar: const AskImanAppBar(title: 'My Charity'),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock_outline,
                size: 64,
                color: AppColors.textGrey,
              ),
              const SizedBox(height: 16),
              const Text(
                'Sign in to manage your charity',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  color: AppColors.textGrey,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const SignInScreen())),
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
      appBar: const AskImanAppBar(title: 'My Charity'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'My Causes',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryDarkest,
            ),
          ),
          const SizedBox(height: 8),
          StreamBuilder<List<CharityCause>>(
            stream: svc.watchMyCauses(),
            builder: (ctx, snap) {
              final list = snap.data ?? [];
              if (list.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.only(top: 20, bottom: 20),
                  child: Text(
                    'You haven\'t created any causes yet',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      color: AppColors.textGrey,
                    ),
                  ),
                );
              }
              return Column(
                children: list
                    .map(
                      (c) => Card(
                        color: AppColors.primaryDark,
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Text(
                            c.title,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textWhite,
                            ),
                          ),
                          subtitle: Text(
                            '\$${c.raised.toStringAsFixed(0)} raised',
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 11,
                              color: AppColors.textGreenMuted,
                            ),
                          ),
                          trailing: Text(
                            '${c.progressPct}%',
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.gold,
                            ),
                          ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  CharityDetailScreen(causeId: c.id),
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 20),
          const Text(
            'My Donations',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryDarkest,
            ),
          ),
          const SizedBox(height: 8),
          StreamBuilder<List<CharityDonation>>(
            stream: svc.watchMyDonations(),
            builder: (ctx, snap) {
              final list = snap.data ?? [];
              if (list.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text(
                    'No donations yet',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      color: AppColors.textGrey,
                    ),
                  ),
                );
              }
              return Column(
                children: list
                    .map(
                      (d) => Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryDark,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.favorite,
                              size: 16,
                              color: AppColors.gold,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                d.anonymous ? 'Anonymous' : d.userName,
                                style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 12,
                                  color: AppColors.textGreenMuted,
                                ),
                              ),
                            ),
                            Text(
                              '\$${d.amount.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.gold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 20),
          const Text(
            'My Requests',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryDarkest,
            ),
          ),
          const SizedBox(height: 8),
          StreamBuilder<List<CharityRequest>>(
            stream: svc.watchMyRequests(),
            builder: (ctx, snap) {
              final list = snap.data ?? [];
              if (list.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text(
                    'No requests submitted',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      color: AppColors.textGrey,
                    ),
                  ),
                );
              }
              return Column(
                children: list
                    .map(
                      (r) => Card(
                        color: AppColors.primaryDark,
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Text(
                            r.title,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textWhite,
                            ),
                          ),
                          subtitle: Text(
                            '\$${r.amountReceived.toStringAsFixed(0)} / \$${r.amountNeeded.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 11,
                              color: AppColors.textGreenMuted,
                            ),
                          ),
                          trailing: Text(
                            r.status,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12,
                              color: AppColors.gold,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
