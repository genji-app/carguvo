import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_package/features/profile/deposit/presentation/show_deposit_flow.dart';
import 'package:app_package/providers/main_content_provider.dart';
import 'package:app_package/shared/utils/auth_gate.dart';
import 'package:app_package/core/utils/styles/app_color.dart';
import 'package:app_package/core/utils/extensions/image_helper.dart';
import 'package:app_package/core/utils/styles/app_images.dart';
import 'package:app_package/shared/responsive/responsive_builder.dart';
import 'package:app_package/shared/widgets/cards/welcome_banner_card.dart';

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
              const artWidth = WelcomeBannerArt.sun88Width;
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
                overlayImageBuilder: (isHovered) => Positioned(
                  top: WelcomeBannerArt.sun88Top,
                  bottom: 0,
                  right: WelcomeBannerArt.sun88Right,
                  width: artWidth,
                  child: AnimatedScale(
                    scale: isHovered ? WelcomeBannerArt.hoverScale : 1.0,
                    alignment: WelcomeBannerArt.hoverArtAnchor,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    child: ImageHelper.load(
                      path: AppImages.imageLogoSun88,
                      fit: BoxFit.cover,
                      cacheWidth: 268,
                    ),
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
                overlayImageBuilder: (isHovered) => Positioned(
                  top: 0,
                  bottom: 0,
                  right: 5,
                  width: artWidth,
                  child: AnimatedScale(
                    scale: isHovered ? WelcomeBannerArt.hoverScale : 1.0,
                    alignment: WelcomeBannerArt.hoverArtAnchor,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    child: ImageHelper.load(
                      path: AppImages.imageBannerPayment,
                      fit: BoxFit.cover,
                      cacheWidth: 340,
                    ),
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
