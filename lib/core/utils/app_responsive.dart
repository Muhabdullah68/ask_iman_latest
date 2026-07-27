// lib/core/utils/app_responsive.dart
// ─────────────────────────────────────────────────────────────────────────────
// APP RESPONSIVE UTILITY
//
// Usage (in any build/helper method):
//   final r = AppResponsive(context);
//
//   r.sp(14)        → scaled font size
//   r.w(16)         → scaled horizontal dimension / padding
//   r.h(20)         → scaled vertical dimension / padding
//   r.radius(12)    → scaled border radius
//   r.iconSize(24)  → scaled icon size
//   r.avatarSize(40)→ scaled avatar diameter
//   r.bottomInset   → keyboard bottom inset
//
// Design base: 390×844 (Pixel 7 / iPhone 14 logical pixels).
// Clamped so very small (<320) or very large (>430) screens stay usable.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

class AppResponsive {
  final BuildContext _ctx;
  late final double _sw;
  late final double _sh;
  late final double _sf; // width scale factor
  late final double _tf; // text scale factor

  static const double _baseW = 390.0;
  static const double _baseH = 844.0;

  AppResponsive(this._ctx) {
    final mq = MediaQuery.of(_ctx);
    _sw = mq.size.width;
    _sh = mq.size.height;
    _sf = (_sw / _baseW).clamp(0.80, 1.15);
    _tf = (_sw / _baseW).clamp(0.82, 1.10);
  }

  double get screenWidth => _sw;
  double get screenHeight => _sh;

  /// Scaled font size
  double sp(double size) => (size * _tf).roundToDouble();

  /// Scaled horizontal spacing / padding / width
  double w(double dp) => (dp * _sf).roundToDouble();

  /// Scaled vertical spacing / padding / height
  double h(double dp) =>
      (dp * (_sh / _baseH).clamp(0.80, 1.15)).roundToDouble();

  /// Scaled border radius
  double radius(double dp) => (dp * _sf).roundToDouble();

  /// Scaled icon size (clamped 12–48)
  double iconSize(double dp) => (dp * _sf).clamp(12.0, 48.0);

  /// Scaled avatar / circle diameter (clamped 24–80)
  double avatarSize(double dp) => (dp * _sf).clamp(24.0, 80.0);

  /// Keyboard inset
  double get bottomInset => MediaQuery.of(_ctx).viewInsets.bottom;

  /// Safe bottom padding
  double get bottomPadding => MediaQuery.of(_ctx).padding.bottom;

  /// Safe top padding
  double get topPadding => MediaQuery.of(_ctx).padding.top;

  bool get isSmall => _sw < 360;
  bool get isMedium => _sw >= 360 && _sw < 400;
  bool get isLarge => _sw >= 400;
}
