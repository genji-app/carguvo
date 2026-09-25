import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:carguvo/core/theme/app_theme.dart';
import 'package:carguvo/routes/app_pages.dart';
import 'package:carguvo/routes/app_routes.dart';

/// App vỏ carguvo — chạy ở [AppMode.fake] (và là app duy nhất user thấy khi
/// chưa unlock). Tách khỏi `main.dart` để `RootGate` dựng được nó như một
/// nhánh cây, thay vì nó là root cố định.
class CarguvoApp extends StatelessWidget {
  const CarguvoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Carguvo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
      defaultTransition: Transition.fade,
      locale: const Locale('vi', 'VN'),
      fallbackLocale: const Locale('vi', 'VN'),
    );
  }
}
