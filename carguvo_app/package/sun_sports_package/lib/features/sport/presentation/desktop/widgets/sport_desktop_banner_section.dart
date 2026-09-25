import 'package:flutter/material.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_images.dart';
import '../../../../../shared/widgets/cards/banner_card.dart';

class SportDesktopBannerSection extends StatelessWidget {
  const SportDesktopBannerSection({super.key});

  @override
  Widget build(BuildContext context) => Container(
    height: 163,
    margin: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        Expanded(
          child: BannerJoinCard(
            backgroundImage: ImageHelper.load(
              path: AppImages.backgroundJoin,
              fit: BoxFit.cover,
            ),
            amount: '\$50,000',
            buttonLabel: 'Tham gia ngay',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: BannerCard(
            backgroundImage: ImageHelper.load(
              path: AppImages.imageSoccer,
              fit: BoxFit.contain,
            ),
            title: 'Sun88',
            subtitle: 'Thương hiệu cá cược thể thao của SunWin',
            buttonLabel: 'Cược ngay',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: BannerCard(
            backgroundImage: ImageHelper.load(
              path: AppImages.imageTennis,
              fit: BoxFit.contain,
            ),
            title: 'Tennis',
            subtitle: 'Rút thăm may mắn',
            buttonLabel: 'Cược ngay',
          ),
        ),
      ],
    ),
  );
}
