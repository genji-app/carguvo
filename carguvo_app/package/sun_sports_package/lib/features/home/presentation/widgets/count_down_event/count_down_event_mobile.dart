import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/providers/scroll_controller_provider.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/features/home/presentation/widgets/count_down_event/count_down_navigation.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_images.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/widgets/borders/animated_gradient_border_painter.dart';
import 'package:sun_sports/shared/widgets/buttons/shine_button.dart';
import 'package:sun_sports/shared/widgets/cards/inner_shadow_card.dart';

class CountDownEventMobile extends ConsumerStatefulWidget {
  const CountDownEventMobile({super.key});

  @override
  ConsumerState<CountDownEventMobile> createState() =>
      _CountDownEventMobileState();
}

class _CountDownEventMobileState extends ConsumerState<CountDownEventMobile>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  static const Color _gradientBottom = Color(0xFF5B2800);
  static const Color _gradientTop = Color(0xFFB95100);
  static const Color _borderHighlight = Color(0xFFB95100);
  static const Color _borderSpark = Color(0xFFFFFFFF);
  static const double _borderStrokeWidth = 1.5;
  static const double _borderGlowBlur = 4;
  static const Duration _borderRotationDuration = Duration(seconds: 3);

  late final AnimationController _borderController;

  ScrollPosition? _scrollPosition;
  bool _isForeground = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _borderController = AnimationController(
      vsync: this,
      duration: _borderRotationDuration,
    );
    if (!kIsWeb) {
      _borderController.repeat();
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _attachScrollListener(),
      );
    }
    prewarmEventCupData(ref);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollPosition?.isScrollingNotifier.removeListener(_onScrollingChanged);
    _borderController.dispose();
    super.dispose();
  }

  void _attachScrollListener() {
    if (!mounted || kIsWeb) return;
    final controller = ref.read(mainScrollControllerProvider);
    if (!controller.hasClients) return;
    final position = controller.position;
    if (identical(position, _scrollPosition)) return;
    _scrollPosition?.isScrollingNotifier.removeListener(_onScrollingChanged);
    _scrollPosition = position;
    position.isScrollingNotifier.addListener(_onScrollingChanged);
  }

  void _onScrollingChanged() {
    final isScrolling = _scrollPosition?.isScrollingNotifier.value ?? false;
    if (isScrolling) {
      if (_borderController.isAnimating) _borderController.stop();
    } else {
      _resumeBorderIfNeeded();
    }
  }

  void _resumeBorderIfNeeded() {
    if (kIsWeb || !_isForeground) return;
    final isScrolling = _scrollPosition?.isScrollingNotifier.value ?? false;
    if (!isScrolling && !_borderController.isAnimating) {
      _borderController.repeat();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    _isForeground = state == AppLifecycleState.resumed;
    if (_isForeground) {
      _resumeBorderIfNeeded();
    } else {
      _borderController.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: AnimatedBuilder(
        animation: _borderController,
        builder: (BuildContext context, Widget? child) {
          return CustomPaint(
            foregroundPainter: AnimatedGradientBorderPainter(
              rotation: _borderController.value,
              borderRadius: 16,
              strokeWidth: _borderStrokeWidth,
              glowBlur: _borderGlowBlur,
              highlight: _borderHighlight,
              spark: _borderSpark,
            ),
            child: child,
          );
        },
        child: RepaintBoundary(
          child: InnerShadowCard(
            borderRadius: 16,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: <Color>[_gradientBottom, _gradientTop],
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  clipBehavior: Clip.hardEdge,
                  children: <Widget>[
                    Positioned(
                      top: -64,
                      right: -0.5,
                      width: 232,
                      height: 138,
                      child: ImageHelper.load(
                        path: AppImages.imgBackgroundCountDownEvent,
                        fit: BoxFit.cover,
                        cacheWidth: 464,
                        cacheHeight: 276,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: <Widget>[
                          const Expanded(child: _CountDownMobileInfo()),
                          const Gap(8),
                          ShineButton(
                            text: 'Cược ngay',
                            height: 36,
                            width: (width * 0.27423).clamp(0.0, 120.0),
                            onPressed: () async {
                              await navigateToEventCup(ref);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CountDownMobileInfo extends StatelessWidget {
  const _CountDownMobileInfo();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        ImageHelper.load(
          path: AppIcons.iconAFFCup,
          height: 32,
          cacheHeight: 64,
          fit: BoxFit.contain,
        ),
        const Gap(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'ASEAN Cup 2026',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.headingXSmall(
                  color: AppColorStyles.contentPrimary,
                ).copyWith(height: 24 / 20),
              ),
              const Gap(4),
              const _CountDownMobileDivider(),
              const Gap(4),
              const FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: _CountDownStatsRow(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CountDownMobileDivider extends StatelessWidget {
  const _CountDownMobileDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            Colors.white.withValues(alpha: 0),
            Colors.white.withValues(alpha: 0.35),
            Colors.white.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}

class _CountDownStatsRow extends StatelessWidget {
  const _CountDownStatsRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _CountDownStatItem(value: '10', label: 'Đội'),
        Gap(8),
        _CountDownStatDivider(),
        Gap(8),
        _CountDownStatItem(value: '26', label: 'Trận'),
        Gap(8),
        _CountDownStatDivider(),
        Gap(8),
        _CountDownStatItem(value: '26/8', label: 'Chung kết'),
      ],
    );
  }
}

class _CountDownStatItem extends StatelessWidget {
  const _CountDownStatItem({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          value,
          style: AppTextStyles.labelXXSmall(
            color: AppColors.yellow300,
          ).copyWith(fontWeight: FontWeight.w700),
        ),
        const Gap(2),
        Text(
          label,
          style: AppTextStyles.paragraphXXSmall(
            color: AppColorStyles.contentPrimary,
          ).copyWith(
            fontWeight: FontWeight.w500,
            color: AppColorStyles.contentPrimary.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}

class _CountDownStatDivider extends StatelessWidget {
  const _CountDownStatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 10,
      color: Colors.white.withValues(alpha: 0.3),
    );
  }
}
