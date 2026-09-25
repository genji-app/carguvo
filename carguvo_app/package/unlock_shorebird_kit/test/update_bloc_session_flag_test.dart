import 'package:flutter_test/flutter_test.dart';
import 'package:unlock_shorebird_kit/shorebird/update/bloc/update_bloc.dart';

/// Tests cho session flag chống infinite loop khi silent restart fail.
/// Flag này là static (library-level) → survive widget remount trong cùng
/// process, reset khi process mới start.
void main() {
  group('UpdateBloc session flag', () {
    setUp(() {
      // Reset flag trước mỗi test để không lẫn state giữa tests.
      UpdateBloc.resetSilentRestartFlagForTesting();
    });

    test('mặc định flag là false (simulate process mới start)', () {
      expect(UpdateBloc.isSilentRestartAttemptedInSession, false);
    });

    test('markSilentRestartAttempted() set flag thành true', () {
      expect(UpdateBloc.isSilentRestartAttemptedInSession, false);
      UpdateBloc.markSilentRestartAttempted();
      expect(UpdateBloc.isSilentRestartAttemptedInSession, true);
    });

    test(
      'flag là static — giữ state xuyên suốt nhiều lần read (simulate widget remount)',
      () {
        UpdateBloc.markSilentRestartAttempted();
        // Đọc flag nhiều lần (từ các instance khác nhau của code caller) —
        // phải luôn trả về true cho tới khi process chết.
        for (int i = 0; i < 10; i++) {
          expect(
            UpdateBloc.isSilentRestartAttemptedInSession,
            true,
            reason: 'Flag phải persist qua nhiều lần đọc (simulate widget remount iteration $i)',
          );
        }
      },
    );

    test(
      'resetSilentRestartFlagForTesting() chỉ để test — cho phép reset về false',
      () {
        UpdateBloc.markSilentRestartAttempted();
        expect(UpdateBloc.isSilentRestartAttemptedInSession, true);
        UpdateBloc.resetSilentRestartFlagForTesting();
        expect(UpdateBloc.isSilentRestartAttemptedInSession, false);
      },
    );

    test(
      'gọi markSilentRestartAttempted nhiều lần an toàn — idempotent',
      () {
        UpdateBloc.markSilentRestartAttempted();
        UpdateBloc.markSilentRestartAttempted();
        UpdateBloc.markSilentRestartAttempted();
        expect(UpdateBloc.isSilentRestartAttemptedInSession, true);
      },
    );
  });
}
