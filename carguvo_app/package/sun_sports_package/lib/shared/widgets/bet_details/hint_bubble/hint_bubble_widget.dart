import 'package:flutter/material.dart';
import 'hint_data.dart';
import 'hint_content_widget.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class HintColors {
  HintColors._();

  static const bubbleBackground = Color(0xFF2A2A2A);
  static const bubbleBorder = Color(0xFFFEE4B1);

  static const titleColor = Color(0xFFFEE4B1);
  static const simpleColor = Color(0xFFFFE991);
  static const teamColor = Color(0xFFFBB877);
  static const highlightColor = Color(0xFFFFE991);
  static const positiveColor = Color(0xFF2E90FA);
  static const negativeColor = Color(0xFFF63D68);
  static const defaultText = Colors.white;
}

class HintBubbleWidget extends StatefulWidget {
  final HintData hintData;
  final String? titleOverride;
  final VoidCallback onClose;

  const HintBubbleWidget({
    required this.hintData,
    required this.onClose,
    super.key,
    this.titleOverride,
  });

  @override
  State<HintBubbleWidget> createState() => _HintBubbleWidgetState();
}

class _HintBubbleWidgetState extends State<HintBubbleWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _close() async {
    await _controller.reverse();
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: _buildContent(),
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    return Container(
      margin: const EdgeInsets.all(16),
      constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
      decoration: BoxDecoration(
        color: HintColors.bubbleBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: HintColors.bubbleBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(right: 24),
                child: HintContentWidget(
                  hintData: widget.hintData,
                  titleOverride: widget.titleOverride,
                ),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: SoundTap.wrap(_close),
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showHintBubble({
  required BuildContext context,
  required HintData hintData,
  String? titleOverride,
}) async {
  return showDialog(
    context: context,
    barrierColor: Colors.black54,
    barrierDismissible: true,
    builder: (context) => Center(
      child: HintBubbleWidget(
        hintData: hintData,
        titleOverride: titleOverride,
        onClose: () => Navigator.of(context).pop(),
      ),
    ),
  );
}
