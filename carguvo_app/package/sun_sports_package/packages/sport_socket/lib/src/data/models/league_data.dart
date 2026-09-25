class LeagueData {
  final int leagueId;

  final int sportId;

  String name;

  int priorityOrder;

  int leagueOrder;

  bool hasLeagueOrder = false;

  String? nameEn;

  String? logoUrl;

  bool cashout;

  String? countryCode;

  int _version = 0;

  int get version => _version;

  LeagueData({
    required this.leagueId,
    required this.sportId,
    required this.name,
    this.priorityOrder = 0,
    this.leagueOrder = 0,
    this.nameEn,
    this.logoUrl,
    this.cashout = false,
    this.countryCode,
  });

  factory LeagueData.fromJson(Map<String, dynamic> json) {
    final leagueId = _parseInt(json['leagueId'] ?? json['li']) ?? 0;
    final sportId = _parseInt(json['sportId'] ?? json['s']) ?? 0;

    final league = LeagueData(
      leagueId: leagueId,
      sportId: sportId,
      name: json['leagueName']?.toString() ?? json['ln']?.toString() ?? '',
    );

    league._applyJson(json);
    return league;
  }

  void updateFrom(Map<String, dynamic> data) {
    _applyJson(data);
    _version++;
  }

  void _applyJson(Map<String, dynamic> data) {
    if (data.containsKey('leagueName') || data.containsKey('ln')) {
      name = data['leagueName']?.toString() ?? data['ln']?.toString() ?? name;
    }

    if (data.containsKey('leaguePriorityOrder') || data.containsKey('lpo')) {
      priorityOrder = _parseInt(data['leaguePriorityOrder'] ?? data['lpo']) ??
          priorityOrder;
    }

    if (data.containsKey('leagueOrder') || data.containsKey('lo')) {
      leagueOrder = _parseInt(data['leagueOrder'] ?? data['lo']) ?? leagueOrder;
      hasLeagueOrder = true;
    }

    if (data.containsKey('leagueNameEn') || data.containsKey('lne')) {
      nameEn = data['leagueNameEn']?.toString() ?? data['lne']?.toString();
    }

    if (data.containsKey('leagueLogo') || data.containsKey('lg')) {
      logoUrl = data['leagueLogo']?.toString() ?? data['lg']?.toString();
    }

    if (data.containsKey('cashout')) {
      cashout = _parseBool(data['cashout']);
    }

    if (data.containsKey('countryCode') || data.containsKey('cc')) {
      countryCode = data['countryCode']?.toString() ?? data['cc']?.toString();
    }
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is num) return value.toInt();
    return null;
  }

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return false;
  }

  @override
  String toString() {
    return 'LeagueData(leagueId: $leagueId, sportId: $sportId, name: $name)';
  }
}
