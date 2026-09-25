import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/providers/user_provider/user_provider.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_images.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/profile/avatar/presentation/widgets/avatar_with_camera.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';
import 'package:sun_sports/shared/widgets/texts/texts.dart';

class ProfileUserCard extends StatelessWidget {
  const ProfileUserCard({
    required this.displayName,
    required this.customerId,
    this.avatarUrl,
    this.onAvatarPressed,
    this.onNotificationPressed,
    super.key,
  });

  final String? avatarUrl;
  final String displayName;
  final String customerId;

  final VoidCallback? onAvatarPressed;

  final VoidCallback? onNotificationPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ImageHelper.load(
                path: AppImages.backgroundProfile,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                AvatarWithCamera(
                  avatarUrl: avatarUrl,
                  onPressed: onAvatarPressed,
                ),

                const SizedBox(width: 16),
                Expanded(
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(
                      end: onNotificationPressed != null ? 44 : 0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: AppTextStyles.headingXSmall(
                            color: AppColorStyles.contentPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${I18n.txtID}: $customerId',
                          style: AppTextStyles.paragraphSmall(
                            color: AppColorStyles.contentSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const _UserBalanceRow(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (onNotificationPressed != null)
            PositionedDirectional(
              top: 20,
              end: 20,
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: AppColorStyles.backgroundQuaternary,
                  shape: BoxShape.circle,
                ),
                child: InkWell(
                  onTap: SoundTap.wrap(onNotificationPressed),
                  borderRadius: BorderRadius.circular(100),
                  child: Center(
                    child: ImageHelper.load(
                      path: AppIcons.iconNotification,
                      width: 20,
                      height: 20,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _UserBalanceRow extends StatelessWidget {
  const _UserBalanceRow();

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final balanceVND = ref.watch(balanceInVNDProvider);
        return Row(
          children: [
            CurrencyText.defaultSuffix(size: 24),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                CurrencyText.formatCurrency(balanceVND.floor()),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelSmall(
                  color: AppColorStyles.contentPrimary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
