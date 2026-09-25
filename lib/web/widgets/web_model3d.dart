// lib/web/widgets/web_model3d.dart
// ─────────────────────────────────────────────────────────────────────────────
// ASK IMAN WEBSITE — INTERACTIVE 3D MODEL (glTF/GLB)
//
// Web-only embedding of a GLB asset via Google's <model-viewer>. The model
// auto-rotates gently, is draggable (camera controls), and sits in a soft gold
// glow so it reads as a sacred decorative object rather than an app gadget.
// Non-web platforms get a static gold medallion so the mobile app never pulls
// the 3D runtime into its UI. Honours reduce-motion via a much slower orbit.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import '../../core/theme/figma_tokens.dart';

class Model3D extends StatelessWidget {
  final String src;
  final String alt;
  final BorderRadius? borderRadius;

  const Model3D({
    super.key,
    required this.src,
    this.alt = '',
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final radius =
        borderRadius ?? BorderRadius.circular(FigmaTokens.radiusCard);
    if (!kIsWeb) {
      return const _ModelFallback();
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: FigmaTokens.ornamentGold.withValues(alpha: 0.25),
            blurRadius: 22,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: ModelViewer(
          key: ValueKey(src),
          src: src,
          alt: alt,
          backgroundColor: Colors.transparent,
          cameraControls: true,
          disablePan: true,
          autoRotate: true,
          rotationPerSecond: reduceMotion ? '4deg' : '18deg',
          interactionPrompt: InteractionPrompt.none,
          shadowIntensity: 1,
          shadowSoftness: 0.8,
          environmentImage: 'neutral',
          debugLogging: false,
        ),
      ),
    );
  }
}

/// Elegant static medallion used off-web (the 3D runtime is web-only).
class _ModelFallback extends StatelessWidget {
  const _ModelFallback();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 132,
        height: 132,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: FigmaTokens.ornamentGold.withValues(alpha: 0.6),
            width: 1.5,
          ),
          gradient: RadialGradient(
            colors: [
              FigmaTokens.ornamentGold.withValues(alpha: 0.18),
              FigmaTokens.ornamentGold.withValues(alpha: 0.02),
            ],
          ),
        ),
        child: Center(
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: FigmaTokens.ornamentGold.withValues(alpha: 0.35),
                width: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
