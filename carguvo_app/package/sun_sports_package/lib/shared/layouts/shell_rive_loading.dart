import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;
import 'package:sun_sports/core/utils/extensions/rive_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_rive.dart';

class ShellRiveLoading extends StatefulWidget {
  const ShellRiveLoading({super.key});

  @override
  State<ShellRiveLoading> createState() => _ShellRiveLoadingState();
}

class _ShellRiveLoadingState extends State<ShellRiveLoading> {
  static Future<rive.File?>? _fileFuture;

  static const int _maxAttempts = 3;
  static const Duration _retryDelay = Duration(milliseconds: 1200);

  rive.RiveWidgetController? _controller;
  int _attempt = 0;
  Timer? _retryTimer;

  @override
  void initState() {
    super.initState();
    unawaited(_loadRiveFile());
  }

  Future<void> _loadRiveFile() async {
    _attempt++;
    try {
      final file =
      await (_fileFuture ??= RiveHelper.getFile(AppRive.animLoading));
      if (!mounted) {
        return;
      }
      if (file != null) {
        setState(() {
          _controller = rive.RiveWidgetController(file);
        });
        return;
      }
      _fileFuture = null;
      _scheduleRetry();
    } catch (_) {
      _fileFuture = null;
      _scheduleRetry();
    }
  }

  void _scheduleRetry() {
    if (!mounted || _attempt >= _maxAttempts) {
      return;
    }
    _retryTimer?.cancel();
    _retryTimer = Timer(_retryDelay, () {
      if (!mounted) {
        return;
      }
      unawaited(_loadRiveFile());
    });
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorStyles.backgroundSecondary,
      body: Center(
        child: _controller != null
            ? SizedBox(
          width: 400,
          height: 400,
          child: rive.RiveWidget(
            controller: _controller!,
            fit: rive.Fit.contain,
          ),
        )
            : const SizedBox(
          width: 36,
          height: 36,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColorStyles.contentPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
