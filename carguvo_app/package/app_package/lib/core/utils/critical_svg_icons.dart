import 'package:app_package/core/utils/styles/app_icons.dart';

class CriticalSvgIcons {
  CriticalSvgIcons._();

  static List<String> get paths => <String>[
        AppIcons.icMenu,
        AppIcons.icSearch,
        AppIcons.iconS,
        AppIcons.iconSSelected,
        AppIcons.iconCasino,
        AppIcons.iconCasinoSelected,
        AppIcons.iconBet,
        AppIcons.iconBetSelected,
        AppIcons.iconSoccer,
        AppIcons.iconSoccerSelected,
        AppIcons.iconMenu,
        AppIcons.iconMenuSelected,
        AppIcons.iconLivechat,
        AppIcons.iconChatSelected,
        AppIcons.iconNotification,
        AppIcons.iconVerified,
        AppIcons.profileAddMoneySelected,
        AppIcons.profileWithdraw,
        AppIcons.profileHistory,
        AppIcons.profileSecurity,
        AppIcons.profileSetting,
        AppIcons.profilePersonal,
        AppIcons.profileMailBox,
        AppIcons.profileSupport,
        AppIcons.icSale,
        AppIcons.icTicket,
      ].where((p) => p.toLowerCase().endsWith('.svg')).toList(growable: false);
}
