// lib/features/community/community_screen.dart
import 'package:flutter/material.dart';
import '../../core/services/community_service.dart';

class CommunityScreen extends StatelessWidget {
  final AppUser currentUser;
  const CommunityScreen({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Community Screen - Temporarily Disabled'),
      ),
    );
  }
}
