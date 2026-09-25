import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sun_sports/core/utils/network_manger.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/widgets/buttons/shine_button.dart';

class NoConnectionScreen extends StatefulWidget {
  const NoConnectionScreen({required this.onRetry, super.key});

  final Future<void> Function() onRetry;

  @override
  State<NoConnectionScreen> createState() => _NoConnectionScreenState();
}

class _NoConnectionScreenState extends State<NoConnectionScreen> {
  static const Duration _retryTimeout = Duration(seconds: 30);

  StreamSubscription<NetworkManagerEvent>? _sub;

  bool _retrying = false;

  @override
  void initState() {
    super.initState();
    NetworkManager.instance.startListening();
    _sub = NetworkManager.instance.stream.listen((event) {
      if (event == NetworkManagerEvent.connectionRestored) _retry();
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _retry() async {
    if (_retrying || !mounted) return;
    setState(() => _retrying = true);
    try {
      await widget.onRetry().timeout(_retryTimeout);
    } catch (_) {
    }
    if (mounted) setState(() => _retrying = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorStyles.backgroundPrimary,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: const BoxDecoration(
                    color: AppColorStyles.backgroundTertiary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.wifi_off_rounded,
                    size: 48,
                    color: AppColors.yellow300,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Mất kết nối',
                  style: AppTextStyles.headingSmall(
                    color: AppColorStyles.contentPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Vui lòng kiểm tra kết nối mạng rồi thử lại.',
                  style: AppTextStyles.paragraphSmall(
                    color: AppColorStyles.contentSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: 240,
                  height: 48,
                  child: _retrying
                      ? const Center(
                          child: SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.yellow300,
                              ),
                            ),
                          ),
                        )
                      : ShineButton(
                          text: 'Kết nối lại',
                          height: 48,
                          width: double.infinity,
                          style: ShineButtonStyle.primaryYellow,
                          onPressed: _retry,
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
