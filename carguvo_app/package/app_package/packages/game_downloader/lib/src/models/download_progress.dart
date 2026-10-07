enum DownloadPhase {
  downloading,

  unzipping,

  done,
}

class DownloadProgress {
  final DownloadPhase phase;

  final double progress;

  final String? gamePath;

  const DownloadProgress({
    required this.phase,
    required this.progress,
    this.gamePath,
  });

  factory DownloadProgress.downloading(double p) =>
      DownloadProgress(phase: DownloadPhase.downloading, progress: p);

  factory DownloadProgress.unzipping(double p) =>
      DownloadProgress(phase: DownloadPhase.unzipping, progress: p);

  factory DownloadProgress.done(String gamePath) => DownloadProgress(
        phase: DownloadPhase.done,
        progress: 1.0,
        gamePath: gamePath,
      );

  @override
  String toString() =>
      'DownloadProgress(${phase.name}, ${(progress * 100).toStringAsFixed(0)}%)';
}
