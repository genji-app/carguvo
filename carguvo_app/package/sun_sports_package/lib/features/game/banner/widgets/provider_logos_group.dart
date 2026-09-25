import 'package:flutter/material.dart';
import 'package:sun_sports/features/game/banner/casino_provider_info.dart';
import 'package:sun_sports/features/game/banner/widgets/provider_logo_item.dart';

class ProviderLogosGroup extends StatelessWidget {
  const ProviderLogosGroup({
    super.key,
    this.providers,
    this.itemSize = 72,
    this.spacing = 8,
    this.onProviderSelected,
  });

  final List<CasinoProviderInfo>? providers;
  final double itemSize;
  final double spacing;
  final ValueChanged<CasinoProviderInfo>? onProviderSelected;

  @override
  Widget build(BuildContext context) {
    final list = providers ?? CasinoProviderInfo.defaultProviders;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (var i = 0; i < list.length; i++) ...[
          if (i > 0) SizedBox(width: spacing),
          ProviderLogoItem(
            info: list[i],
            size: itemSize,
            onTap: onProviderSelected,
          ),
        ],
      ],
    );
  }
}
