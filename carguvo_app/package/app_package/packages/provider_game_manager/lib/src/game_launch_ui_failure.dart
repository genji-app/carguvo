part of '../provider_game_manager.dart';

class GameLaunchUiFailure implements Exception {
  const GameLaunchUiFailure({
    required this.code,
    required this.title,
    required this.subtitle,
    this.retryable = false,
  });

  final String code;
  final String title;
  final String subtitle;
  final bool retryable;

  static const network = GameLaunchUiFailure(
    code: 'GP_NETWORK',
    title: 'Không có kết nối mạng',
    subtitle: 'Kiểm tra kết nối và thử lại',
    retryable: true,
  );

  static const server = GameLaunchUiFailure(
    code: 'GP_SERVER_ERROR',
    title: 'Lỗi máy chủ',
    subtitle: 'Máy chủ gặp sự cố, vui lòng thử lại',
    retryable: true,
  );

  static const sessionExpired = GameLaunchUiFailure(
    code: 'GP_SESSION_EXPIRED',
    title: 'Phiên đăng nhập hết hạn',
    subtitle: 'Vui lòng đăng nhập lại để tiếp tục',
  );

  static const missingUrl = GameLaunchUiFailure(
    code: 'GP_MISSING_URL',
    title: 'Không tìm thấy game',
    subtitle: 'Không lấy được địa chỉ trò chơi',
  );

  static const maintenance = GameLaunchUiFailure(
    code: 'GP_MAINTENANCE',
    title: 'Game đang bảo trì.',
    subtitle: 'Xin quay lại sau!',
  );

  static const comingSoon = GameLaunchUiFailure(
    code: 'GP_COMING_SOON',
    title: 'Game sắp ra mắt',
    subtitle: 'Nội dung này chưa được phát hành',
  );

  static const unavailable = GameLaunchUiFailure(
    code: 'GP_UNAVAILABLE',
    title: 'Game không khả dụng',
    subtitle: 'Game này hiện đang tạm dừng hoặc đang phát triển',
  );

  static const loadTimeout = GameLaunchUiFailure(
    code: 'GP_LOAD_TIMEOUT',
    title: 'Tải game quá lâu',
    subtitle: 'Vui lòng kiểm tra kết nối mạng hoặc thử lại',
    retryable: true,
  );

  static GameLaunchUiFailure business(String message) => GameLaunchUiFailure(
    code: 'GP_UNKNOWN',
    title: message.isEmpty ? 'Đã xảy ra lỗi.' : message,
    subtitle: '',
  );

  @override
  String toString() => '$code: $title';
}

String redactGameUrl(String url) {
  var result = url;
  for (final key in const {'accessToken', 'refreshToken', 'token'}) {
    result = result.replaceAllMapped(
      RegExp('([?&]$key=)([^&]*)'),
      (m) => '${m[1]}${_maskToken(m[2] ?? '')}',
    );
  }
  return result;
}

String _maskToken(String value) {
  if (value.length <= 8) return '***';
  return '${value.substring(0, 4)}…${value.substring(value.length - 4)}'
      '(${value.length})';
}
