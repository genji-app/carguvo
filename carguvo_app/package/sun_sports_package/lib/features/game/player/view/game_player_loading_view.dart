import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_images.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/widgets/sun_progress_bar.dart';

class GamePlayerLoadingView extends StatelessWidget {
  const GamePlayerLoadingView({
    this.progress,
    this.contentVisible = true,
    this.label,
    super.key,
  });

  final double? progress;
  final bool contentVisible;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final progressVal = progress ?? 0.0;

    return ColoredBox(
      color: AppColorStyles.backgroundPrimary,
      child: AnimatedScale(
        scale: contentVisible ? 1.0 : 0.94,
        duration: const Duration(milliseconds: 388),
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(
          opacity: contentVisible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxHeight = constraints.maxHeight;

              final logoSize = (maxHeight * 0.38).clamp(70.0, 200.0);
              final gapLarge = (maxHeight * 0.08).clamp(8.0, 48.0);
              final gapSmall = (maxHeight * 0.03).clamp(4.0, 16.0);

              final showTip = maxHeight >= 280;

              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _GameLogo(size: logoSize),
                          SizedBox(height: gapLarge),
                          _LoadingLabel(label: label ?? 'Đang tải...'),
                          SizedBox(height: gapSmall),
                          RepaintBoundary(
                            child: SizedBox(
                              width: 200,
                              child: SunProgressBar(progress: progressVal),
                            ),
                          ),
                          if (showTip) ...[
                            SizedBox(height: gapLarge),
                            const RepaintBoundary(child: _TipCarousel()),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TipCarousel extends StatefulWidget {
  const _TipCarousel();

  @override
  State<_TipCarousel> createState() => _TipCarouselState();
}

class _TipCarouselState extends State<_TipCarousel> {
  static const Duration _tipInterval = Duration(seconds: 3);

  static const List<({String text, List<String> highlights})> _tips = [
    (text: 'Tải 1.1.1.1 để truy cập sun88.win', highlights: ['1.1.1.1']),
    (
      text: 'Vào Cược của tôi để quản lý cược đơn và cược xiên',
      highlights: ['Cược của tôi'],
    ),
    (
      text: 'Sun88 thương hiệu cá cược thể thao của Sunwin',
      highlights: ['Sun88', 'Sunwin'],
    ),
    (text: 'Kèo được chọn sẽ tự động vào giỏ kèo', highlights: ['giỏ kèo']),
    (
      text:
          'Nạp tiền siêu tốc, chọn phương thức yêu thích và tiền vào tài '
          'khoản chỉ trong vài giây',
      highlights: ['Nạp tiền siêu tốc,'],
    ),
    (
      text: 'Tích hợp game casino của sunwin và các nhà cung cấp nổi tiếng',
      highlights: ['game casino'],
    ),
    (
      text: 'Xác minh tài khoản sớm để các lệnh rút tiền được duyệt nhanh hơn',
      highlights: ['Xác minh tài khoản'],
    ),
    (
      text: 'Thêm giải đấu/trận đấu vào mục yêu thích để không bỏ lỡ kèo hay',
      highlights: ['mục yêu thích'],
    ),
    (
      text: 'Cá nhân hóa trải nghiệm với trang sports chỉ dành riêng cho bạn',
      highlights: ['Cá nhân hóa'],
    ),
    (
      text:
          'Tỷ lệ cược được cập nhật liên tục theo thời gian thực, bám sát '
          'diễn biến trận đấu',
      highlights: ['cập nhật liên tục'],
    ),
    (
      text:
          'Đa dạng loại kèo: tài xỉu, chấp, xiên... với mức tỷ lệ hấp dẫn '
          'cho mọi lựa chọn',
      highlights: ['Đa dạng loại kèo:'],
    ),
  ];

  late final List<({String text, List<String> highlights})> _shuffledTips;
  int _tipIndex = 0;
  Timer? _tipTimer;

  @override
  void initState() {
    super.initState();
    _shuffledTips = List.of(_tips)..shuffle();
    _tipTimer = Timer.periodic(_tipInterval, (_) {
      if (!mounted) return;
      setState(() => _tipIndex = (_tipIndex + 1) % _shuffledTips.length);
    });
  }

  @override
  void dispose() {
    _tipTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tip = _shuffledTips[_tipIndex];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 48,
        child: Align(
          alignment: Alignment.topCenter,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            switchInCurve: Curves.linear,
            switchOutCurve: Curves.linear,
            layoutBuilder: (currentChild, previousChildren) {
              return Stack(
                alignment: Alignment.topCenter,
                children: [
                  ...previousChildren,
                  if (currentChild != null) currentChild,
                ],
              );
            },
            transitionBuilder: (child, animation) {
              final incoming = child.key == ValueKey<int>(_tipIndex);
              final beginOffset = incoming
                  ? const Offset(0, 0.6)
                  : const Offset(0, -0.6);

              final opacity = animation.drive(
                CurveTween(
                  curve: incoming
                      ? const Interval(0.4, 1, curve: Curves.easeOut)
                      : const Interval(0.6, 1, curve: Curves.easeIn),
                ),
              );
              final position = animation.drive(
                Tween<Offset>(
                  begin: beginOffset,
                  end: Offset.zero,
                ).chain(CurveTween(curve: Curves.easeOutCubic)),
              );

              return ClipRect(
                child: FadeTransition(
                  opacity: opacity,
                  child: SlideTransition(position: position, child: child),
                ),
              );
            },
            child: _HighlightedTip(
              key: ValueKey<int>(_tipIndex),
              text: tip.text,
              highlights: tip.highlights,
            ),
          ),
        ),
      ),
    );
  }
}

class _GameLogo extends StatelessWidget {
  const _GameLogo({this.size = 200});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ImageHelper.load(
        path: AppImages.logoUrl,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorWidget: const ColoredBox(color: AppColorStyles.backgroundPrimary),
        bypassSuspend: true,
      ),
    );
  }
}

class _LoadingLabel extends StatelessWidget {
  const _LoadingLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      textAlign: TextAlign.center,
      style: AppTextStyles.labelXSmall(color: Colors.white),
    );
  }
}

class _HighlightedTip extends StatelessWidget {
  const _HighlightedTip({
    required this.text,
    required this.highlights,
    super.key,
  });

  final String text;
  final List<String> highlights;

  @override
  Widget build(BuildContext context) {
    final baseStyle = AppTextStyles.paragraphMedium(
      color: AppColorStyles.contentSecondary,
    );
    final hlStyle = baseStyle.copyWith(color: AppColors.yellow500);

    final ranges = <(int, int)>[];
    for (final raw in highlights) {
      final needle = raw.trim();
      if (needle.isEmpty) continue;
      int from = 0;
      int idx;
      while ((idx = text.indexOf(needle, from)) != -1) {
        ranges.add((idx, idx + needle.length));
        from = idx + needle.length;
      }
    }
    ranges.sort((a, b) => a.$1.compareTo(b.$1));

    final spans = <TextSpan>[];
    int cursor = 0;
    for (final (start, end) in ranges) {
      if (start < cursor) continue;
      if (start > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, start)));
      }
      spans.add(TextSpan(text: text.substring(start, end), style: hlStyle));
      cursor = end;
    }
    if (cursor < text.length) {
      spans.add(TextSpan(text: text.substring(cursor)));
    }

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(style: baseStyle, children: spans),
    );
  }
}
