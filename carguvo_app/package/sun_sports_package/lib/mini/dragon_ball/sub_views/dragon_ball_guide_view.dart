import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/mini_game_icons.dart';
import 'package:sun_sports/mini/minipoker/sub_views/minipoker_sub_view_scaffold.dart';
import 'package:sun_sports/mini/minipoker/widgets/minipoker_common.dart';

class DragonBallGuideView extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onClose;
  final BorderRadius borderRadius;

  const DragonBallGuideView({
    required this.onBack,
    required this.onClose,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MinipokerSubViewScaffold(
      title: 'Hướng dẫn',
      onBack: onBack,
      onClose: onClose,
      borderRadius: borderRadius,
      child: const DragonBallGuideContent(),
    );
  }
}

class DragonBallGuideContent extends StatelessWidget {
  const DragonBallGuideContent({super.key});

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(
        context,
      ).copyWith(dragDevices: PointerDeviceKind.values.toSet()),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionTitle('Hệ số'),
            const SizedBox(height: 12),
            _PayRow(
              icon: MiniGameIcons.dbSymbolGoku,
              trailing: const _JackpotTrailing(),
            ),
            _PayRow(icon: MiniGameIcons.dbSymbolGoku, multiplier: 'X10'),
            _PayRow(icon: MiniGameIcons.dbSymbolVegeta, multiplier: 'X1'),
            _PayRow(icon: MiniGameIcons.dbSymbolPiccolo, multiplier: 'X0.35'),
            _PayRow(
              icon: MiniGameIcons.dbSymbolYoungGoku,
              multiplier: 'X0.1',
              showDivider: false,
            ),
            const SizedBox(height: 12),
            const _Divider(),
            const SizedBox(height: 12),

            _NoteLine(
              leadingIcon: MiniGameIcons.dbSymbolWild,
              text: ' có thể thay thế mọi icon ngoại trừ ',
              trailingIcon: MiniGameIcons.dbSymbolGoku,
            ),
            const SizedBox(height: 8),
            const _NoteText(
              '2 cuộn cuối gồm hệ số nhân thưởng, chỉ tính 2 icon ở hàng '
              'giữa',
            ),
            const SizedBox(height: 8),
            _NoteLine(
              text: 'Hệ số nhân sẽ mất giá trị nếu ',
              trailingIcon: MiniGameIcons.dbSymbolFrieza,
              suffixText: ' đứng trước',
            ),
            const SizedBox(height: 12),
            const _Divider(),
            const SizedBox(height: 12),

            const _SectionTitle('Tính tiền thắng'),
            const SizedBox(height: 8),
            const _NoteText(
              'Tiền thắng bằng tổng tất cả các bộ nhân theo bảng thưởng '
              'trên',
            ),
            const SizedBox(height: 12),
            const _ExampleBox(),
            const SizedBox(height: 12),
            const _NoteText('Trong ví dụ trên:'),
            const SizedBox(height: 8),
            _NoteLine(
              text: '3 cuộn đầu có 4 line của icon piccolo ',
              trailingIcon: MiniGameIcons.dbSymbolPiccolo,
            ),
            const SizedBox(height: 8),
            _NoteLine(
              text: '2 cuộn sau có 2 icon ',
              trailingIcon: MiniGameIcons.dbSymbolX10,
              trailingIconWidth: 40,
            ),
            const SizedBox(height: 8),
            const _NoteText('Giải thưởng nhận được:'),
            const SizedBox(height: 4),
            const MinipokerGoldNumber('4 x 0.35 x 10 x 10 x 100 = 14,000'),
            const SizedBox(height: 16),
            const _NoteText('Chúc các bạn chơi game vui'),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: GoogleFonts.plusJakartaSans(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      height: 20 / 14,
      color: AppColors.green400,
    ),
  );
}

class _PayRow extends StatelessWidget {
  final String icon;
  final String? multiplier;
  final Widget? trailing;
  final bool showDivider;

