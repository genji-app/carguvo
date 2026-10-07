part of 'network_asset.dart';

class _NetworkPlaceholder extends StatelessWidget {
  final Widget? placeholder;
  final double? width;
  final double? height;

  const _NetworkPlaceholder({this.placeholder, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    if (placeholder != null) return placeholder!;

    return SizedBox(
      width: width,
      height: height,
      child: Center(
        child: CupertinoActivityIndicator(
          color: AppColorStyles.contentSecondary,
          radius: (width != null && width! < 40) ? 8 : 12,
        ),
      ),
    );
  }
}

class _NetworkErrorWidget extends StatelessWidget {
  final Widget? errorWidget;
  final double? width;
  final double? height;

  const _NetworkErrorWidget({this.errorWidget, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return errorWidget ??
        Container(
          width: width,
          height: height ?? 144,
          decoration: BoxDecoration(
            color: AppColorStyles.backgroundPrimary,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Icon(
              Icons.error,
              color: AppColorStyles.contentSecondary,
              size: (width ?? 24) * 0.8,
            ),
          ),
        );
  }
}

class _NetworkFadeIn extends StatefulWidget {
  final Widget child;

  const _NetworkFadeIn({required this.child});

  @override
  State<_NetworkFadeIn> createState() => _NetworkFadeInState();
}

class _NetworkFadeInState extends State<_NetworkFadeIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _animation, child: widget.child);
  }
}
