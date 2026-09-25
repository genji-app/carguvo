import 'package:flutter/material.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/features/game/banner/casino_provider_info.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class ProviderLogoItem extends StatefulWidget {
  const ProviderLogoItem({
    required this.info,
    super.key,
    this.size = 72,
    this.onTap,
  });

  final CasinoProviderInfo info;
  final double size;
  final ValueChanged<CasinoProviderInfo>? onTap;

  @override
  State<ProviderLogoItem> createState() => _ProviderLogoItemState();
}

class _ProviderLogoItemState extends State<ProviderLogoItem> {
  bool _isHovered = false;
  bool _isPressed = false;

  double get _targetScale {
    if (_isPressed) return 0.95;
    if (_isHovered) return 1.15;
    return 1.0;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : MouseCursor.defer,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) {
        if (_isHovered || _isPressed) {
          setState(() {
            _isHovered = false;
            _isPressed = false;
          });
        }
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap != null
            ? SoundTap.wrap(() => widget.onTap!(widget.info))
            : null,
        child: RepaintBoundary(
          child: AnimatedScale(
            scale: _targetScale,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            child: SizedBox(
              width: widget.size,
              height: widget.size,
              child: ImageHelper.load(
                path: widget.info.imageAsset,
                width: widget.size,
                height: widget.size,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
