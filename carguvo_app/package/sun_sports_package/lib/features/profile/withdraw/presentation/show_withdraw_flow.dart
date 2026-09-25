import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/features/profile/shared/wallet_flow_gate.dart';
import 'package:sun_sports/features/profile/withdraw/presentation/providers/withdraw_overlay_provider.dart';
import 'package:sun_sports/features/profile/withdraw/presentation/mobile/withdraw_mobile_bottom_sheet.dart';
import 'package:sun_sports/features/profile_hub/profile_hub.dart';
import 'package:sun_sports/shared/responsive/responsive_builder.dart';

void showWithdrawFlow(BuildContext context, WidgetRef ref) {
  resetWithdrawForms(ref);

  final deviceType = ResponsiveBuilder.getDeviceType(context);
  final isMobileSheet =
      deviceType == DeviceType.mobile || deviceType == DeviceType.tablet;

  unawaited(
    openWalletFlowWithLoading(
      context: context,
      ref: ref,
      prefetch: () => prefetchWalletConfig(ref),
      open: () {
        if (isMobileSheet) {
          WithdrawMobileBottomSheet.show(context);
        } else {
          ProfileHub.maybeOf(context)?.close();
          ref.read(withdrawOverlayVisibleProvider.notifier).state = true;
        }
      },
    ),
  );
}
