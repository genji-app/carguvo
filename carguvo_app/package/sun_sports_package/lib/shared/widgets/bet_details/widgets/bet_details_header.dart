import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/providers/user_provider/user_provider.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/widgets/scoin_icon.dart';

class BetDetailsHeader extends ConsumerWidget {
  const BetDetailsHeader({
    super.key,
    this.isVibrating = false,
    this.isMobile = false,
    this.isBottomSheet = false,
  });

  final bool isVibrating;
  final bool isMobile;
  final bool isBottomSheet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceVND = ref.watch(balanceInVNDProvider);

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        if (isBottomSheet)
          Positioned(
            top: 8,
            child: Center(
              child: Opacity(
                opacity: 0.20,
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
          ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  isVibrating ? 'Cược nhanh' : 'Cược đơn',
                  style: AppTextStyles.headingXXSmall(
                    color: AppColorStyles.contentPrimary,
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Ví của tôi',
                    style: AppTextStyles.paragraphXSmall(
                      color: AppColorStyles.contentSecondary,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatCurrency(balanceVND),
                        style: AppTextStyles.labelXSmall(
                          color: AppColors.yellow400,
                        ),
                      ),
                      const SCoinIcon(),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatCurrency(double value) => value
      .toStringAsFixed(0)
      .replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (match) => '${match[1]},',
      );
}
