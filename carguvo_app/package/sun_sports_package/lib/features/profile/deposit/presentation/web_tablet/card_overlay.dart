import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/features/profile/deposit/presentation/widgets/card_container.dart';

class CardOverlay extends ConsumerStatefulWidget {
  const CardOverlay({super.key});

  @override
  ConsumerState<CardOverlay> createState() => _CardOverlayState();
}

class _CardOverlayState extends ConsumerState<CardOverlay> {
  @override
  Widget build(BuildContext context) {
    return const CardContainer();
  }
}
