/// Tag chung cho toàn bộ log chẩn đoán luồng "splash → mất kết nối".
///
/// Log này CỐ TÌNH trải qua nhiều package (unlock_shorebird_kit +
/// sun_sports_package + app shell) để có thể dựng lại timeline đầy đủ chỉ bằng
/// MỘT lệnh grep:
///
/// ```bash
/// flutter logs | grep NetDiag
/// adb logcat | grep NetDiag           # Android
/// idevicesyslog | grep NetDiag        # iOS
/// ```
///
/// Mỗi dòng có dạng:
/// `[NetDiag] 14:03:22.145 (+1234ms) | <SCOPE> | <message>`
///
/// - `14:03:22.145` là wall-clock — dùng cái này để sắp xếp thứ tự GIỮA các
///   package (mỗi package có clock riêng nên `+ms` không so sánh chéo được).
/// - `(+1234ms)` là thời gian kể từ dòng NetDiag đầu tiên của package này →
///   đọc là biết pha nào tốn bao nhiêu giây.
library;

const String kNetDiagTag = '[NetDiag]';

final Stopwatch _netDiagClock = Stopwatch()..start();

String _wallClock() {
  final DateTime now = DateTime.now();
  final String hh = now.hour.toString().padLeft(2, '0');
  final String mm = now.minute.toString().padLeft(2, '0');
  final String ss = now.second.toString().padLeft(2, '0');
  final String ms = now.millisecond.toString().padLeft(3, '0');
  return '$hh:$mm:$ss.$ms';
}

/// Log một dòng chẩn đoán mạng/splash.
///
/// Dùng [print] (KHÔNG phải `debugPrint`) để log xuất hiện trong CẢ
/// release/profile build — bắt buộc khi debug trên TestFlight / Play internal.
/// `debugPrint` còn bị throttle nên dễ nuốt dòng khi log dồn.
/// KHÔNG log dữ liệu nhạy cảm (token, password, số dư) qua hàm này.
void netDiag(String scope, String message) {
  // ignore: avoid_print
  print(
    '$kNetDiagTag ${_wallClock()} (+${_netDiagClock.elapsedMilliseconds}ms) '
    '| $scope | $message',
  );
}
