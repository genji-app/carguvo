import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sun_sports/features/profile/deposit/presentation/show_deposit_flow.dart';
import 'package:sun_sports/providers/main_content_provider.dart';
import 'package:sun_sports/shared/utils/auth_gate.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_images.dart';
import 'package:sun_sports/shared/responsive/responsive_builder.dart';
import 'package:sun_sports/shared/widgets/cards/welcome_banner_card.dart';

class HomeDesktopWelcomeSection extends ConsumerWidget {
  const HomeDesktopWelcomeSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Container(
    height: 125,
    padding: const EdgeInsets.only(top: 15),
    child: Row(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              const artWidth = WelcomeBannerArt.sun88FitHeight;
              return WelcomeBannerCard(
                color: const Color(0xFF050505),
                colorOverlay: AppColors.orange600.withValues(alpha: 0.45),
                onTap: () {
                  ref.read(mainContentProvider.notifier).goToSport();
                },
                childTextContent: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thương hiệu\ncá cược thể thao',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        height: 22 / 18,
                        color: AppColors.yellow500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 233),
                      child: Text(
                        'Từ hệ sinh thái',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          height: 24 / 12,
                          color: const Color(0xFFFFFEF5),
                        ),
                      ),
                    ),
                  ],
                ),
                overlayImageBuilder: (isHovered) => AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  top: isHovered ? -10 : 0,
                  bottom: 0,
                  right: isHovered ? -20 : -10,
                  width: isHovered
                      ? artWidth + WelcomeBannerArt.hoverGrow
                      : artWidth,
                  child: ImageHelper.load(
                    path: AppImages.imageLogoSun88,
                    fit: BoxFit.cover,
                    cacheWidth: 258,
                  ),
                ),
              );
            },
          ),
        ),
        const Gap(12),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final artWidth = ResponsiveBuilder.isDesktop(context)
                  ? WelcomeBannerArt.secondMax
                  : WelcomeBannerArt.second(
                      constraints.maxWidth,
                      cardHeight: constraints.maxHeight,
                    );
              return WelcomeBannerCard(
                buttonText: 'Nạp tiền',
                color: const Color(0xFF050505),
                colorOverlay: AppColors.yellow500.withValues(alpha: 0.4),
                onTap: () {
                  if (!requireLogin(context, ref)) return;
                  showDepositFlow(context, ref);
                },
                childTextContent: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nạp rút đa dạng',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        height: 22 / 18,
                        color: AppColors.yellow500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ngân hàng, ví điện tử và crypto',
                      softWrap: false,
                      maxLines: 1,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        height: 24 / 12,
                        color: const Color(0xFFFFFEF5),
                      ),
                    ),
                  ],
                ),
                overlayImageBuilder: (isHovered) => AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  top: isHovered ? -20 : 0,
                  bottom: 0,
                  right: isHovered ? -5 : 5,
                  width: isHovered
                      ? artWidth + WelcomeBannerArt.hoverGrow
                      : artWidth,
                  child: ImageHelper.load(
                    path: AppImages.imageBannerPayment,
                    fit: BoxFit.cover,
                    cacheWidth: 370,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}
