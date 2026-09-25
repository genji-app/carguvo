import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/features/profile/deposit/presentation/widgets/crypto_container.dart';

class CryptoOverlay extends ConsumerStatefulWidget {
  const CryptoOverlay({super.key});

  @override
  ConsumerState<CryptoOverlay> createState() => _CryptoOverlayState();
}

class _CryptoOverlayState extends ConsumerState<CryptoOverlay> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return const CryptoContainer();
  }
}
