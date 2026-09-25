// lib/web/widgets/web_tilt3d.dart
// ─────────────────────────────────────────────────────────────────────────────
// ASK IMAN WEBSITE — 3D TILT SURFACE
//
// Gives an existing 2D surface a genuine 3D presence: the child tilts toward
// the cursor with a real perspective projection (Matrix4), eases smoothly so
// rapid cursor movement never janks, and breathes a soft gold glow+shadow
// while hovered. Purely hover-driven — idle widgets stay static (no rotating
// sacred ornament text), and reduce-motion users get the plain child.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../core/theme/figma_tokens.dart';

class Tilt3D extends StatefulWidget {
  final Widget child;
  final double maxAngle;
  final double perspective;
  final double glow;
  final BorderRadius? borderRadius;

  const Tilt3D({
    super.key,
    required this.child,
    this.maxAngle = 8,
    this.perspective = 0.0012,
    this.glow = 0.28,
    this.borderRadius,
  });

  @override
  State<Tilt3D> createState() => _Tilt3DState();
}

class _Tilt3DState extends State<Tilt3D> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  Size _size = Size.zero;
  double _rx = 0, _ry = 0, _tx = 0, _ty = 0;
  double _hover = 0, _hoverT = 0;
  bool _animating = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _ensureAnimating() {
    if (!_animating) {
      _animating = true;
      _ticker.start();
    }
  }

  void _onTick(Duration _) {
    const k = 0.26;
    _hoverT += (_hover - _hoverT) * k;
    _rx += (_tx - _rx) * k;
    _ry += (_ty - _ry) * k;
    final settled =
        (_tx - _rx).abs() < 0.02 &&
        (_ty - _ry).abs() < 0.02 &&
        (_hover - _hoverT).abs() < 0.01;
    if (settled && _hover == 0) {
      _rx = 0;
      _ry = 0;
      _hoverT = 0;
      _stopTicker();
      return;
    }
    setState(() {});
  }

  void _stopTicker() {
    _ticker.stop();
    _animating = false;
  }

  void _onHover(PointerHoverEvent e) {
    final size = _size;
    if (size.width == 0 || size.height == 0) return;
    final dx = ((e.localPosition.dx / size.width) - 0.5) * 2;
    final dy = ((e.localPosition.dy / size.height) - 0.5) * 2;
    _tx = -dy * widget.maxAngle;
    _ty = dx * widget.maxAngle;
    if (_hover == 0) _hover = 1;
    _ensureAnimating();
  }

  void _onExit(PointerExitEvent e) {
    _tx = 0;
    _ty = 0;
    _hover = 0;
    _ensureAnimating();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) return widget.child;
    return MouseRegion(
      onHover: _onHover,
      onExit: _onExit,
      child: LayoutBuilder(
        builder: (context, constraints) {
          _size = constraints.biggest;
          final hover = _hoverT;
          final matrix = Matrix4.identity()
            ..setEntry(3, 2, widget.perspective)
            ..rotateX(_rx * math.pi / 180)
            ..rotateY(_ry * math.pi / 180);
          final radius =
              widget.borderRadius ??
              BorderRadius.circular(FigmaTokens.radiusCard);
          return Container(
            foregroundDecoration: BoxDecoration(
              borderRadius: radius,
              boxShadow: [
                BoxShadow(
                  color: FigmaTokens.ornamentGold.withValues(
                    alpha: 0.16 + 0.10 * hover,
                  ),
                  blurRadius: 12 + 10 * hover,
                  spreadRadius: 1 + 2 * hover,
                ),
              ],
            ),
            child: Transform(
              transform: matrix,
              alignment: Alignment.center,
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}
