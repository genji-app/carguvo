import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carguvo/data/local/hive_service.dart';
import 'package:carguvo/routes/app_routes.dart';

class OnboardingController extends GetxController {
  final pageController = PageController();
  final currentPage = 0.obs;

  final pages = [
    const OnboardingPage(
      icon: Icons.inventory_2_outlined,
      title: 'Quản lý hàng hóa dễ dàng',
      description:
          'Theo dõi từng kiện hàng trên xe của bạn.\n'
          'Không lo giao thiếu, giao nhầm.',
    ),
    const OnboardingPage(
      icon: Icons.local_shipping_outlined,
      title: 'Hàng còn trên xe',
      description:
          'Xem ngay danh sách hàng còn trên xe\n'
          'theo thời gian thực.',
    ),
    const OnboardingPage(
      icon: Icons.route_outlined,
      title: 'Quản lý chuyến xe',
      description:
          'Quản lý chuyến xe chuyên nghiệp\n'
          'ngay trên điện thoại của bạn.',
    ),
  ];

  void nextPage() {
    if (currentPage.value < pages.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      completeOnboarding();
    }
  }

  void skip() => completeOnboarding();

  Future<void> completeOnboarding() async {
    await HiveService.setOnboardingCompleted();
    Get.offAllNamed(AppRoutes.main);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}

class OnboardingPage {
  final IconData icon;
  final String title;
  final String description;

  const OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
  });
}
