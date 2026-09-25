library;

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_images.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/game/game.dart';
import 'package:sun_sports/features/home/presentation/providers/home_category_provider.dart';
import 'package:sun_sports/providers/casino_provider_menu_provider.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';
import 'package:sun_sports/shared/widgets/scroll/scroll.dart';

const Map<String, String> _kLabels = {
  'sun': 'Sunwin',
  'ncc:lcevo': 'Evo',
  'ncc:via-casino-vn': 'Via',
  'ncc:amb-vn': 'Sexy GM',
  'ncc:vivo': 'Vivo',
};

class HomeMobileProviderSection extends ConsumerStatefulWidget {
  const HomeMobileProviderSection({super.key});

  @override
  ConsumerState<HomeMobileProviderSection> createState() =>
      _HomeMobileProviderSectionState();
}

class _HomeMobileProviderSectionState
    extends ConsumerState<HomeMobileProviderSection> {
  final ScrollGestureAxisLock _wheelAxisLock = ScrollGestureAxisLock();

  void _open(LobbyCategory provider) {
    ref
        .read(homeProviderFilterRequestProvider.notifier)
        .update(
          (HomeProviderFilterRequest? previous) => HomeProviderFilterRequest(
            providerId: provider.id,
            serial: (previous?.serial ?? 0) + 1,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final List<LobbyCategory> providers = ref.watch(
      casinoProviderCategoriesProvider,
    );
    if (providers.isEmpty) return const SizedBox.shrink();
    final ProviderGameManager manager = ref.watch(providerGameManagerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text(
            'Nhà cung cấp',
            style: AppTextStyles.textStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 24 / 16,
              color: AppColorStyles.contentPrimary,
            ),
          ),
        ),
        ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            scrollbars: false,
            dragDevices: PointerDeviceKind.values.toSet(),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: VerticalWheelForwarder(
              axisLock: _wheelAxisLock,
              child: Row(
                children: [
                  for (int i = 0; i < providers.length; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    _card(
                      providers[i],
                      _kLabels[providers[i].id] ??
                          casinoProviderMenuLabel(providers[i], manager),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _card(LobbyCategory provider, String label) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: SoundTap.wrap(() => _open(provider)),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            color: Color(0xFF252423),
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          child: Container(
            padding: const EdgeInsets.all(1),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(16)),
              gradient: RadialGradient(
                center: Alignment.topLeft,
                radius: 60 / 52,
                transform: _BorderFlareTransform(),
                colors: [
                  Color(0xFFF38744),
                  Color(0x94F38744),
                  Color(0x42F38744),
                  Color(0x0FF38744),
                  Color(0x00F38744),
                ],
                stops: [0.1, 0.3, 0.5, 0.7, 0.9],
              ),
            ),
            child: Container(
              constraints: const BoxConstraints(minWidth: 128),
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(
                color: Color(0xFF111010),
                borderRadius: BorderRadius.all(Radius.circular(15)),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: -115.2,
                    top: -129,
                    width: 465.67,
                    height: 296.31,
                    child: IgnorePointer(
                      child: ImageHelper.load(
                        path: AppImages.bgProviderCard,
                        width: 465.67,
                        height: 296.31,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 5,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox.square(
                          dimension: 40,
                          child: ImageHelper.load(
                            path: casinoProviderMenuIcons(provider).active,
                            width: 40,
                            height: 40,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          label,
                          maxLines: 1,
                          softWrap: false,
                          style: AppTextStyles.textStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            height: 20 / 14,
                            color: AppColorStyles.contentPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BorderFlareTransform extends GradientTransform {
  const _BorderFlareTransform();

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.identity()
        ..translateByDouble(bounds.left + 8, bounds.top, 0, 1)
        ..scaleByDouble(2, 1, 1, 1)
        ..translateByDouble(-bounds.left, -bounds.top, 0, 1);
}
