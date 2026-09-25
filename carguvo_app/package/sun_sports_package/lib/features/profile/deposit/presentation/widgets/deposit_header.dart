import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class DepositHeader extends StatelessWidget {
  final VoidCallback onClose;
  final bool showBackButton;

  const DepositHeader({
    super.key,
    required this.onClose,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(17, 12, 16, 12),
    child: Row(
      children: [
        if (showBackButton) ...[
          InkWell(
            onTap: SoundTap.wrap(onClose),
            child: Container(
              width: 20,
              height: 20,
              color: Colors.transparent,
              child: ImageHelper.load(
                path: AppIcons.icBack,
                width: 20,
                height: 20,
              ),
            ),
          ),
          const Gap(12),
        ],
        Expanded(
          child: Text(
            'Nạp tiền',
            style: AppTextStyles.headingXSmall(
              color: AppColors.gray25,
            ),
            textAlign: showBackButton ? TextAlign.start : TextAlign.center,
          ),
        ),
        InkWell(
          onTap: SoundTap.wrap(onClose),
          borderRadius: BorderRadius.circular(100),
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Center(
              child: Icon(Icons.close, size: 20, color: AppColors.gray25),
            ),
          ),
        ),
      ],
    ),
  );
}
