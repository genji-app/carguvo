import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sun_sports/features/profile/deposit/presentation/show_deposit_flow.dart';
import 'package:sun_sports/providers/main_content_provider.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_images.dart';
import 'package:sun_sports/features/home/presentation/desktop/widgets/home_desktop_welcome_section.dart';
import 'package:sun_sports/shared/responsive/responsive_builder.dart';
import 'package:sun_sports/shared/utils/auth_gate.dart';
import 'package:sun_sports/shared/widgets/cards/welcome_banner_card.dart';
import 'package:sun_sports/shared/widgets/scroll/scroll.dart';

class HomeMobileWelcomeSection extends ConsumerStatefulWidget {
  const HomeMobileWelcomeSection({super.key});

  @override
  ConsumerState<HomeMobileWelcomeSection> createState() =>
      _HomeMobileWelcomeSectionState();
}

class _HomeMobileWelcomeSectionState
    extends ConsumerState<HomeMobileWelcomeSection> {
  static const double _bannerHeight = 110;
  static const double _hPadding = 8;

  final PageController _controller = PageController();
  final ScrollGestureAxisLock _wheelAxisLock = ScrollGestureAxisLock();
  final ValueNotifier<int> _index = ValueNotifier<int>(0);

  @override
  void dispose() {
    _controller.dispose();
    _index.dispose();
    super.dispose();
  }

  void _onPageChanged(int i) => _index.value = i;

  @override
  Widget build(BuildContext context) {
    if (!ResponsiveBuilder.isMobile(context)) {
      return const HomeDesktopWelcomeSection();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final bannerWidth = constraints.maxWidth - _hPadding * 2;
        final banners = <Widget>[
          _buildSun88Banner(),
          _buildPaymentBanner(bannerWidth),
        ];
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: _bannerHeight,
              child: RepaintBoundary(
                child: PageView.builder(
                  controller: _controller,
                  onPageChanged: _onPageChanged,
                  itemCount: banners.length,
                  itemBuilder: (context, i) => VerticalWheelForwarder(
                    axisLock: _wheelAxisLock,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: _hPadding,
                      ),
                      child: banners[i],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            _Dots(listenable: _index, count: banners.length),
          ],
        );
      },
    );
  }

  Widget _buildSun88Banner() => WelcomeBannerCard(
    onTap: () => ref.read(mainContentProvider.notifier).goToSport(),
    color: const Color(0xFF050505),
    colorOverlay: AppColors.orange600.withValues(alpha: 0.45),
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
    overlayImageBuilder: (_) => Positioned(
      top: 0,
      right: -10,
      width: WelcomeBannerArt.sun88FitHeight,
      bottom: 0,
      child: ImageHelper.load(
        path: AppImages.imageLogoSun88,
        fit: BoxFit.cover,
        cacheWidth: 218,
      ),
    ),
  );

  Widget _buildPaymentBanner(double cardWidth) => WelcomeBannerCard(
    buttonText: 'Nạp tiền',
    onTap: () {
      if (!requireLogin(context, ref)) return;
      showDepositFlow(context, ref);
    },
    color: const Color(0xFF050505),
    colorOverlay: AppColors.yellow500.withValues(alpha: 0.4),
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
    overlayImageBuilder: (_) => Positioned(
      top: 0,
      right: 5,
      width: WelcomeBannerArt.second(cardWidth),
      bottom: 0,
      child: ImageHelper.load(
        path: AppImages.imageBannerPayment,
        fit: BoxFit.cover,
        cacheWidth: 320,
      ),
    ),
  );
}

class _Dots extends StatelessWidget {
  final ValueListenable<int> listenable;
  final int count;

  const _Dots({required this.listenable, required this.count});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: listenable,
      builder: (context, active, _) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(count, (i) {
          final isActive = i == active;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: isActive ? 18 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.yellow500
                  : AppColorStyles.contentPrimary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(3),
            ),
          );
        }),
      ),
    );
  }
}
