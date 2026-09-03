// lib/web/widgets/web_animations.dart
// ─────────────────────────────────────────────────────────────────────────────
// ASK IMAN WEBSITE — Animation utilities
//
// Reusable animation widgets and extensions for the Islamic website.
// Uses flutter_animate for declarative animations + custom widgets
// for scroll-triggered reveals, shimmer loading, and micro-interactions.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/figma_tokens.dart';

// ══════════════════════════════════════════════════════════════════════════════
// SCROLL REVEAL — fades + slides up when scrolled into viewport
// ══════════════════════════════════════════════════════════════════════════════

class ScrollReveal extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset slideOffset;
  final bool autoStart;

  const ScrollReveal({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 500),
    this.slideOffset = const Offset(0, 30),
    this.autoStart = false,
  });

  @override
  State<ScrollReveal> createState() => _ScrollRevealState();
}

class _ScrollRevealState extends State<ScrollReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    if (widget.autoStart) {
      _controller.forward();
      _hasAnimated = true;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    if (reduceMotion || _hasAnimated) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: _controller, curve: Curves.easeOut),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: widget.slideOffset,
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic)),
          child: widget.child,
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (_hasAnimated) return false;
        if (notification is ScrollUpdateNotification ||
            notification is ScrollEndNotification) {
          _checkVisibility();
        }
        return false;
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _checkVisibility();
          });
          return widget.child;
        },
      ),
    );
  }

  void _checkVisibility() {
    if (_hasAnimated || !mounted) return;
    final box = context.findRenderObject();
    if (box == null || box is! RenderBox) return;
    final size = box.size;
    final position = box.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(context).size.height;
    if (position.dy < screenHeight * 0.85 && position.dy + size.height > 0) {
      _hasAnimated = true;
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// STAGGERED GRID — children entrance with incremental delays
// ══════════════════════════════════════════════════════════════════════════════

class StaggeredEntrance extends StatelessWidget {
  final List<Widget> children;
  final Duration staggerDelay;
  final Duration childDuration;
  final Offset slideOffset;
  final Axis direction;

  const StaggeredEntrance({
    super.key,
    required this.children,
    this.staggerDelay = const Duration(milliseconds: 80),
    this.childDuration = const Duration(milliseconds: 450),
    this.slideOffset = const Offset(0, 25),
    this.direction = Axis.vertical,
  });

  @override
  Widget build(BuildContext context) {
    return ScrollReveal(
      duration: Duration(
        milliseconds: childDuration.inMilliseconds + children.length * staggerDelay.inMilliseconds,
      ),
      slideOffset: Offset.zero,
      child: _StaggeredBody(
        children: children,
        staggerDelay: staggerDelay,
        childDuration: childDuration,
        slideOffset: slideOffset,
        direction: direction,
      ),
    );
  }
}

class _StaggeredBody extends StatefulWidget {
  final List<Widget> children;
  final Duration staggerDelay;
  final Duration childDuration;
  final Offset slideOffset;
  final Axis direction;

  const _StaggeredBody({
    required this.children,
    required this.staggerDelay,
    required this.childDuration,
    required this.slideOffset,
    required this.direction,
  });

  @override
  State<_StaggeredBody> createState() => _StaggeredBodyState();
}

class _StaggeredBodyState extends State<_StaggeredBody>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    final totalDuration = widget.children.length * widget.staggerDelay.inMilliseconds;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: totalDuration + widget.childDuration.inMilliseconds),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasAnimated) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _checkVisibility());
    }
    return widget.direction == Axis.vertical
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(widget.children.length, (i) {
              return _buildAnimatedChild(i, widget.children[i]);
            }),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(widget.children.length, (i) {
              return Expanded(child: _buildAnimatedChild(i, widget.children[i]));
            }),
          );
  }

  Widget _buildAnimatedChild(int index, Widget child) {
    final start = index * widget.staggerDelay.inMilliseconds / _controller.duration!.inMilliseconds;
    final end = math.min((index * widget.staggerDelay.inMilliseconds + widget.childDuration.inMilliseconds) / _controller.duration!.inMilliseconds, 1.0);
    final interval = Interval(start, end.clamp(0.0, 1.0), curve: Curves.easeOut);
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _controller,
        curve: interval,
      ),
      child: SlideTransition(
        position: Tween<Offset>(begin: widget.slideOffset, end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(start, end.clamp(0.0, 1.0), curve: Curves.easeOutCubic),
          ),
        ),
        child: child,
      ),
    );
  }

  void _checkVisibility() {
    if (_hasAnimated || !mounted) return;
    final box = context.findRenderObject();
    if (box == null || box is! RenderBox) return;
    final position = box.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(context).size.height;
    if (position.dy < screenHeight * 0.85 && position.dy + box.size.height > 0) {
      _hasAnimated = true;
      _controller.forward();
    }
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SHIMMER BOX — skeleton loading placeholder
// ══════════════════════════════════════════════════════════════════════════════

class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    this.width = double.infinity,
    this.height = 20,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? FigmaTokens.darkCard : FigmaTokens.surfacePanelMint;
    final highlightColor = isDark
        ? FigmaTokens.darkSurface
        : FigmaTokens.surfaceBackgroundAlt;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Multiple shimmer lines stacked
class ShimmerLines extends StatelessWidget {
  final int lineCount;
  final double lineHeight;
  final double spacing;
  final List<double>? widths;

  const ShimmerLines({
    super.key,
    this.lineCount = 3,
    this.lineHeight = 14,
    this.spacing = 10,
    this.widths,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(lineCount, (i) {
        final w = widths != null && i < widths!.length ? widths![i] : double.infinity;
        return Padding(
          padding: EdgeInsets.only(bottom: i < lineCount - 1 ? spacing : 0),
          child: ShimmerBox(width: w, height: lineHeight),
        );
      }),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// GOLD REVEAL — accent bar that animates width from 0 to target
// ══════════════════════════════════════════════════════════════════════════════

class GoldReveal extends StatefulWidget {
  final double width;
  final double height;
  final Duration duration;
  final Duration delay;

  const GoldReveal({
    super.key,
    this.width = 72,
    this.height = 3,
    this.duration = const Duration(milliseconds: 600),
    this.delay = Duration.zero,
  });

  @override
  State<GoldReveal> createState() => _GoldRevealState();
}

class _GoldRevealState extends State<GoldReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!_hasAnimated) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _checkVisibility());
        }
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Container(
              width: widget.width * _controller.value,
              height: widget.height,
              decoration: BoxDecoration(
                gradient: FigmaTokens.progressGradient,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          },
        );
      },
    );
  }

  void _checkVisibility() {
    if (_hasAnimated || !mounted) return;
    final box = context.findRenderObject();
    if (box == null || box is! RenderBox) return;
    final position = box.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(context).size.height;
    if (position.dy < screenHeight * 0.9) {
      _hasAnimated = true;
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// ANIMATED COUNTER — counts up from 0 to target
// ══════════════════════════════════════════════════════════════════════════════

class AnimatedCounter extends StatefulWidget {
  final int target;
  final Duration duration;
  final TextStyle? style;
  final String suffix;

  const AnimatedCounter({
    super.key,
    required this.target,
    this.duration = const Duration(milliseconds: 1200),
    this.style,
    this.suffix = '',
  });

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = Tween<double>(begin: 0, end: widget.target.toDouble()).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasAnimated) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _checkVisibility());
    }
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text(
          '${_animation.value.round()}${widget.suffix}',
          style: widget.style,
        );
      },
    );
  }

  void _checkVisibility() {
    if (_hasAnimated || !mounted) return;
    final box = context.findRenderObject();
    if (box == null || box is! RenderBox) return;
    final position = box.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(context).size.height;
    if (position.dy < screenHeight * 0.9) {
      _hasAnimated = true;
      _controller.forward();
    }
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// HOVER GLOW — Enhanced HoverLift with gold glow shadow on hover
// ══════════════════════════════════════════════════════════════════════════════

class HoverGlow extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double lift;
  final Color glowColor;

  const HoverGlow({
    super.key,
    required this.child,
    this.onTap,
    this.lift = 1.015,
    this.glowColor = const Color(0x1AC9962C),
  });

  @override
  State<HoverGlow> createState() => _HoverGlowState();
}

