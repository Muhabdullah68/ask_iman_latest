import 'package:flutter/material.dart';
import '../../core/services/tutorial_service.dart';
import 'tooltip_arrow_painter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/l10n/app_localizations.dart';

class TooltipOverlay extends StatefulWidget {
  final Widget child;
  final String id;
  final String title;
  final String description;
  final TooltipArrowDirection arrowDirection;
  final Offset offset;
  final VoidCallback? onNext;

  const TooltipOverlay({
    super.key,
    required this.child,
    required this.id,
    required this.title,
    required this.description,
    this.arrowDirection = TooltipArrowDirection.down,
    this.offset = const Offset(0, 0),
    this.onNext,
  });

  @override
  State<TooltipOverlay> createState() => _TooltipOverlayState();
}

class _TooltipOverlayState extends State<TooltipOverlay>
    with SingleTickerProviderStateMixin {
  final GlobalKey _childKey = GlobalKey();
  final OverlayPortalController _overlayController = OverlayPortalController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    TutorialService.instance.addListener(_onTutorialChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncOverlay());
  }

  @override
  void dispose() {
    TutorialService.instance.removeListener(_onTutorialChanged);
    _animationController.dispose();
    super.dispose();
  }

  void _onTutorialChanged() {
    if (mounted) _syncOverlay();
  }

  void _syncOverlay() {
    final svc = TutorialService.instance;
    final shouldShow = svc.isActive && svc.currentStepId == widget.id;
    if (shouldShow && !_overlayController.isShowing) {
      _overlayController.show();
      _animationController.forward();
    } else if (!shouldShow && _overlayController.isShowing) {
      _animationController.reverse().then((_) {
        if (_overlayController.isShowing) {
          _overlayController.hide();
        }
      });
    }
  }

  void _handleNext() {
    if (widget.onNext != null) {
      widget.onNext!();
    } else {
      TutorialService.instance.next();
    }
  }

  void _handleSkipAll() {
    TutorialService.instance.skipAll();
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _overlayController,
      overlayChildBuilder: (BuildContext context) {
        final RenderBox? renderBox =
            _childKey.currentContext?.findRenderObject() as RenderBox?;
        if (renderBox == null) return const SizedBox.shrink();
        final size = renderBox.size;
        final offset = renderBox.localToGlobal(Offset.zero) + widget.offset;

        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () {},
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: CustomPaint(
                    painter: _HighlightPainter(rect: offset & size),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 50,
              right: 16,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: TextButton(
                  onPressed: _handleSkipAll,
                  child: Text(
                    'Skip All',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            _buildTooltipBubble(offset, size, context),
          ],
        );
      },
      child: KeyedSubtree(key: _childKey, child: widget.child),
    );
  }

  Widget _buildTooltipBubble(
    Offset targetOffset,
    Size targetSize,
    BuildContext context,
  ) {
    final screenSize = MediaQuery.of(context).size;
    const bubbleWidth = 300.0;
    const arrowSize = Size(20, 12);
    const bubblePadding = EdgeInsets.all(16);
    const bubbleMargin = 16.0;

    final loc = AppLocalizations.of(context);
    final totalSteps = TutorialService.tutorialSequence.length;
    final stepIndex = TutorialService.tutorialSequence.indexWhere(
      (s) => s.id == widget.id,
    );

    double left, top;

    final textPainter = TextPainter(
      text: TextSpan(
        children: [
          TextSpan(
            text: widget.title,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const TextSpan(text: '\n'),
          TextSpan(
            text: widget.description,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
      textDirection: TextDirection.ltr,
      maxLines: null,
    )..layout(maxWidth: bubbleWidth - bubblePadding.left - bubblePadding.right);

    final estimatedBubbleHeight = textPainter.height + 120;

    switch (widget.arrowDirection) {
      case TooltipArrowDirection.down:
        left = (targetOffset.dx + targetSize.width / 2) - bubbleWidth / 2;
        top =
            targetOffset.dy -
            bubbleMargin -
            estimatedBubbleHeight -
            arrowSize.height;
        break;
      case TooltipArrowDirection.up:
        left = (targetOffset.dx + targetSize.width / 2) - bubbleWidth / 2;
        top = targetOffset.dy + targetSize.height + bubbleMargin;
        break;
      case TooltipArrowDirection.left:
        left = targetOffset.dx + targetSize.width + bubbleMargin;
        top =
            targetOffset.dy + targetSize.height / 2 - estimatedBubbleHeight / 2;
        break;
      case TooltipArrowDirection.right:
        left = targetOffset.dx - bubbleWidth - bubbleMargin;
        top =
            targetOffset.dy + targetSize.height / 2 - estimatedBubbleHeight / 2;
        break;
    }

    left = left.clamp(
      bubbleMargin,
      screenSize.width - bubbleWidth - bubbleMargin,
    );
    top = top.clamp(100, screenSize.height - estimatedBubbleHeight - 50);

    Widget bubbleChild;

    if (widget.arrowDirection == TooltipArrowDirection.up ||
        widget.arrowDirection == TooltipArrowDirection.down) {
      bubbleChild = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.arrowDirection == TooltipArrowDirection.down)
            SizedBox(
              width: arrowSize.width,
              height: arrowSize.height,
              child: CustomPaint(
                painter: TooltipArrowPainter(
                  color: const Color(0xFF1B4332),
                  direction: AxisDirection.down,
                ),
              ),
            ),
          _buildBubbleContent(loc, stepIndex, totalSteps),
          if (widget.arrowDirection == TooltipArrowDirection.up)
            SizedBox(
              width: arrowSize.width,
              height: arrowSize.height,
              child: CustomPaint(
                painter: TooltipArrowPainter(
                  color: const Color(0xFF1B4332),
                  direction: AxisDirection.up,
                ),
              ),
            ),
        ],
      );
    } else {
      bubbleChild = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.arrowDirection == TooltipArrowDirection.right)
            SizedBox(
              width: arrowSize.height,
              height: arrowSize.width,
              child: CustomPaint(
                painter: TooltipArrowPainter(
                  color: const Color(0xFF1B4332),
                  direction: AxisDirection.right,
                ),
              ),
            ),
          _buildBubbleContent(loc, stepIndex, totalSteps),
          if (widget.arrowDirection == TooltipArrowDirection.left)
            SizedBox(
              width: arrowSize.height,
              height: arrowSize.width,
              child: CustomPaint(
                painter: TooltipArrowPainter(
                  color: const Color(0xFF1B4332),
                  direction: AxisDirection.left,
                ),
              ),
            ),
        ],
      );
    }

    return Positioned(
      left: left,
      top: top,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(scale: _scaleAnimation, child: bubbleChild),
      ),
    );
  }

  Widget _buildBubbleContent(
    AppLocalizations loc,
    int stepIndex,
    int totalSteps,
  ) {
    final isLast = stepIndex == totalSteps - 1;
    return Container(
      width: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B4332),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${stepIndex + 1}/$totalSteps',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDarkest,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.description,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: _handleNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.primaryDarkest,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                isLast ? 'Got it!' : 'Next',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HighlightPainter extends CustomPainter {
  final Rect rect;

  _HighlightPainter({required this.rect});

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size)
      ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(12)));

    final Paint paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);

    final borderPaint = Paint()
      ..color = AppColors.gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(12)),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
