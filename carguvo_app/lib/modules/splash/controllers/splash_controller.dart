import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:carguvo/data/local/hive_service.dart';
import 'package:carguvo/routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    debugPrint('DEBUG: SplashController.onInit called');
  }

  @override
  void onReady() {
    super.onReady();
    debugPrint('DEBUG: SplashController.onReady called');
    _navigate();
  }

  Future<void> _navigate() async {
    debugPrint('DEBUG: SplashController._navigate started (v5)');
    try {
      await Future.delayed(const Duration(seconds: 2));
      debugPrint('DEBUG: SplashController delay finished');

      bool isCompleted = false;
      try {
        isCompleted = HiveService.isOnboardingCompleted;
      } catch (e) {
        debugPrint('DEBUG: Error checking onboarding status: $e');
      }

      debugPrint(
        'DEBUG: Target Route determined: ${isCompleted ? 'MAIN' : 'ONBOARDING'}',
      );

      if (isCompleted) {
        Get.offAllNamed(AppRoutes.main);
      } else {
        Get.offAllNamed(AppRoutes.onboarding);
      }
      debugPrint('DEBUG: Get.offAllNamed successfully called');
    } catch (e) {
      debugPrint('DEBUG: Fatal error in _navigate: $e');
      // Emergency fallback
      debugPrint('DEBUG: Attempting emergency navigation to ONBOARDING');
      Get.offAllNamed(AppRoutes.onboarding);
    }
  }
}
