import 'package:flutter/material.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class CompositedTooltipController {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  ScrollPosition? _scrollPosition;
  bool _autoCloseOnScroll = true;
  bool _isDisposed = false;

  bool get isShowing => _overlayEntry != null;

  bool get isDisposed => _isDisposed;

  void show({
    required BuildContext context,
    required Widget Function(VoidCallback onClose) builder,
    Alignment targetAnchor = Alignment.bottomRight,
    Alignment followerAnchor = Alignment.topRight,
    Offset offset = const Offset(-12, 12),
    bool autoCloseOnScroll = true,
    bool dismissOnTapOutside = true,
    bool rootOverlay = true,
  }) {
    if (_isDisposed) {
      assert(false, 'Cannot show tooltip on disposed controller');
      return;
    }

    if (!context.mounted) {
      return;
    }

    remove();

    _autoCloseOnScroll = autoCloseOnScroll;

    if (_autoCloseOnScroll) {
      _scrollPosition?.removeListener(_onScroll);
      _scrollPosition = Scrollable.maybeOf(context)?.position;
      _scrollPosition?.addListener(_onScroll);
    }

    _overlayEntry = OverlayEntry(
      builder: (overlayContext) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: SoundTap.wrap(dismissOnTapOutside ? remove : null),
          child: Stack(
            children: [
              CompositedTransformFollower(
                link: _layerLink,
                targetAnchor: targetAnchor,
                followerAnchor: followerAnchor,
                offset: offset,
                child: Material(
                  color: Colors.transparent,
                  child: GestureDetector(
                    onTap: SoundTap.wrap(() {}),
                    child: builder(remove),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    try {
      Overlay.of(context, rootOverlay: rootOverlay).insert(_overlayEntry!);
    } catch (e) {
      _overlayEntry = null;
      _scrollPosition?.removeListener(_onScroll);
      _scrollPosition = null;
    }
  }

  void remove() {
    if (_isDisposed) return;

    _scrollPosition?.removeListener(_onScroll);
    _scrollPosition = null;
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Widget wrapTarget({required Widget child}) {
    if (_isDisposed) {
      return child;
    }
    return CompositedTransformTarget(link: _layerLink, child: child);
  }

  void _onScroll() {
    if (_autoCloseOnScroll && isShowing) {
      remove();
    }
  }

  void dispose() {
    if (_isDisposed) return;

    remove();
    _isDisposed = true;
  }
}
