class DownloadProgress {
  final String stage;
  final double percent;

  const DownloadProgress({required this.stage, required this.percent});

  @override
  String toString() => 'DownloadProgress($stage, ${(percent * 100).toStringAsFixed(1)}%)';
}
