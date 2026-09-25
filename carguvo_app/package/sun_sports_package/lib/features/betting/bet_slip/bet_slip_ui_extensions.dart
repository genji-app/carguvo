import 'package:flutter/material.dart';
import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/core/services/models/league_model.dart';
import 'package:sun_sports/core/services/repositories/my_bet_repository/my_bet_repository.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';

const int _outrightMarketId = 35;

bool _settlementShowsScore(SettlementStatusEnum s) => switch (s) {
  SettlementStatusEnum.won ||
  SettlementStatusEnum.lost ||
  SettlementStatusEnum.draw ||
  SettlementStatusEnum.halfWon ||
  SettlementStatusEnum.halfLost => true,
  _ => false,
};

extension SettlementStatusUIExt on SettlementStatusEnum {
  String get label => switch (this) {
    SettlementStatusEnum.won => I18n.txtWon,
    SettlementStatusEnum.lost => I18n.txtLost,
    SettlementStatusEnum.halfWon => I18n.txtHalfWon,
    SettlementStatusEnum.halfLost => I18n.txtHalfLost,
    SettlementStatusEnum.draw => I18n.txtDraw,
    SettlementStatusEnum.voided => I18n.txtCancel,
    SettlementStatusEnum.refunded => I18n.txtRefunded,
    SettlementStatusEnum.cashout => I18n.txtSold,
    SettlementStatusEnum.declined => I18n.txtDeclined,
    SettlementStatusEnum.processing => I18n.txtProcessing,
    SettlementStatusEnum.running => I18n.txtCurrentlyActive,
    _ => I18n.txtPending,
  };

  String get parlayLabel => switch (this) {
    SettlementStatusEnum.won => I18n.txtWonParlay,
    SettlementStatusEnum.lost => I18n.txtLostParlay,
    SettlementStatusEnum.draw => I18n.txtDrawParlay,
    _ => label,
  };

  Color get color => switch (this) {
    SettlementStatusEnum.won ||
    SettlementStatusEnum.halfWon => AppColors.green400,
    SettlementStatusEnum.lost ||
    SettlementStatusEnum.halfLost => AppColors.red400,
    SettlementStatusEnum.draw ||
    SettlementStatusEnum.voided ||
    SettlementStatusEnum.refunded ||
    SettlementStatusEnum.declined => AppColors.gray300,
    SettlementStatusEnum.cashout => AppColors.blue300,
    SettlementStatusEnum.processing => AppColors.yellow400,
    _ => AppColors.gray300,
  };
}

extension BetSlipUIExt on BetSlip {
  String get formattedStatus => settlementStatusEnum.label;

  bool get isOutright => marketId == _outrightMarketId;

  String get fullMatchNameWithScore {
    if (matchTypeEnum == MatchType.leagueBetting) {
      return 'CƯỢC ĐẶC BIỆT - $matchName';
    }
    if (!_settlementShowsScore(
      SettlementStatusEnum.fromString(settlementStatus),
    )) {
      return '$homeName vs $awayName';
    }
    return '$homeName $formattedScore $awayName';
  }

  String get displayScore => score.isEmpty ? '[0-0]' : score;

  String get fullMatchName {
    if (matchName != null && matchName!.isNotEmpty) return matchName!;
    return '$homeName vs $awayName';
  }

  String get displayMarketName {
    return MarketHelper.getMarketNameViDisplay(marketId);
  }

  String get formattedStake => '${(stake / 1000).toStringAsFixed(0)}K';

  String get formattedWinning => '${(winning / 1000).toStringAsFixed(1)}K';

  String get formattedScore {
    final s = score.isEmpty
        ? '0-0'
        : score.replaceAll('[', '').replaceAll(']', '');
    final ft = s.contains('-') && !s.contains(' - ')
        ? s.replaceAll('-', ' - ')
        : s;

    if (htScore != null && htScore!.isNotEmpty && htScore != '[0-0]') {
      final ht = htScore!
          .replaceAll('[', '')
          .replaceAll(']', '')
          .replaceAll('-', ' - ');
      return '$ft (HT $ht)';
    }
    return ft;
  }
}

extension ChildBetUIExt on ChildBet {
  String get formattedStatus => settlementStatusEnum.label;

  String get fullMatchNameWithScore {
    if (!_settlementShowsScore(settlementStatusEnum)) {
      return '$homeName vs $awayName';
    }
    return '$homeName $formattedScore $awayName';
  }

  String get displayMarketName => MarketHelper.getMarketNameViDisplay(marketId);

  String get formattedScore {
    final s = score.isEmpty
        ? '0-0'
        : score.replaceAll('[', '').replaceAll(']', '');
    final ft = s.contains('-') && !s.contains(' - ')
        ? s.replaceAll('-', ' - ')
        : s;

    if (htScore != null && htScore!.isNotEmpty && htScore != '[0-0]') {
      final ht = htScore!
          .replaceAll('[', '')
          .replaceAll(']', '')
          .replaceAll('-', ' - ');
      return '$ft (HT $ht)';
    }
    return ft;
  }
}
