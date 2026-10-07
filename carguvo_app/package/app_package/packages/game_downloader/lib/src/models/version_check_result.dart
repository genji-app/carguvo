class VersionCheckResult {
  final bool isSynced;

  final bool needsDownload;

  final String? localVersion;
  final String serverVersion;
  final String downloadUrl;

  final String? localGamePath;

  const VersionCheckResult({
    required this.isSynced,
    required this.needsDownload,
    required this.localVersion,
    required this.serverVersion,
    required this.downloadUrl,
    required this.localGamePath,
  });
}
