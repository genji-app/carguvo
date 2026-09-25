import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/mini/minipoker/sub_views/minipoker_sub_view_scaffold.dart';
import 'package:sun_sports/mini/minipoker/widgets/minipoker_card.dart';
import 'package:sun_sports/mini/minipoker/widgets/minipoker_common.dart';

class MinipokerGuideView extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onClose;
  final BorderRadius borderRadius;

  const MinipokerGuideView({
    required this.onBack,
    required this.onClose,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    super.key,
  });

  static const List<PorkerCard> _kJackpotHand = [
    PorkerCard(PorkerSuit.diamond, '10'),
    PorkerCard(PorkerSuit.diamond, 'j'),
    PorkerCard(PorkerSuit.diamond, 'q'),
    PorkerCard(PorkerSuit.diamond, 'k'),
    PorkerCard(PorkerSuit.diamond, 'a'),
  ];

  static const List<(String, String, List<PorkerCard>)> _payTable = [
    (
      'Thùng phá sảnh',
      '1000',
      [
        PorkerCard(PorkerSuit.club, '4'),
        PorkerCard(PorkerSuit.club, '5'),
        PorkerCard(PorkerSuit.club, '6'),
        PorkerCard(PorkerSuit.club, '7'),
        PorkerCard(PorkerSuit.club, '8'),
      ],
    ),
    (
      'Tứ quý',
      '150',
      [
        PorkerCard(PorkerSuit.diamond, 'a'),
        PorkerCard(PorkerSuit.club, 'a'),
        PorkerCard(PorkerSuit.heart, 'a'),
        PorkerCard(PorkerSuit.spade, 'a'),
        PorkerCard(PorkerSuit.diamond, '9'),
      ],
    ),
    (
      'Cù lũ',
      '50',
      [
        PorkerCard(PorkerSuit.spade, 'a'),
        PorkerCard(PorkerSuit.heart, 'a'),
        PorkerCard(PorkerSuit.diamond, 'a'),
        PorkerCard(PorkerSuit.club, 'k'),
        PorkerCard(PorkerSuit.diamond, 'k'),
      ],
    ),
    (
      'Thùng',
      '20',
      [
        PorkerCard(PorkerSuit.club, 'j'),
        PorkerCard(PorkerSuit.club, '4'),
        PorkerCard(PorkerSuit.club, '6'),
        PorkerCard(PorkerSuit.club, '9'),
        PorkerCard(PorkerSuit.club, 'k'),
      ],
    ),
    (
      'Sảnh',
      '13',
      [
        PorkerCard(PorkerSuit.heart, '4'),
        PorkerCard(PorkerSuit.club, '5'),
        PorkerCard(PorkerSuit.diamond, '6'),
        PorkerCard(PorkerSuit.diamond, '7'),
        PorkerCard(PorkerSuit.spade, '8'),
      ],
    ),
    (
      'Xám',
      '8',
      [
        PorkerCard(PorkerSuit.diamond, '4'),
        PorkerCard(PorkerSuit.heart, '4'),
        PorkerCard(PorkerSuit.spade, '4'),
        PorkerCard(PorkerSuit.heart, '10'),
        PorkerCard(PorkerSuit.club, 'k'),
      ],
    ),
    (
      'Hai đôi',
      '5',
      [
        PorkerCard(PorkerSuit.club, '3'),
        PorkerCard(PorkerSuit.spade, '3'),
        PorkerCard(PorkerSuit.diamond, '5'),
        PorkerCard(PorkerSuit.diamond, 'j'),
        PorkerCard(PorkerSuit.club, 'j'),
      ],
    ),
    (
      'Đôi J trở lên',
      '2.5',
      [
        PorkerCard(PorkerSuit.heart, 'q'),
        PorkerCard(PorkerSuit.diamond, 'q'),
        PorkerCard(PorkerSuit.club, '8'),
        PorkerCard(PorkerSuit.diamond, '6'),
        PorkerCard(PorkerSuit.club, '3'),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return MinipokerSubViewScaffold(
      title: MinipokerSubView.guide.title,
      onBack: onBack,
      onClose: onClose,
      borderRadius: borderRadius,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context)
            .copyWith(dragDevices: PointerDeviceKind.values.toSet()),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle('Thưởng Nổ hũ'),
              const SizedBox(height: 12),
              const _JackpotRow(
                name: 'Thùng phá sảnh J',
                desc: '5 lá bài liên tiếp cùng chất từ 7 -> A',
                cards: _kJackpotHand,
              ),
              const SizedBox(height: 12),
              const _Divider(),
              const SizedBox(height: 12),

              const _SectionTitle('Tiền thắng = Hệ số x Mức cược'),
              const SizedBox(height: 12),
              for (var i = 0; i < _payTable.length; i++) ...[
                if (i > 0) const SizedBox(height: 12),
                _PayRow(
                  name: _payTable[i].$1,
                  multiplier: _payTable[i].$2,
                  cards: _payTable[i].$3,
                ),
              ],
            ],
          ),
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

class _JackpotRow extends StatelessWidget {
  final String name;
  final String desc;
  final List<PorkerCard> cards;

  const _JackpotRow({
    required this.name,
    required this.desc,
    required this.cards,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HandName(name),
        const SizedBox(height: 4),
        Text(
          desc,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            height: 18 / 12,
            color: AppColorStyles.contentSecondary,
          ),
        ),
        const SizedBox(height: 4),
        MinipokerResultCardBox(cards: cards),
      ],
    );
  }
}

class _PayRow extends StatelessWidget {
  final String name;
  final String multiplier;
  final List<PorkerCard> cards;

  const _PayRow({
    required this.name,
    required this.multiplier,
    required this.cards,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HandName(name),
        const SizedBox(height: 4),
        Row(
          children: [
            MinipokerResultCardBox(cards: cards),
            const SizedBox(width: 10),
            Text(
              'x',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 18 / 12,
                color: AppColorStyles.contentSecondary,
              ),
            ),
            const SizedBox(width: 8),
            MinipokerGoldNumber(multiplier),
          ],
        ),
      ],
    );
  }
}

class _HandName extends StatelessWidget {
  final String text;

  const _HandName(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          height: 18 / 12,
          color: AppColorStyles.contentPrimary,
        ),
      );
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