  const _PayRow({
    required this.icon,
    this.multiplier,
    this.trailing,
    this.showDivider = true,
  });

  static const double _iconSize = 36;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(
                bottom: BorderSide(color: AppColorStyles.borderPrimary),
              )
            : null,
      ),
      child: Row(
        children: [
          for (var i = 0; i < 3; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            ImageHelper.load(path: icon, width: _iconSize, height: _iconSize),
          ],
          const Spacer(),
          trailing ??
              Text(
                multiplier ?? '',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 20 / 14,
                  color: AppColorStyles.contentPrimary,
                ),
              ),
        ],
      ),
    );
  }
}

class _JackpotTrailing extends StatelessWidget {
  const _JackpotTrailing();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ImageHelper.load(
          path: MiniGameIcons.dbSymbolX10,
          width: 36,
          height: 24,
        ),
        const SizedBox(width: 2),
        ImageHelper.load(
          path: MiniGameIcons.dbSymbolX10,
          width: 36,
          height: 24,
        ),
        const SizedBox(width: 8),
        const MinipokerGoldNumber('JACKPOT'),
      ],
    );
  }
}

class _NoteText extends StatelessWidget {
  final String text;

  const _NoteText(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: GoogleFonts.plusJakartaSans(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      height: 20 / 13,
      color: AppColorStyles.contentPrimary,
    ),
  );
}

class _NoteLine extends StatelessWidget {
  final String? leadingIcon;
  final String text;
  final String? trailingIcon;
  final String? suffixText;
  final double trailingIconWidth;

  const _NoteLine({
    required this.text,
    this.leadingIcon,
    this.trailingIcon,
    this.suffixText,
    this.trailingIconWidth = 24,
  });

  static const double _iconSize = 24;

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.plusJakartaSans(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      height: 20 / 13,
      color: AppColorStyles.contentPrimary,
    );
    return Text.rich(
      TextSpan(
        children: [
          if (leadingIcon != null)
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: ImageHelper.load(
                path: leadingIcon!,
                width: _iconSize,
                height: _iconSize,
              ),
            ),
          TextSpan(text: text),
          if (trailingIcon != null)
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: ImageHelper.load(
                path: trailingIcon!,
                width: trailingIconWidth,
                height: _iconSize,
              ),
            ),
          if (suffixText != null) TextSpan(text: suffixText),
        ],
      ),
      style: style,
    );
  }
}

class _ExampleBox extends StatelessWidget {
  const _ExampleBox();

  static const double _size = 40;

  Widget _sym(String path, {double? width}) =>
      ImageHelper.load(path: path, width: width ?? _size, height: _size);

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF171614),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _sym(MiniGameIcons.dbSymbolYoungGoku),
                      _sym(MiniGameIcons.dbSymbolWild),
                      _sym(MiniGameIcons.dbSymbolVegeta),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _sym(MiniGameIcons.dbSymbolFrieza),
                      _sym(MiniGameIcons.dbSymbolPiccolo),
                      _sym(MiniGameIcons.dbSymbolPiccolo),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _sym(MiniGameIcons.dbSymbolPiccolo),
                      _sym(MiniGameIcons.dbSymbolYoungGoku),
                      _sym(MiniGameIcons.dbSymbolPiccolo),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF171614),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _sym(MiniGameIcons.dbSymbolX10, width: 48),
                      _sym(MiniGameIcons.dbSymbolX10, width: 48),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _sym(MiniGameIcons.dbSymbolFrieza),
                      _sym(MiniGameIcons.dbSymbolFrieza),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _sym(MiniGameIcons.dbSymbolX10, width: 48),
                      _sym(MiniGameIcons.dbSymbolX10, width: 48),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) => Container(
    height: 1,
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0x00FFFFFF), Color(0x33FFFFFF), Color(0x00FFFFFF)],
        stops: [0.0, 0.5, 1.0],
      ),
    ),
  );
}
