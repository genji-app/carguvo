import 'package:flutter/material.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';

class ParlayLoadingButton extends StatelessWidget {
  final double height;
  final double? width;

  const ParlayLoadingButton({super.key, this.height = 40, this.width});

  @override
  Widget build(BuildContext context) => Container(
    width: width ?? double.infinity,
    height: height,
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
    decoration: BoxDecoration(
      color: AppColors.gray600,
      borderRadius: BorderRadius.circular(100),
    ),
    child: const Center(
      child: SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.gray300),
        ),
      ),
    ),
  );
}
