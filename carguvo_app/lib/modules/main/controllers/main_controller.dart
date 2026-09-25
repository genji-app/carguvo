import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainController extends GetxController {
  final currentIndex = 0.obs;

  void changePage(int index) {
    currentIndex.value = index;
  }

  final List<BottomNavItem> navItems = [
    BottomNavItem(icon: Icons.home_rounded, label: 'Trang chủ'),
    BottomNavItem(icon: Icons.local_shipping_rounded, label: 'Chuyến xe'),
    BottomNavItem(icon: Icons.inventory_2_rounded, label: 'Hàng hóa'),
    BottomNavItem(icon: Icons.location_on_rounded, label: 'Điểm giao'),
    BottomNavItem(icon: Icons.settings_rounded, label: 'Cài đặt'),
  ];
}

class BottomNavItem {
  final IconData icon;
  final String label;

  BottomNavItem({required this.icon, required this.label});
}
