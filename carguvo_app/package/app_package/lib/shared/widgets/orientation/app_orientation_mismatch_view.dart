import 'package:flutter/material.dart';
import 'package:orientation_guard/orientation_guard.dart';

class AppOrientationMismatchView extends StatelessWidget {
  const AppOrientationMismatchView({required this.policy, super.key});

  final OrientationPolicy policy;

  @override
  Widget build(BuildContext context) {
    final allowsLandscape = policy.allowsLandscape;
    final allowsPortrait = policy.allowsPortrait;

    final config = OrientationScope.configOf(context);
    final experience = OrientationExperienceClassifier.standard.classify(
      context,
      config,
    );
    final isDesktop = isDesktopWebPlatform(config);
    final canRotate = !isDesktop && experience.canRotate;

    final String title;
    final String message;

    if (allowsLandscape && !allowsPortrait) {
      title = canRotate
          ? 'Vui lòng xoay thiết bị sang ngang'
          : 'Vui lòng chỉnh cửa sổ sang chế độ ngang';
      message = 'Màn hình này hiển thị tốt nhất ở chế độ ngang.';
    } else if (allowsPortrait && !allowsLandscape) {
      title = canRotate
          ? 'Vui lòng xoay thiết bị về màn hình dọc'
          : 'Vui lòng chỉnh cửa sổ sang chế độ dọc';
      message = 'Màn hình này hiển thị tốt nhất ở chế độ dọc.';
    } else {
      title = canRotate
          ? 'Vui lòng xoay thiết bị'
          : 'Vui lòng chỉnh kích thước cửa sổ';
      message = 'Màn hình này cần một hướng hiển thị khác.';
    }

    return OrientationMismatchView(
      policy: policy,
      title: title,
      message: message,
    );
  }
}
