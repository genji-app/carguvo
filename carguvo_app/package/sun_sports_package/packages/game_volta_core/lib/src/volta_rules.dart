import 'volta_platform.dart';

class VoltaRules {
  const VoltaRules._();

  static const int rebetCeiling = 40000000;

  static const int vsCells = 10;

  static const int betHistoryFetchSize = 50;

  static const int betHistoryPageSize = 5;

  static const int rankingSize = 10;

  static const int chatBufferLines = 30;

  static const int chatMaxChars = 50;

  static const int chatMinBalance = 20000;

  static String get chatRoom {
    final Object? configured =
        VoltaPlatform.instance.brandConfig('volta_chat_room');
    if (configured is String && configured.isNotEmpty) return configured;
    return defaultChatRoom;
  }

  static const String defaultChatRoom = 'volta';

  static const Duration httpTimeout = Duration(seconds: 10);

  static const Duration socketPing = Duration(seconds: 5);

  static const Duration socketPongTimeout = Duration(milliseconds: 12500);

  static const Duration resumeReconnectThreshold = Duration(seconds: 15);

  static const Duration linkDownAfter = Duration(seconds: 12);

  static const Duration balanceRefresh = Duration(seconds: 5);

  static const Duration ticketPoll = Duration(seconds: 3);

  static const Duration ticketTrackWindow = Duration(seconds: 15);

  static Duration get betClosedNoticeDelay =>
      VoltaPlatform.instance.isAndroid
      ? const Duration(milliseconds: 700)
      : const Duration(milliseconds: 450);

  static const double stakeGrowScale = 1.18;

  static const Duration stakeGrowDuration = Duration(milliseconds: 1200);

  static const Duration stakeShrinkDuration = Duration(milliseconds: 700);

  static const Duration stakeIdleBeforeShrink = Duration(milliseconds: 500);

  static const Duration betClosedNoticeDuration = Duration(seconds: 1);

  static const Duration tvKeepAfterResult = Duration(seconds: 4);

  static const String betClosedNotice = 'Đã hết thời gian đặt cược!';
}
