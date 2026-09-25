import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/features/profile/deposit/presentation/widgets/giftcode_container.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/shared/widgets/cards/inner_shadow_card.dart';

class GiftCodeOverlay extends ConsumerStatefulWidget {
  const GiftCodeOverlay({super.key});

  @override
  ConsumerState<GiftCodeOverlay> createState() => _GiftCodeOverlayState();
}

class _GiftCodeOverlayState extends ConsumerState<GiftCodeOverlay> {
  @override
  Widget build(BuildContext context) {
    return const GiftCodeContainer();
  }
}
