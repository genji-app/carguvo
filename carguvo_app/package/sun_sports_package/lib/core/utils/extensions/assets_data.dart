class AssetsData {
  const AssetsData({
    required this.label,
    required this.urlPath,
    required this.oldVersion,
    required this.newVersion,
  });

  final String label;
  final String urlPath;
  final int oldVersion;
  final int newVersion;
}
