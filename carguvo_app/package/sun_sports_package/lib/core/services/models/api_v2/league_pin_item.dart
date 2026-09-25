class LeaguePinItem {
  const LeaguePinItem({
    required this.leagueId,
    required this.name,
    required this.logoUrl,
    required this.sortOrder,
  });

  final int leagueId;
  final String name;
  final String logoUrl;
  final int sortOrder;
}
