import 'package:provider_game_manager/provider_game_manager.dart';
import 'package:game_downloader/game_downloader.dart';

enum CocosGameStatus {
  idle,
  preparing,

  readyToPlay,
  launching,
  active,
  error,
}

class CocosGameDownloadState {
  const CocosGameDownloadState({
    this.status = CocosGameStatus.idle,
    this.phase,
    this.progress = 0,
    this.gameName,
    this.game,
    this.gamePath,
    this.errorMessage,
  });

  final CocosGameStatus status;

  final DownloadPhase? phase;

  final double progress;

  final String? gameName;

  final LobbyGame? game;

  final String? gamePath;

  final String? errorMessage;

  bool get isDownloading => status == CocosGameStatus.preparing;

  bool get isBusy =>
      status == CocosGameStatus.preparing ||
      status == CocosGameStatus.launching;

  bool get hasError => status == CocosGameStatus.error;

  CocosGameDownloadState copyWith({
    CocosGameStatus? status,
    DownloadPhase? phase,
    double? progress,
    String? gameName,
    LobbyGame? game,
    String? gamePath,
    String? errorMessage,
  }) {
    return CocosGameDownloadState(
      status: status ?? this.status,
      phase: phase ?? this.phase,
      progress: progress ?? this.progress,
      gameName: gameName ?? this.gameName,
      game: game ?? this.game,
      gamePath: gamePath ?? this.gamePath,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
