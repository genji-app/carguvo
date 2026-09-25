import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carguvo/core/theme/app_colors.dart';
import 'package:carguvo/core/theme/app_dimensions.dart';
import 'package:carguvo/core/theme/app_typography.dart';
import 'package:carguvo/modules/onboarding/controllers/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingLG),
                child: Obx(
                  () => controller.currentPage.value < 2
                      ? TextButton(
                          onPressed: controller.skip,
                          child: Text(
                            'Bỏ qua',
                            style: AppTypography.labelMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        )
                      : const SizedBox(height: 48),
                ),
              ),
            ),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                itemCount: controller.pages.length,
                onPageChanged: (index) => controller.currentPage.value = index,
                itemBuilder: (context, index) {
                  final page = controller.pages[index];
                  return _OnboardingPageWidget(page: page);
                },
              ),
            ),

            // Indicators
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppDimensions.paddingXXL,
              ),
              child: Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    controller.pages.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: controller.currentPage.value == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: controller.currentPage.value == index
                            ? AppColors.primary
                            : AppColors.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusFull,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Button
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingXXL,
              ),
              child: Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: AppDimensions.buttonHeight,
                  child: ElevatedButton(
                    onPressed: controller.nextPage,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          controller.currentPage.value == 2
                              ? 'Bắt đầu'
                              : 'Tiếp tục',
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.paddingHuge),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageWidget extends StatelessWidget {
  final OnboardingPage page;

  const _OnboardingPageWidget({required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingHuge,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryLight,
                  AppColors.primary.withValues(alpha: 0.15),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(page.icon, size: 72, color: AppColors.primary),
          ),
          const SizedBox(height: 48),

          // Title
          Text(
            page.title,
            style: AppTypography.heading2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            page.description,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
