
import 'package:flutter/material.dart';
import 'package:sun_sports/shared/widgets/tooltip/overlay_tooltip/overlay_tooltip.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class SimpleTooltipButton extends StatefulWidget {
  const SimpleTooltipButton({super.key});

  @override
  State<SimpleTooltipButton> createState() => _SimpleTooltipButtonState();
}

class _SimpleTooltipButtonState extends State<SimpleTooltipButton> {
  final _tooltipController = CompositedTooltipController();

  @override
  void dispose() {
    _tooltipController.dispose();
    super.dispose();
  }

  void _showTooltip() {
    _tooltipController.show(
      context: context,
      builder: (onClose) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'This is a tooltip!',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _tooltipController.wrapTarget(
      child: IconButton(onPressed: SoundTap.wrap(_showTooltip), icon: const Icon(Icons.info)),
    );
  }
}

class CustomPositionTooltip extends StatefulWidget {
  const CustomPositionTooltip({super.key});

  @override
  State<CustomPositionTooltip> createState() => _CustomPositionTooltipState();
}

class _CustomPositionTooltipState extends State<CustomPositionTooltip> {
  final _tooltipController = CompositedTooltipController();

  @override
  void dispose() {
    _tooltipController.dispose();
    super.dispose();
  }

  void _showTooltip() {
    _tooltipController.show(
      context: context,
      targetAnchor: Alignment.topCenter,
      followerAnchor: Alignment.bottomCenter,
      offset: const Offset(0, -8),
      autoCloseOnScroll: true,
      builder: (onClose) => const TooltipContainer(
        width: 200,
        arrowPosition: ArrowPosition.bottom,
        child: Text('Tooltip above button'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _tooltipController.wrapTarget(
      child: ElevatedButton(
        onPressed: SoundTap.wrap(_showTooltip),
        child: const Text('Show Tooltip'),
      ),
    );
  }
}

class TooltipInList extends StatefulWidget {
  const TooltipInList({super.key});

  @override
  State<TooltipInList> createState() => _TooltipInListState();
}

class _TooltipInListState extends State<TooltipInList> {
  final List<CompositedTooltipController> _controllers = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 20; i++) {
      _controllers.add(CompositedTooltipController());
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _showTooltip(int index) {
    _controllers[index].show(
      context: context,
      autoCloseOnScroll: true,
      builder: (onClose) => TooltipContainer(
        width: 250,
        arrowPosition: ArrowPosition.topRight,
        arrowOffset: 14.0,
        child: Text('Tooltip for item $index'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 20,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text('Item $index'),
          trailing: _controllers[index].wrapTarget(
            child: IconButton(
              onPressed: SoundTap.wrap(() => _showTooltip(index)),
              icon: const Icon(Icons.help_outline),
            ),
          ),
        );
      },
    );
  }
}

class BetSlipExplanationButtonExample extends StatefulWidget {
  const BetSlipExplanationButtonExample({super.key});

  @override
  State<BetSlipExplanationButtonExample> createState() =>
      _BetSlipExplanationButtonExampleState();
}

class _BetSlipExplanationButtonExampleState
    extends State<BetSlipExplanationButtonExample> {

  final _tooltipController = CompositedTooltipController();

  @override
  void dispose() {
    _tooltipController.dispose();
    super.dispose();
  }

  void _showTooltip() {
    final hintData = _getHintData();
    if (hintData == null) return;

    const tooltipWidth = 326.0;

    _tooltipController.show(
      context: context,
      targetAnchor: Alignment.bottomRight,
      followerAnchor: Alignment.topRight,
      offset: const Offset(-12, 12),
      autoCloseOnScroll: true,
      builder: (onClose) => TooltipContainer(
        width: tooltipWidth,
        padding: EdgeInsets.zero,
        arrowPosition: ArrowPosition.topRight,
        arrowOffset: 14.0,
        child: Text('Hint: $hintData'),
      ),
    );
  }

  dynamic _getHintData() => 'Sample hint data';

  @override
  Widget build(BuildContext context) {
    return _tooltipController.wrapTarget(
      child: IconButton(onPressed: SoundTap.wrap(_showTooltip), icon: const Icon(Icons.info)),
    );
  }
}
