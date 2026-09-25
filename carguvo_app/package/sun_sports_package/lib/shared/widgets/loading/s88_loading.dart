import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sun_sports/core/env/app_env.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';

class S88Loading extends StatefulWidget {
  const S88Loading({
    super.key,
    this.width,
    this.height,
    this.backgroundColor = defaultBackgroundColor,
    this.indicatorSize = 150,
    this.dismissible = false,
    this.onDismiss,
    this.gifUrl,
    this.fadeDuration = const Duration(milliseconds: 500),
    this.hideSignal,
    this.onHidden,
  });

  static const Color defaultBackgroundColor = Color(0x80000000);

  final double? width;

  final double? height;

  final Color backgroundColor;

  final double indicatorSize;

  final bool dismissible;

  final VoidCallback? onDismiss;

  final String? gifUrl;

  final Duration fadeDuration;

  final ValueListenable<bool>? hideSignal;

  final VoidCallback? onHidden;

  String get _resolvedUrl => gifUrl ?? AppEnv.loadingGifUrl;

  static S88LoadingHandle show(
    BuildContext context, {
    double? width,
    double? height,
    Color backgroundColor = defaultBackgroundColor,
    double indicatorSize = 150,
    bool dismissible = false,
    VoidCallback? onDismiss,
    String? gifUrl,
    Duration fadeDuration = const Duration(milliseconds: 500),
  }) {
    final overlay =
        Overlay.maybeOf(context, rootOverlay: true) ??
        Navigator.maybeOf(context, rootNavigator: true)?.overlay;

    if (overlay == null) {
      assert(() {
        debugPrint('S88Loading.show: không tìm thấy Overlay nào từ context');
        return true;
      }());
      return S88LoadingHandle._noop();
    }

    final hideSignal = ValueNotifier<bool>(false);

    late OverlayEntry entry;
    var removed = false;
    void removeEntry() {
      if (removed) return;
      removed = true;
      entry.remove();
      hideSignal.dispose();
    }

    entry = OverlayEntry(
      builder: (_) => Positioned.fill(
        child: S88Loading(
          width: width,
          height: height,
          backgroundColor: backgroundColor,
          indicatorSize: indicatorSize,
          dismissible: dismissible,
          onDismiss: onDismiss,
          gifUrl: gifUrl,
          fadeDuration: fadeDuration,
          hideSignal: hideSignal,
          onHidden: removeEntry,
        ),
      ),
    );
    overlay.insert(entry);
    return S88LoadingHandle._(hideSignal);
  }

  @override
  State<S88Loading> createState() => _S88LoadingState();
}

class S88LoadingHandle {
  S88LoadingHandle._(this._hideSignal);

  S88LoadingHandle._noop() : _hideSignal = null;

  final ValueNotifier<bool>? _hideSignal;

  void remove() {
    final signal = _hideSignal;
    if (signal == null || signal.value) return;
    signal.value = true;
  }
}

class _S88LoadingState extends State<S88Loading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.fadeDuration,
    );
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _controller.forward();

    widget.hideSignal?.addListener(_onHideSignal);

    if (widget.hideSignal?.value ?? false) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _onHideSignal();
      });
    }
  }

  bool _hiding = false;

  void _onHideSignal() {
    if (widget.hideSignal?.value == true) {
      if (mounted && !_hiding) setState(() => _hiding = true);
      _controller.reverse().whenComplete(() => widget.onHidden?.call());
    }
  }

  @override
  void dispose() {
    widget.hideSignal?.removeListener(_onHideSignal);
    _controller.dispose();
    super.dispose();
  }

  Widget _fallback() => const SizedBox(
        width: 32,
        height: 32,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation(Color(0xFFFFB732)),
        ),
      );

  @override
  Widget build(BuildContext context) => IgnorePointer(
    ignoring: _hiding,
    child: FadeTransition(
      opacity: _opacity,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.dismissible ? widget.onDismiss : () {},
        child: Container(
          width: widget.width ?? double.infinity,
          height: widget.height ?? double.infinity,
          color: widget.backgroundColor,
          alignment: Alignment.center,
          child: ImageHelper.load(
            path: widget._resolvedUrl,
            width: widget.indicatorSize,
            height: widget.indicatorSize,
            fit: BoxFit.contain,
            placeholder: _fallback(),
            errorWidget: _fallback(),
          ),
        ),
      ),
    ),
  );
}
