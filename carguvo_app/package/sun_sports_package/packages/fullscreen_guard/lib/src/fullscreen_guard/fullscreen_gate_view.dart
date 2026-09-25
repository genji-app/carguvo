import 'package:flutter/material.dart';

import 'fullscreen_guard.dart';

class FullscreenGateView extends StatefulWidget {
  const FullscreenGateView({
    required this.onProceed,
    required this.onCancel,
    this.backgroundColor = const Color(0xFF1A1A1A),
    this.accentColor = const Color(0xFFFFD54F),
    this.title = 'Fullscreen Required',
    this.subtitle = 'Tap or swipe up to continue',
    this.hintText = 'TAP OR SWIPE UP',
    this.icon = Icons.fullscreen_rounded,
    this.hintIcon = Icons.keyboard_double_arrow_up_rounded,
    super.key,
  });

  final VoidCallback onProceed;

  final VoidCallback onCancel;

  final Color backgroundColor;

  final Color accentColor;

  final String title;

  final String subtitle;

  final String hintText;

  final IconData icon;

  final IconData hintIcon;

  @override
  State<FullscreenGateView> createState() => _FullscreenGateViewState();
}

class _FullscreenGateViewState extends State<FullscreenGateView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  bool _isProceeding = false;

  void _handleProceed() {
    if (_isProceeding) return;
    _isProceeding = true;
    widget.onProceed();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _isProceeding = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1, end: 1.05),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.05, end: 1),
        weight: 50,
      ),
    ]).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _fadeAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 1),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1, end: 0),
        weight: 50,
      ),
    ]).animate(_animationController);
  }

  FullscreenGuardController? _guardController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_guardController == null) {
      _guardController = FullscreenGuard.of(context);
      _guardController!.strategy.setupGate(
        onSatisfied: () {
          if (mounted) _handleProceed();
        },
        onCancel: () {
          if (mounted) widget.onCancel();
        },
      );
    }
  }

  @override
  void dispose() {
    _guardController?.strategy.teardownGate();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onVerticalDragEnd: (details) {
          if ((details.primaryVelocity ?? 0) < -100) {
            _handleProceed();
          }
        },
        onTap: _handleProceed,
        behavior: HitTestBehavior.opaque,
        child: Container(
          color: widget.backgroundColor.withValues(alpha: 0.9),
          child: Stack(
            children: [
              Positioned(
                top: 20 + MediaQuery.of(context).padding.top,
                left: 20,
                child: IconButton(
                  onPressed: widget.onCancel,
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  color: Colors.white,
                  iconSize: 28,
                ),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: widget.accentColor.withValues(alpha: 0.5),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: widget.accentColor.withValues(alpha: 0.2),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: Icon(
                          widget.icon,
                          color: widget.accentColor,
                          size: 64,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 48),
                      child: Text(
                        widget.subtitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                      ),
                    ),
                    const SizedBox(height: 60),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          Icon(
                            widget.hintIcon,
                            color: widget.accentColor,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.hintText,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: widget.accentColor,
                                  letterSpacing: 1.5,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
