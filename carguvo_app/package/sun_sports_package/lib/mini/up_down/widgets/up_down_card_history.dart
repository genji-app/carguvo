import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/mini/up_down/state/up_down_card.dart';
import 'package:sun_sports/mini/up_down/state/up_down_state_provider.dart';

class UpDownCardHistoryBar extends ConsumerWidget {
  const UpDownCardHistoryBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(upDownStateProvider.select((s) => s.history));
    return Container(
      height: 34,
      width: double.infinity,
      color: AppColorStyles.backgroundTertiary,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ClipRect(
        child: OverflowBox(
          maxWidth: double.infinity,
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < history.length; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                _CardChip(card: decodeCard(history[i])),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CardChip extends StatelessWidget {
  final UpDownCard card;

  const _CardChip({required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: AppColorStyles.backgroundQuaternary,
        borderRadius: BorderRadius.circular(1000),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            card.label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              height: 18 / 12,
              color: AppColorStyles.contentSecondary,
            ),
          ),
          const SizedBox(width: 2),
          ImageHelper.load(
            path: card.suit.assetPath,
            width: 10,
            height: 10,
            color: AppColorStyles.contentSecondary,
          ),
        ],
      ),
    );
  }
}
