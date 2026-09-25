import 'package:flutter/foundation.dart';
import 'package:sun_sports/core/utils/styles/app_images.dart';

@immutable
class CasinoProviderInfo {
  const CasinoProviderInfo({
    required this.id,
    required this.name,
    required this.imageAsset,
    this.categoryId,
  });

  final String id;

  final String name;

  final String imageAsset;

  final String? categoryId;

  static final List<CasinoProviderInfo> defaultProviders = [
    CasinoProviderInfo(
      id: 'sunwin',
      name: 'SunWin',
      imageAsset: AppImages.nccSunwin,
      categoryId: 'sunwin',
    ),
    CasinoProviderInfo(
      id: 'lcevo',
      name: 'Evolution',
      imageAsset: AppImages.nccEvo,
      categoryId: 'live',
    ),
    CasinoProviderInfo(
      id: 'pp',
      name: 'Pragmatic Play',
      imageAsset: AppImages.nccPp,
      categoryId: 'live',
    ),
    CasinoProviderInfo(
      id: 'vivo',
      name: 'Vivo Gaming',
      imageAsset: AppImages.nccVivo,
      categoryId: 'live',
    ),
    CasinoProviderInfo(
      id: 'amb-vn',
      name: 'Sexy Gaming',
      imageAsset: AppImages.nccSexy,
      categoryId: 'live',
    ),
  ];
}
