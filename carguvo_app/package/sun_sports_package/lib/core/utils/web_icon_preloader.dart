import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';

class WebIconPreloader {
  static Future<void> preloadCriticalIcons(BuildContext context) async {
    if (!kIsWeb) return;

    final criticalIcons = [
      AppIcons.iconCurrencyUnit,
      AppIcons.iconHome,
      AppIcons.iconSoccer,
      AppIcons.iconMenu,
      AppIcons.iconBet,
      AppIcons.iconCasino,
      AppIcons.iconHomeSport,
      AppIcons.iconComingSport,
      AppIcons.iconFavoriteSport,
    ];

    await _preloadIcons(context, criticalIcons);
  }

  static Future<void> preloadAllIcons(BuildContext context) async {
    if (!kIsWeb) return;

    final allIcons = [
      AppIcons.iconCurrencyUnit,
      AppIcons.iconHome,
      AppIcons.iconSoccer,
      AppIcons.iconMenu,
      AppIcons.iconBet,
      AppIcons.iconCasino,
      AppIcons.iconBasketballSelected,
      AppIcons.iconBet1Selected,
      AppIcons.iconChatSelected,
      AppIcons.iconEmojiSelected,
      AppIcons.iconFootballSelected,
      AppIcons.iconMenuSelected,
      AppIcons.iconMobileSelected,
      AppIcons.iconNewsSelected,
      AppIcons.iconSettingSelected,
      AppIcons.iconSupportSelected,
      AppIcons.iconTennisSelected,
      AppIcons.iconTimerSelected,
      AppIcons.iconTransferSelected,
      AppIcons.iconHomeSport,
      AppIcons.iconComingSport,
      AppIcons.iconFavoriteSport,

    ];

    await _preloadIcons(context, allIcons);
  }

  static Future<void> preloadIcons(
    BuildContext context,
    List<String> iconUrls,
  ) async {
    if (!kIsWeb) return;
    await _preloadIcons(context, iconUrls);
  }

  static Future<void> _preloadIcons(
    BuildContext context,
    List<String> iconUrls,
  ) async {
    if (!kIsWeb || iconUrls.isEmpty) return;

    try {
      final futures = iconUrls.map((url) async {
        try {
          final isSvg = url.toLowerCase().endsWith('.svg');

          if (isSvg) {
            await ImageHelper.precacheSVG(context, url);
          } else {
            await ImageHelper.precacheNetworkImage(context, url);
          }
        } catch (e) {
        }
      });

      await Future.wait(futures);
    } catch (e) {
    }
  }
}