class _HoverGlowState extends State<HoverGlow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered ? widget.lift : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(FigmaTokens.radiusCard),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: widget.glowColor,
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(FigmaTokens.radiusCard),
              splashColor: FigmaTokens.accentGoldAmber.withOpacity(0.1),
              highlightColor: FigmaTokens.accentGoldAmber.withOpacity(0.04),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// PULSE GLOW — gold glow ring that expands and fades on tap
// ══════════════════════════════════════════════════════════════════════════════

class PulseGlow extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Duration duration;

  const PulseGlow({
    super.key,
    required this.child,
    this.onTap,
    this.duration = const Duration(milliseconds: 400),
  });

  @override
  State<PulseGlow> createState() => _PulseGlowState();
}

class _PulseGlowState extends State<PulseGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _glowOpacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _glowOpacity = Tween<double>(begin: 0.5, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _pulse() {
    _controller.forward(from: 0);
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(FigmaTokens.radiusCard),
              boxShadow: [
                BoxShadow(
                  color: FigmaTokens.accentGoldAmber.withOpacity(_glowOpacity.value),
                  blurRadius: 16 * _glowOpacity.value + 4,
                  spreadRadius: 2 * _glowOpacity.value,
                ),
              ],
            ),
            child: widget.child,
          ),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// PAGE TRANSITIONS — smooth fade + slide for route navigation
// ══════════════════════════════════════════════════════════════════════════════

class WebPageTransition {
  static PageRouteBuilder<T> slideFade<T>({required Widget page, Duration? duration}) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration ?? const Duration(milliseconds: 250),
      reverseTransitionDuration: duration ?? const Duration(milliseconds: 200),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curved),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.04),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// RESPONSIVE SCROLL PHYSICS — platform-aware scroll behavior
// ══════════════════════════════════════════════════════════════════════════════

ScrollPhysics get webScrollPhysics {
  if (kIsWeb) {
    return const ClampingScrollPhysics();
  }
  return const BouncingScrollPhysics();
}

// ══════════════════════════════════════════════════════════════════════════════
// SECTION FADE-IN — wraps a section with scroll-triggered fade
// ══════════════════════════════════════════════════════════════════════════════

class SectionFadeIn extends StatelessWidget {
  final Widget child;
  final Duration delay;
  final double slideDistance;

  const SectionFadeIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.slideDistance = 20,
  });

  @override
  Widget build(BuildContext context) {
    return ScrollReveal(
      delay: delay,
      duration: const Duration(milliseconds: 500),
      slideOffset: Offset(0, slideDistance),
      child: child,
    );
  }
}
