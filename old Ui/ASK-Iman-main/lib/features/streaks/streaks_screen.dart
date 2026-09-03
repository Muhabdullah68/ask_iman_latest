import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/l10n/app_localizations.dart';
import '../community/streaks/streaks_tab.dart';

class StreaksScreen extends StatelessWidget {
  const StreaksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        title: Text(
          AppLocalizations.of(context).translate('streaks'),
          style: const TextStyle(color: AppColors.gold, fontFamily: 'Cairo'),
        ),
        iconTheme: const IconThemeData(color: AppColors.gold),
        elevation: 0,
      ),
      body: const StreaksTab(currentUser: null),
    );
  }
}
