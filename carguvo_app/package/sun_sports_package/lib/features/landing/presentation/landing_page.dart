import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/providers/pending_toast_provider.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/core/utils/styles/app_images.dart';
import 'package:sun_sports/features/auth/presentation/desktop/screens/auth_desktop_screen.dart';
import 'package:sun_sports/shared/widgets/buttons/shine_button.dart';
import 'package:sun_sports/shared/widgets/toast/app_toast.dart';

final _showLoginPageProvider = StateProvider.autoDispose<bool>((ref) => false);

class LandingPage extends ConsumerStatefulWidget {
  const LandingPage({super.key});

  @override
  ConsumerState<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends ConsumerState<LandingPage> {
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _showPendingToast();
    });
  }

  void _showPendingToast() {
    final pendingToast = ref.read(pendingToastProvider);
    if (pendingToast != null) {
      ref.read(pendingToastProvider.notifier).state = null;

      if (mounted) {
        if (pendingToast.isError) {
          AppToast.showError(
            context,
            message: pendingToast.message,
            title: pendingToast.title,
            duration: pendingToast.duration ?? const Duration(seconds: 5),
          );
        } else {
          AppToast.showSuccess(
            context,
            message: pendingToast.message,
            title: pendingToast.title,
            duration: pendingToast.duration ?? const Duration(seconds: 5),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final showLoginPage = ref.watch(_showLoginPageProvider);

    if (showLoginPage) {
      return const AuthDesktopScreen(showLogin: true);
    }

    return Scaffold(
      backgroundColor: AppColorStyles.backgroundPrimary,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ImageHelper.load(
              path: AppImages.headerShadow,
              fit: BoxFit.fill,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ImageHelper.load(
                  path: AppImages.logoUrl,
                  width: 200,
                  height: 80,
                  fit: BoxFit.contain,
                ),
                const Gap(24),
                Text(
                  'Chào mừng đến với Sun88',
                  style: AppTextStyles.headingSmall(color: Colors.white),
                ),
                const Gap(8),
                Text(
                  'Nền tảng cá cược thể thao hàng đầu',
                  style: AppTextStyles.paragraphMedium(color: Colors.white70),
                ),
                const Gap(48),
                ShineButton(
                  text: 'Tham gia ngay',
                  style: ShineButtonStyle.primaryYellow,
                  width: 200,
                  onPressed: () {
                    ref.read(_showLoginPageProvider.notifier).state = true;
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
