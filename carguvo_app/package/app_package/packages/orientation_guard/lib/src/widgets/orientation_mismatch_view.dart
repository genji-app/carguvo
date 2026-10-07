import 'package:flutter/material.dart';

import '../models/orientation_experience.dart';
import '../models/orientation_policy.dart';
import 'orientation_scope.dart';

class OrientationMismatchView extends StatelessWidget {
  const OrientationMismatchView({
    super.key,
    required this.policy,
    this.title,
    this.message,
  });

  final OrientationPolicy policy;

  final String? title;

  final String? message;

  @override
  Widget build(BuildContext context) {
    final allowsLandscape = policy.allowsLandscape;
    final allowsPortrait = policy.allowsPortrait;

    final config = OrientationScope.configOf(context);
    final experience = OrientationExperienceClassifier.standard.classify(context, config);
    final isDesktop = isDesktopWebPlatform(config);
    final canRotate = !isDesktop && experience.canRotate;

    final String defaultTitle;
    final String defaultMessage;

    if (allowsLandscape && !allowsPortrait) {
      defaultTitle = canRotate
          ? 'Please rotate your device to landscape'
          : 'Please resize your window to landscape';
      defaultMessage = 'This screen requires a landscape orientation for the best experience.';
    } else if (allowsPortrait && !allowsLandscape) {
      defaultTitle = canRotate
          ? 'Please rotate your device to portrait'
          : 'Please resize your window to portrait';
      defaultMessage = 'This screen requires a portrait orientation.';
    } else {
      defaultTitle = canRotate ? 'Please rotate your device' : 'Please resize your window';
      defaultMessage = 'This screen requires a different orientation.';
    }

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Material(
        color: const Color(0xFF11100F),
        child: AbsorbPointer(
          absorbing: true,
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.screen_rotation_rounded,
                      size: 64,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      title ?? defaultTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      message ?? defaultMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
