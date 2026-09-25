
import 'package:flutter/material.dart';
import 'package:sun_sports/shared/widgets/tooltip/overlay_tooltip/overlay_tooltip.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class BasicSmartTooltipExample extends StatelessWidget {
  const BasicSmartTooltipExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SmartTooltip(
      contentBuilder: (onClose) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'This is a smart tooltip!',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class CustomTriggerExample extends StatelessWidget {
  const CustomTriggerExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SmartTooltip(
      contentBuilder: (onClose) => TooltipContainer(
        width: 250,
        child: const Text('Tooltip with custom trigger'),
      ),
      triggerBuilder: (onTap) =>
          ElevatedButton(onPressed: SoundTap.wrap(onTap), child: const Text('Show Info')),
    );
  }
}

class ConfiguredSmartTooltipExample extends StatelessWidget {
  const ConfiguredSmartTooltipExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SmartTooltip(
      strategy: TooltipStrategy.composited,
      config: const SmartTooltipConfig(
        tooltipWidth: 300,
        arrowPosition: ArrowPosition.topLeft,
        autoCloseOnScroll: true,
        triggerSize: 20,
        triggerColor: Colors.blue,
      ),
      contentBuilder: (onClose) => TooltipContainer(
        width: 300,
        arrowPosition: ArrowPosition.topLeft,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Title', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Description text goes here'),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: SoundTap.wrap(onClose), child: const Text('Close')),
          ],
        ),
      ),
    );
  }
}

class ControlledSmartTooltipExample extends StatefulWidget {
  const ControlledSmartTooltipExample({super.key});

  @override
  State<ControlledSmartTooltipExample> createState() =>
      _ControlledSmartTooltipExampleState();
}

class _ControlledSmartTooltipExampleState
    extends State<ControlledSmartTooltipExample> {
  final _tooltipController = SmartTooltipController();

  @override
  void dispose() {
    _tooltipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SmartTooltip(
          controller: _tooltipController,
          contentBuilder: (onClose) =>
              TooltipContainer(child: const Text('Controlled tooltip')),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: SoundTap.wrap(() => _tooltipController.show()),
          child: const Text('Show from outside'),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: SoundTap.wrap(() => _tooltipController.hide()),
          child: const Text('Hide from outside'),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: SoundTap.wrap(() => _tooltipController.toggle()),
          child: const Text('Toggle'),
        ),
      ],
    );
  }
}

class SmartTooltipInListExample extends StatefulWidget {
  const SmartTooltipInListExample({super.key});

  @override
  State<SmartTooltipInListExample> createState() =>
      _SmartTooltipInListExampleState();
}

class _SmartTooltipInListExampleState extends State<SmartTooltipInListExample> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 20,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text('Item $index'),
          trailing: SmartTooltip(
            strategy: TooltipStrategy.composited,
            config: const SmartTooltipConfig(autoCloseOnScroll: true),
            contentBuilder: (onClose) => TooltipContainer(
              width: 250,
              arrowPosition: ArrowPosition.topRight,
              child: Text('Information about item $index'),
            ),
          ),
        );
      },
    );
  }
}

class PresetConfigExample extends StatelessWidget {
  const PresetConfigExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SmartTooltip(
          config: SmartTooltipConfig.compact,
          contentBuilder: (onClose) => const TooltipContainer(
            width: 250,
            child: Text('Compact tooltip'),
          ),
        ),
        const SizedBox(height: 16),

        SmartTooltip(
          config: SmartTooltipConfig.large,
          contentBuilder: (onClose) => const TooltipContainer(
            width: 400,
            child: Text('Large tooltip with more content'),
          ),
        ),
        const SizedBox(height: 16),

        SmartTooltip(
          config: SmartTooltipConfig.topAligned,
          contentBuilder: (onClose) => const TooltipContainer(
            width: 300,
            arrowPosition: ArrowPosition.bottomRight,
            child: Text('Tooltip above trigger'),
          ),
        ),
      ],
    );
  }
}

class BetSlipSmartTooltipExample extends StatelessWidget {
  const BetSlipSmartTooltipExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SmartTooltip(
      strategy: TooltipStrategy.composited,
      config: const SmartTooltipConfig(
        tooltipWidth: 326,
        arrowPosition: ArrowPosition.topRight,
        arrowOffset: 14.0,
        autoCloseOnScroll: true,
        triggerSize: 18,
        triggerPadding: EdgeInsets.all(4.0),
      ),
      contentBuilder: (onClose) {
        final hintData = _getHintData();

        return TooltipContainer(
          width: 326,
          padding: EdgeInsets.zero,
          arrowPosition: ArrowPosition.topRight,
          arrowOffset: 14.0,
          child: Text('Hint: $hintData'),
        );
      },
      triggerBuilder: (onTap) => InkWell(
        borderRadius: BorderRadius.circular(100),
        onTap: SoundTap.wrap(onTap),
        child: const Padding(
          padding: EdgeInsets.all(4.0),
          child: SizedBox.square(
            dimension: 18,
            child: Icon(Icons.info_outline, size: 18),
          ),
        ),
      ),
    );
  }

  String _getHintData() => 'Sample hint data';
}

class CustomContainerExample extends StatelessWidget {
  const CustomContainerExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SmartTooltip(
      config: SmartTooltipConfig(
        tooltipContainerBuilder: (content) => Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.purple, Colors.blue],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: content,
        ),
      ),
      contentBuilder: (onClose) => const Text(
        'Custom styled tooltip',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
