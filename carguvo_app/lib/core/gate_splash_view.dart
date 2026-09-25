import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:carguvo/core/theme/app_colors.dart';

/// Splash của GATE (chạy TRƯỚC khi biết sẽ vào cover hay betting).
///
/// Cố ý KHÔNG dùng GetX / controller: nó sống ngoài `GetMaterialApp` của
/// carguvo. Giao diện để giống app carguvo thật, vì đây là màn user thấy
/// đầu tiên ở mọi mode.
class GateSplashView extends StatelessWidget {
  const GateSplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: const CupertinoActivityIndicator(
              radius: 11,
              color: AppColors.primary,
            ),
      ),
    );
  }
}
