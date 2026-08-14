import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AskImanCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? color;
  final List<BoxShadow>? boxShadow;
  final Border? border;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final Clip clipBehavior;
  final Gradient? gradient;
  final AlignmentGeometry alignment;

  const AskImanCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.borderRadius = 16,
    this.color,
    this.boxShadow,
    this.border,
    this.width,
    this.height,
    this.onTap,
    this.clipBehavior = Clip.antiAlias,
    this.gradient,
    this.alignment = Alignment.topLeft,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = color ?? (isDark ? AppColors.darkCard : AppColors.lightCard);
    final defaultBorder = border ??
        Border.all(
          color: isDark ? AppColors.darkBorder.withValues(alpha: 0.5) : Colors.transparent,
          width: isDark ? 0.5 : 0,
        );
    final defaultShadow = boxShadow ??
        (isDark
            ? <BoxShadow>[]
            : <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                  spreadRadius: 0,
                ),
              ]);

    final container = Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      alignment: alignment,
      decoration: BoxDecoration(
        color: gradient != null ? null : cardColor,
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        border: defaultBorder,
        boxShadow: defaultShadow,
      ),
      clipBehavior: clipBehavior,
      child: child,
    );

    if (onTap == null) return container;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(borderRadius),
      child: container,
    );
  }
}

class AskImanGoldBorderCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final VoidCallback? onTap;
  const AskImanGoldBorderCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.borderRadius = 16,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AskImanCard(
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      onTap: onTap,
      color: isDark ? AppColors.darkBgSurface : AppColors.goldSurface.withValues(alpha: 0.3),
      border: Border.all(color: AppColors.gold.withValues(alpha: 0.6), width: 1),
      boxShadow: const [],
      child: child,
    );
  }
}
