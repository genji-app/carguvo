import 'package:flutter/material.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';

class SplashNetworkBanner extends StatelessWidget {
  const SplashNetworkBanner.offline({super.key}) : online = false;

  const SplashNetworkBanner.online({super.key}) : online = true;

  final bool online;

  static const double kContentHeight = 44.0;

  static const Color _offlineBackground = Color(0xFF35110A);
  static const Color _offlineForeground = Color(0xFFF8655B);
  static const Color _onlineBackground = Color(0xFF1B3D1B);
  static const Color _onlineForeground = Color(0xFF4ADE80);

  @override
  Widget build(BuildContext context) {
    final background = online ? _onlineBackground : _offlineBackground;
    final foreground = online ? _onlineForeground : _offlineForeground;
    final text = online
        ? 'Đã kết nối'
        : 'Không kết nối mạng. Đang kết nối…';

    return Material(
      color: background,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            height: kContentHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  online ? Icons.wifi_rounded : Icons.wifi_off_rounded,
                  color: foreground,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    text,
                    style: AppTextStyles.paragraphSmall(color: foreground),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
