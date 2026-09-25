import 'package:flutter/material.dart';
import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';

enum MyBetMenu { bettingSlip, myBets }

extension MyBetMenuEx on MyBetMenu {
  Widget get icon => switch (this) {
    MyBetMenu.bettingSlip => ImageHelper.load(path: AppIcons.icBettingSlip),
    MyBetMenu.myBets => ImageHelper.load(path: AppIcons.icMyBet),
  };

  String get label => switch (this) {
    MyBetMenu.bettingSlip => I18n.txtBettingSlip,
    MyBetMenu.myBets => I18n.txtMyBets,
  };
}
