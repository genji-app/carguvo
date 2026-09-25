import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
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

class CountDownEventDesktop extends ConsumerStatefulWidget {
  const CountDownEventDesktop({super.key});

  @override
  ConsumerState<CountDownEventDesktop> createState() =>
      _CountDownEventDesktopState();
}

class _CountDownEventDesktopState extends ConsumerState<CountDownEventDesktop>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  static const Color _gradientBottom = Color(0xFF5B2800);
  static const Color _gradientTop = Color(0xFFB95100);
  static const Color _borderHighlight = Color(0xFFB95100);
  static const Color _borderSpark = Color(0xFFFFFFFF);
  static const double _borderStrokeWidth = 1.5;
  static const double _borderGlowBlur = 4;
  static const Duration _borderRotationDuration = Duration(seconds: 3);

  late final AnimationController _borderController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _borderController = AnimationController(
      vsync: this,
      duration: _borderRotationDuration,
    );
    if (!kIsWeb) _borderController.repeat();
    prewarmEventCupData(ref);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _borderController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    final isForeground = state == AppLifecycleState.resumed;
    if (isForeground) {
      if (!kIsWeb && !_borderController.isAnimating) {
        _borderController.repeat();
      }
    } else {
      _borderController.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
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
                  children: <Widget>[
                    Positioned(
                      top: 0,
                      right: 0,
                      bottom: 0,
                      left: 512,
                      child: ImageHelper.load(
                        path: AppImages.imgBackgroundCountDownEvent,
                        fit: BoxFit.cover,
                        cacheWidth: 800,
                        cacheHeight: 400,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 28, 16),
                      child: Stack(
                        alignment: Alignment.center,
                        children: const <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              _CountDownEventBranding(),
                              Spacer(),
                              _CountDownBetButton(),
                            ],
                          ),
                          _CountDownStatsRow(),
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

class _CountDownBetButton extends ConsumerWidget {
  const _CountDownBetButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ShineButton(
      text: 'Cược ngay',
      height: 36,
      onPressed: () async {
        await navigateToEventCup(ref);
      },
    );
  }
}

class _CountDownEventBranding extends StatelessWidget {
  const _CountDownEventBranding();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ImageHelper.load(
          path: AppIcons.iconAFFCup,
          height: 52,
          cacheHeight: 104,
          fit: BoxFit.contain,
        ),
        const Gap(16),
        Text(
          'ASEAN Cup\n2026',
          style: AppTextStyles.headingSmall(
            color: AppColorStyles.contentPrimary,
          ).copyWith(height: 28 / 24),
        ),
      ],
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
        _CountDownStatBox(value: '10', label: 'Đội'),
        Gap(8),
        _CountDownStatBox(value: '26', label: 'Trận'),
        Gap(8),
        _CountDownStatBox(value: '26/8', label: 'Chung kết'),
      ],
    );
  }
}

class _CountDownStatBox extends StatelessWidget {
  const _CountDownStatBox({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: const GradientBoxBorder(
          width: 0.5,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              Color(0x99FFFFFF),
              Color(0x00FFFFFF),
            ],
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            value,
            textAlign: TextAlign.center,
            style: AppTextStyles.headingSmall(
              color: AppColors.yellow300,
            ).copyWith(fontWeight: FontWeight.w700, height: 28 / 24),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.paragraphXXSmall(
              color: AppColorStyles.contentPrimary,
            ).copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
