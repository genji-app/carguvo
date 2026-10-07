library;

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_package/core/utils/extensions/image_helper.dart';
import 'package:app_package/core/utils/styles/app_color_styles.dart';
import 'package:app_package/core/utils/styles/app_images.dart';
import 'package:app_package/core/utils/styles/app_text_styles.dart';
import 'package:app_package/features/game/game.dart';
import 'package:app_package/features/home/presentation/providers/home_category_provider.dart';
import 'package:app_package/providers/casino_provider_menu_provider.dart';
import 'package:app_package/shared/widgets/buttons/sound_tap.dart';
import 'package:app_package/shared/widgets/scroll/scroll.dart';

const Map<String, String> _kLabels = {
  'sun': 'Sunwin',
  'ncc:lcevo': 'Evo',
  'ncc:via-casino-vn': 'Via',
  'ncc:amb-vn': 'Sexy GM',
  'ncc:vivo': 'Vivo',
};

const Map<String, ({double width, double height})> _kLogoSizes =
    <String, ({double width, double height})>{
      'sun': (width: 41, height: 39),
      'amb-vn': (width: 66, height: 25.6),
      'lcevo': (width: 54, height: 21),
      'via-casino-vn': (width: 52, height: 29),
      'vivo': (width: 64.26, height: 26.18),
    };

({String asset, double width, double height}) _logoOf(LobbyCategory provider) {
  final String providerId = provider.id.startsWith('ncc:')
      ? provider.id.substring(4)
      : provider.id;
  final String? asset = casinoProviderLogo(provider);
  final ({double width, double height})? size = _kLogoSizes[providerId];
  if (asset == null || size == null) {
    return (
      asset: casinoProviderMenuIcons(provider).active,
      width: 40,
      height: 40,
    );
  }
  return (asset: asset, width: size.width, height: size.height);
}

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
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 24 / 14,
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
                    if (i > 0) const SizedBox(width: 9),
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
    final ({String asset, double width, double height}) logo = _logoOf(
      provider,
    );
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
              width: 88,
              height: 50,
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(
                color: Color(0xFF111010),
                borderRadius: BorderRadius.all(Radius.circular(15)),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: -115.16,
                    top: -128.96,
                    width: 465.67,
                    height: 296.31,
                    child: IgnorePointer(
                      child: Opacity(
                        opacity: 0.4,
                        child: ImageHelper.load(
                          path: AppImages.bgProviderCard,
                          width: 465.67,
                          height: 296.31,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 5,
                    ),
                    child: Center(
                      child: ImageHelper.load(
                        path: logo.asset,
                        width: logo.width,
                        height: logo.height,
                        fit: BoxFit.contain,
                      ),
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
