import 'package:flutter/material.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';

class FlyingBetController {
  static final FlyingBetController instance = FlyingBetController._();
  FlyingBetController._();

  OverlayEntry? _overlayEntry;
  final GlobalKey betSlipIconKey = GlobalKey();
  final GlobalKey collapsedTicketKey = GlobalKey();

  bool collapsedTicketActive = false;

  final GlobalKey desktopBettingBadgeKey = GlobalKey();

  final GlobalKey bettingSlipTabKey = GlobalKey();

  void fly({
    required BuildContext context,
    required Offset sourcePosition,
    required Size sourceSize,
    required String label,
    required String value,
  }) {
    final targetPosition =
        _getBettingSlipTabPosition() ??
        _getDesktopBettingBadgePosition() ??
        _getCollapsedTicketPosition() ??
        _getBetSlipIconPosition();
    if (targetPosition == null) {
      debugPrint('[FlyingBet] Target position not found');
      return;
    }

    _overlayEntry?.remove();

    _overlayEntry = OverlayEntry(
      builder: (context) => _FlyingBetWidget(
        sourcePosition: sourcePosition,
        sourceSize: sourceSize,
        targetPosition: targetPosition,
        label: label,
        value: value,
        onComplete: () {
          _overlayEntry?.remove();
          _overlayEntry = null;
        },
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  Offset? _getBetSlipIconPosition() {
    final renderBox =
        betSlipIconKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return null;

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    return Offset(position.dx + size.width / 2, position.dy + size.height / 2);
  }

  Offset? _getCollapsedTicketPosition() {
    if (!collapsedTicketActive) return null;
    final renderBox =
        collapsedTicketKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return null;

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    return Offset(position.dx + size.width / 2, position.dy + size.height / 2);
  }

  Offset? _getBettingSlipTabPosition() {
    final renderBox =
        bettingSlipTabKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return null;

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    return Offset(position.dx + size.width / 2, position.dy + size.height / 2);
  }

  Offset? _getDesktopBettingBadgePosition() {
    final renderBox =
        desktopBettingBadgeKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return null;

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    return Offset(position.dx + size.width / 2, position.dy + size.height / 2);
  }
}

class _FlyingBetWidget extends StatefulWidget {
  final Offset sourcePosition;
  final Size sourceSize;
  final Offset targetPosition;
  final String label;
  final String value;
  final VoidCallback onComplete;

  const _FlyingBetWidget({
    required this.sourcePosition,
    required this.sourceSize,
    required this.targetPosition,
    required this.label,
    required this.value,
    required this.onComplete,
  });

  @override
  State<_FlyingBetWidget> createState() => _FlyingBetWidgetState();
}

class _FlyingBetWidgetState extends State<_FlyingBetWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  late Widget _cachedBetCard;

  @override
  void initState() {
    super.initState();

    _cachedBetCard = _buildBetCard();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.3).animate(_controller);

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.linear),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward().then((_) {
        widget.onComplete();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;

        final currentX =
            widget.sourcePosition.dx +
            (widget.targetPosition.dx - widget.sourcePosition.dx) * t;
        final currentY =
            widget.sourcePosition.dy +
            (widget.targetPosition.dy - widget.sourcePosition.dy) * t;

        return Positioned(
          left:
              currentX - (widget.sourceSize.width * _scaleAnimation.value) / 2,
          top:
              currentY - (widget.sourceSize.height * _scaleAnimation.value) / 2,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.scale(scale: _scaleAnimation.value, child: child),
          ),
        );
      },
      child: _cachedBetCard,
    );
  }

  Widget _buildBetCard() {
    return RepaintBoundary(
      child: Container(
        width: widget.sourceSize.width,
        height: widget.sourceSize.height,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF9BF5A),
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Color(0x80F9BF5A),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (widget.label.isNotEmpty)
              Flexible(
                child: Text(
                  widget.label,
                  style: AppTextStyles.textStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            const Spacer(),
            Text(
              widget.value,
              style: AppTextStyles.displayStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
