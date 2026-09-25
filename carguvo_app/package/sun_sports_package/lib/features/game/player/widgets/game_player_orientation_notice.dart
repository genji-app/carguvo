import 'package:flutter/material.dart';
import 'package:orientation_guard/orientation_guard.dart';
import 'package:sun_sports/shared/widgets/orientation/app_orientation_mismatch_view.dart';

class GamePlayerOrientationNotice extends StatelessWidget {
  const GamePlayerOrientationNotice({required this.policy, super.key});

  final OrientationPolicy policy;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black87,
      child: AppOrientationMismatchView(policy: policy),
    );
  }
}
