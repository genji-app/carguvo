class GameVersion {
  final String version;
  final String downloadUrl;

  const GameVersion({
    required this.version,
    required this.downloadUrl,
  });

  @override
  String toString() => 'GameVersion(version: $version, url: $downloadUrl)';
}
