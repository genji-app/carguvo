part of '../provider_game_manager.dart';

sealed class ProviderGamePlayDecision {
  const ProviderGamePlayDecision();
}

class PlayDecisionBusy extends ProviderGamePlayDecision {
  const PlayDecisionBusy();
}

class PlayDecisionNeedLogin extends ProviderGamePlayDecision {
  const PlayDecisionNeedLogin();
}

class PlayDecisionGameMaintaining extends ProviderGamePlayDecision {
  const PlayDecisionGameMaintaining(this.gameId);

  final int gameId;
}

class PlayDecisionNotEnoughMoney extends ProviderGamePlayDecision {
  const PlayDecisionNotEnoughMoney(this.gold, this.required);

  final int gold;
  final int required;
}

class PlayDecisionUnavailable extends ProviderGamePlayDecision {
  const PlayDecisionUnavailable(this.gameId, {this.reason});

  final int gameId;

  final String? reason;
}

class PlayDecisionOpenInNewTab extends ProviderGamePlayDecision {
  const PlayDecisionOpenInNewTab(this.url, this.game);

  final String url;
  final ProductProviderInfo game;
}

class PlayDecisionPlay extends ProviderGamePlayDecision {
  const PlayDecisionPlay(this.url, this.game);

  final String url;
  final ProductProviderInfo game;

  String get gameCode => game.gameCode;
  DefineOrientation get orientation => game.orientation;
}
