import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carguvo/core/theme/app_colors.dart';
import 'package:carguvo/modules/main/controllers/main_controller.dart';
import 'package:carguvo/modules/dashboard/views/dashboard_view.dart';
import 'package:carguvo/modules/trips/views/trip_list_view.dart';
import 'package:carguvo/modules/cargo/views/cargo_list_view.dart';
import 'package:carguvo/modules/delivery_points/views/delivery_point_list_view.dart';
import 'package:carguvo/modules/settings/views/settings_view.dart';

class MainView extends GetView<MainController> {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    const pages = [
      DashboardView(),
      TripListView(),
      CargoListView(),
      DeliveryPointListView(),
      SettingsView(),
    ];

    return Scaffold(
      body: Obx(
        () =>
            IndexedStack(index: controller.currentIndex.value, children: pages),
      ),
      bottomNavigationBar: Obx(
        () => Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: controller.currentIndex.value,
            onTap: controller.changePage,
            items: controller.navItems
                .map(
                  (item) => BottomNavigationBarItem(
                    icon: Icon(item.icon),
                    activeIcon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(item.icon),
                    ),
                    label: item.label,
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
