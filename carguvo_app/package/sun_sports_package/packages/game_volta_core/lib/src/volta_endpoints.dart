import 'volta_agent.dart';
import 'volta_http.dart';
import 'volta_platform.dart';
import 'volta_settings.dart';

class VoltaEndpoints {
  const VoltaEndpoints._();

  static VoltaSettings? get _settings => VoltaSettingService.instance.current;

  static String get exposeBase => _settings?.expose ?? '';

  static String get bettingBase => _settings?.betting ?? '';

  static String get gameApiBase => VoltaPlatform.instance.apiDomain;

  static String get socketUrl => _settings?.socket ?? '';

  static String get videoJsBase => _settings?.videoJs ?? '';

  static String get token => VoltaDebugOverrides.active
      ? VoltaDebugOverrides.token
      : VoltaPlatform.instance.userToken;

  static int get agentId => VoltaAgent.id;

  static bool get isReady => exposeBase.isNotEmpty && token.isNotEmpty;

  static String userByToken({bool legacy = false}) => legacy
      ? '$exposeBase/user/getUserByToken?token=$token'
      : '$exposeBase/api/v2/volta/getUserByToken?token=$token'
            '&agentId=$agentId';

  static String snapshot({int days = 1, bool isLive = true}) =>
      '$exposeBase/volta?agentId=$agentId&token=$token&days=$days'
      '&isLive=$isLive';

  static String statistics() => '$exposeBase/volta/statistics';

  static String eventStatistics(int leagueId, int eventId) =>
      '$exposeBase/volta/statistics/$leagueId/$eventId';

  static String playerStats(int eventId) =>
      '$exposeBase/volta/statistics/player?eventId=$eventId';

  static String ranking({int size = 10}) =>
      '$gameApiBase/gameapi/public/volta/ranking?size=$size';

  static String betHistory({int index = 0, int size = 50}) =>
      '$exposeBase/volta/bet/groupReporting?&check-total=true'
      '&index=$index&size=$size&status=Settled&status=Active';

  static const int brandTimezoneOffset = -420;

  static int get deviceTimezoneOffset =>
      -DateTime.now().timeZoneOffset.inMinutes;

  static bool _warnedTimezone = false;

  static void _warnIfForeignTimezone() {
    if (!voltaDebug || _warnedTimezone) return;
    final int device = deviceTimezoneOffset;
    if (device == brandTimezoneOffset) return;
    _warnedTimezone = true;
    voltaLog(() =>
      '🟠 Volta: máy đang ở múi giờ $device nhưng lịch sử vẫn gửi '
      '$brandTimezoneOffset (múi giờ nhà cái). Nếu người chơi thấy thiếu ván '
      'ở đầu/cuối ngày thì đây là chỗ phải chốt — docs/21 §5 mục 11.',
    );
  }

  static String resultHistory({
    required DateTime fromDate,
    int timezoneOffset = brandTimezoneOffset,
    int matchType = 4,
    int size = 20,
  }) =>
      '$exposeBase/volta/history'
      '?fromDate=${Uri.encodeComponent(_jsIso(fromDate))}'
      '&timezoneOffset=${_timezoneFor(timezoneOffset)}'
      '&matchType=$matchType&size=$size';

  static String _jsIso(DateTime value) {
    final DateTime utc = DateTime.fromMillisecondsSinceEpoch(
      value.millisecondsSinceEpoch,
      isUtc: true,
    );
    return utc.toIso8601String();
  }

  static int _timezoneFor(int value) {
    _warnIfForeignTimezone();
    return value;
  }

  static String placeBet() => '$bettingBase/volta/place-bet';

  static String ticketStatus(String ticketId) =>
      '$exposeBase/bet/getStatusByTicketId?ticketId=$ticketId&token=$token';

  static String liveLink(int eventId, {String brand = ''}) =>
      '$exposeBase/streaming/get-live-link/$eventId/?brand=$brand';
}
