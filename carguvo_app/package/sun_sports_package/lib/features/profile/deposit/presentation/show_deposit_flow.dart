import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/features/profile/deposit/presentation/providers/deposit_form_providers.dart';
import 'package:sun_sports/features/profile/deposit/presentation/providers/deposit_overlay_provider.dart';
import 'package:sun_sports/features/profile/deposit/presentation/mobile/deposit_mobile_bottom_sheet.dart';
import 'package:sun_sports/features/profile/shared/wallet_flow_gate.dart';
import 'package:sun_sports/features/profile_hub/profile_hub.dart';
import 'package:sun_sports/shared/responsive/responsive_builder.dart';

void showDepositFlow(BuildContext context, WidgetRef ref) {
  resetDepositForms(ref);

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
          DepositMobileBottomSheet.show(context);
        } else {
          ProfileHub.maybeOf(context)?.close();
          ref.read(depositOverlayVisibleProvider.notifier).state = true;
        }
      },
    ),
  );
}
