import 'package:meta/meta.dart';
import 'volta_platform.dart';

class VoltaStrings {
  const VoltaStrings._();

  static String betError({String? key, int code = 0}) {
    final String? named = _normalizeKey(key);
    if (named != null) {
      final String? text = _lookup(named);
      if (text != null) return text;
      if (_looksLikeSentence(key!)) return key.trim();
      if (voltaDebug) {
        voltaLog(() => 'VoltaStrings: chưa có câu cho mã "$named" — dùng câu chung');
      }
      return _fallback;
    }
    final String? byCode = _codeToKey[code];
    if (byCode != null) {
      final String? text = _lookup(byCode);
      if (text != null) return text;
    }
    return _fallback;
  }

  @visibleForTesting
  static bool knows(String key) => _byKey.containsKey(_normalizeKey(key));

  static const String _fallback = 'Đặt cược thất bại, vui lòng thử lại';

  static String? _normalizeKey(String? raw) {
    if (raw == null) return null;
    final String text = raw.trim();
    if (text.isEmpty) return null;
    return text.toUpperCase().replaceAll('-', '_').replaceAll(' ', '_');
  }

  static bool _looksLikeSentence(String raw) => raw.trim().contains(' ');

  static String? _lookup(String key) => _brandOverride(key) ?? _byKey[key];

  static String? _brandOverride(String key) {
    final Object? table = VoltaPlatform.instance.brandConfig('volta_text');
    if (table is! Map) return null;
    final Object? value = table[key];
    return value is String && value.trim().isNotEmpty ? value.trim() : null;
  }

  static const Map<String, String> _byKey = <String, String>{
    'FUNDS_NOT_ENOUGH': 'Số dư không đủ, vui lòng nạp thêm',
    'MATCH_NOT_ACTIVE': 'Trận đấu không còn nhận cược',
    'MARKET_NOT_ACTIVE': 'Kèo đã đóng',
    'ODDS_CHANGED': 'Tỉ lệ cược vừa thay đổi, vui lòng thử lại',
    'SCORE_CHANGED': 'Tỉ số vừa thay đổi, vui lòng thử lại',
    'STAKE_TOO_SMALL': 'Số tiền cược thấp hơn mức tối thiểu',
    'STAKE_TOO_LARGE': 'Số tiền cược vượt mức tối đa',
    'ODDS_NOT_FOUND': 'Không tìm thấy kèo',
    'LIMIT_SETTING_NOT_FOUND': 'Kèo chưa được cấu hình, thử lại sau',
    'LIMIT_SETTING_LINE_STEP_NOT_FOUND': 'Kèo chưa được cấu hình, thử lại sau',
    'LIMIT_SETTING_MAIN_LINE_CLS_NOT_FOUND':
        'Kèo chưa được cấu hình, thử lại sau',
    'CLS_NOT_ALLOW': 'Kèo đã đóng',
    'WINNINGS_INCORRECT': 'Tiền thắng không khớp, vui lòng thử lại',
    'ODDS_IS_CLOSED': 'Kèo đã đóng',
    'PLAYER_STATUS_IS_BLOCKED': 'Tài khoản đang bị tạm khoá đặt cược',
    'MAX_STAKE_LOWER_THAN_MIN_STAKE': 'Kèo chưa được cấu hình, thử lại sau',
    'ODDS_STYLE_IS_NOT_SUPPORTED': 'Hệ tỉ lệ không được hỗ trợ',
    'OVER_PLAYER_MATCH_MAX_LIABILITY': 'Cửa này đã đạt giới hạn nhận cược',
    'OVER_MARKET_LAL': 'Cửa này đã đạt giới hạn nhận cược',
    'INVALID_CONTENT': 'Yêu cầu không hợp lệ',
    'BAD_REQUEST': 'Yêu cầu không hợp lệ',
    'GAME_MAINTAIN': 'Game đang bảo trì, vui lòng quay lại sau',
  };

  static const Map<int, String> _codeToKey = <int, String>{
    400: 'BAD_REQUEST',
    600: 'FUNDS_NOT_ENOUGH',
    601: 'MATCH_NOT_ACTIVE',
    602: 'MARKET_NOT_ACTIVE',
    603: 'ODDS_CHANGED',
    604: 'SCORE_CHANGED',
    605: 'STAKE_TOO_SMALL',
    606: 'STAKE_TOO_LARGE',
    607: 'ODDS_NOT_FOUND',
    608: 'LIMIT_SETTING_NOT_FOUND',
    609: 'LIMIT_SETTING_LINE_STEP_NOT_FOUND',
    610: 'LIMIT_SETTING_MAIN_LINE_CLS_NOT_FOUND',
    611: 'CLS_NOT_ALLOW',
    612: 'WINNINGS_INCORRECT',
    613: 'ODDS_IS_CLOSED',
    614: 'PLAYER_STATUS_IS_BLOCKED',
    615: 'MAX_STAKE_LOWER_THAN_MIN_STAKE',
    616: 'ODDS_STYLE_IS_NOT_SUPPORTED',
    617: 'OVER_PLAYER_MATCH_MAX_LIABILITY',
    618: 'OVER_MARKET_LAL',
  };
}
