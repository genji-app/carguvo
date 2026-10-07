class LivestreamResponse {
  final String? url;

  final String? status;

  final int? type;

  const LivestreamResponse({this.url, this.status, this.type});

  factory LivestreamResponse.fromJson(Map<String, dynamic> json) {
    final rawUrl = json['0']?.toString() ?? json['h5Link']?.toString();
    final status = json['4']?.toString() ?? json['status']?.toString();
    final type = _parseType(json['2'] ?? json['type']);

    final url = rawUrl != null && rawUrl.isNotEmpty
        ? _sanitizeLivestreamUrl(rawUrl)
        : null;

    return LivestreamResponse(url: url, status: status, type: type);
  }

  static int? _parseType(dynamic raw) {
    if (raw is int) return raw;
    if (raw is String) return int.tryParse(raw);
    return null;
  }

  static String _sanitizeLivestreamUrl(String url) {
    String s = url.trim();
    while (s.endsWith('=') || s.endsWith('?')) {
      s = s.substring(0, s.length - 1);
    }
    return s;
  }

  LivestreamResponse wrapWithPlayerDomain({
    required String videoDomain,
    required String virtualVideoDomain,
    int size = 75,
  }) {
    final raw = url;
    if (raw == null || raw.isEmpty) return this;

    final String domain;
    switch (type) {
      case 1:
      case 3:
        domain = videoDomain;
        break;
      case 2:
        domain = virtualVideoDomain;
        break;
      default:
        domain = '';
    }

    if (domain.isEmpty) return this;

    final base = domain.endsWith('/')
        ? domain.substring(0, domain.length - 1)
        : domain;
    final wrapped = '$base/?link=${Uri.encodeComponent(raw)}&size=$size';

    return LivestreamResponse(url: wrapped, status: status, type: type);
  }

  bool get hasUrl => url != null && url!.isNotEmpty;

  bool get isSuccess => status == 'OK' || hasUrl;

  @override
  String toString() =>
      'LivestreamResponse(url: $url, status: $status, type: $type)';
}
