// lib/widgets/topic_card.dart
// =============================================================================
// Floating splash card — one 165x132 rounded tile with a 42x42 icon box,
// a title line and a subtitle line, all Poppins. Pure widget, no image.
// No BackdropFilter (costs frame rate for no gain here). The parent screen
// owns positioning (Positioned) and motion; this widget only draws the tile.
// =============================================================================

import 'package:flutter/material.dart';
import 'ask_iman_logo.dart';

class TopicCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const TopicCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 165,
      height: 132,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xF2FFFFFA),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0x40DCCDA5), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A283C2D),
            blurRadius: 30,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CardIconBox(icon: icon),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.visible,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: SplashPalette.green,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.visible,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13.5,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF4A6B5C),
                    height: 1.1,
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

/// A 42x42 rounded icon chip used inside the card, keeping the icon centred
/// in its box while allowing an optional soft square background.
class CardIconBox extends StatelessWidget {
  final IconData icon;
  const CardIconBox({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 42,
      height: 42,
      child: Center(
        child: Icon(icon, size: 26, color: SplashPalette.green),
      ),
    );
  }
}