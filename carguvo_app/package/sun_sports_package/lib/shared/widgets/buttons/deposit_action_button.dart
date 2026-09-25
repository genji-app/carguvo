import 'package:flutter/material.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class DepositActionButton extends StatelessWidget {
  final String text;

  final bool isEnabled;

  final VoidCallback? onTap;

  final double height;

  final EdgeInsets padding;

  const DepositActionButton({
    super.key,
    required this.text,
    required this.isEnabled,
    this.onTap,
    this.height = 44,
    this.padding = const EdgeInsets.fromLTRB(16, 16, 16, 40),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: InkWell(
          onTap: SoundTap.wrap(isEnabled ? onTap : null),
          borderRadius: BorderRadius.circular(100),
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                height: height,
                decoration: BoxDecoration(
                  color: isEnabled ? AppColors.yellow700 : AppColors.gray700,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              if (isEnabled)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.0, 0.55232],
                          colors: [
                            Colors.white.withValues(alpha: 0.24),
                            Colors.white.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              Center(
                child: Text(
                  text,
                  style: AppTextStyles.textStyle(
                    fontSize: 16,
                    fontWeight: isEnabled ? FontWeight.w500 : FontWeight.w600,
                    color: isEnabled ? Colors.white : AppColors.gray500,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
