/// Tag duy nhất cho toàn bộ log trong package `unlock_shorebird_kit`.
/// Filter trong `flutter logs` bằng:
///
/// ```bash
/// flutter logs | grep "\[Unlock Shorebird\]"
/// ```
const String kUnlockShorebirdTag = '[Unlock Shorebird]';

/// Helper tiện log có sẵn TAG. Dùng [print] (KHÔNG phải [debugPrint]) để log
/// xuất hiện trong CẢ release/profile build — cần cho debug Shorebird flow
/// trên TestFlight/Play internal track. Trade-off: log vẫn xuất hiện trên
/// production, có thể leak thông tin → cẩn thận đừng log dữ liệu nhạy cảm.
///
/// Example:
/// ```dart
/// logUS('Step 1 start: check local unlock key');
/// // Output: [Unlock Shorebird] Step 1 start: check local unlock key
/// ```
void logUS(String message) {
  // ignore: avoid_print
  print('$kUnlockShorebirdTag $message');
}
