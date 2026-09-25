import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

import 'update_event.dart';
import 'update_state.dart';

class UpdateBloc extends Bloc<UpdateEvent, UpdateState> {
  UpdateBloc({
    required ShorebirdUpdater updater,
    UpdateTrack track = UpdateTrack.stable,
    bool autoUpdateEnabled = false,
    bool skipInitialCheck = false,
  }) : _updater = updater,
       _track = track,
       _autoUpdateEnabled = autoUpdateEnabled,
       super(const UpdateState()) {
    on<UpdateCheckRequested>(_onCheckRequested);
    on<UpdateDownloadRequested>(_onDownloadRequested);
    if (!_autoUpdateEnabled && !skipInitialCheck) {
      add(const UpdateCheckRequested());
    }
  }

  // ── Session flag ─────────────────────────────────────────────────────────
  //
  // Flag chỉ tồn tại trong process lifetime (static field = library-level).
  // Mục đích: ngăn infinite loop khi `RestartScope.executeRestartApp` fail
  // không kill được OS process và rơi vào fallback widget-remount.
  //
  // Kịch bản bug:
  //   1. Fresh install, có patch → handler thấy isFirstPatchOnBinary=true
  //      → gọi executeRestartWithFade với terminate=true
  //   2. Trên một số iOS setup, TerminateRestart không thật sự kill process
  //      (Apple hạn chế exit(0)) → fallback sang widget subtree remount
  //   3. Widget remount KHÔNG reload Shorebird VM → patch chưa apply
  //   4. SplashModeScreen mới mount → flow lại → shorebird vẫn báo
  //      restartRequired → handler lại thấy isFirstPatch=true → loop
  //
  // Flag này (static, survive widget remount trong cùng process) đảm bảo
  // silent restart chỉ được thử TỐI ĐA một lần mỗi process. Khi OS thực sự
  // kill process mới (user swipe quit, hoặc terminate=true thành công),
  // static field reset tự nhiên → patch được apply trên process mới.
  static bool _silentRestartAttemptedInSession = false;

  /// True khi đã thử silent restart (terminate=true) trong process hiện tại.
  /// Reset khi OS kill process mới.
  static bool get isSilentRestartAttemptedInSession =>
      _silentRestartAttemptedInSession;

  /// Đánh dấu đã thử silent restart. Gọi NGAY TRƯỚC khi invoke callback
  /// restart, để nếu callback dẫn đến widget remount thì flag đã set kịp.
  static void markSilentRestartAttempted() {
    _silentRestartAttemptedInSession = true;
  }

  /// Reset flag. Chỉ dùng trong test — không cần gọi trong production vì
  /// flag tự reset khi process mới start.
  @visibleForTesting
  static void resetSilentRestartFlagForTesting() {
    _silentRestartAttemptedInSession = false;
  }

  final ShorebirdUpdater _updater;
  final UpdateTrack _track;
  final bool _autoUpdateEnabled;

  Future<void> _onCheckRequested(
    UpdateCheckRequested event,
    Emitter<UpdateState> emit,
  ) async {
    emit(
      state.copyWith(
        status: UpdateFlowStatus.checking,
        message: _autoUpdateEnabled
            ? 'Auto checking for updates...'
            : 'Checking for updates...',
      ),
    );
    try {
      final status = await _updater.checkForUpdate(track: _track);
      switch (status) {
        case UpdateStatus.restartRequired:
          emit(
            state.copyWith(
              status: UpdateFlowStatus.restartRequired,
              message: 'Patch ready. Restart to apply.',
            ),
          );
          break;
        case UpdateStatus.outdated:
          add(const UpdateDownloadRequested());
          break;
        default:
          if (!_autoUpdateEnabled) {
            emit(
              state.copyWith(
                status: UpdateFlowStatus.upToDate,
                message: 'Status: $status',
              ),
            );
          } else {
            emit(state.copyWith(status: UpdateFlowStatus.upToDate));
          }
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: UpdateFlowStatus.error,
          message: 'Error checking for update: $e',
        ),
      );
    }
  }

  Future<void> _onDownloadRequested(
    UpdateDownloadRequested event,
    Emitter<UpdateState> emit,
  ) async {
    emit(
      state.copyWith(
        status: UpdateFlowStatus.downloading,
        message: _autoUpdateEnabled ? null : 'Downloading patch...',
      ),
    );
    try {
      await _updater.update(track: _track);
      emit(
        state.copyWith(
          status: UpdateFlowStatus.restartRequired,
          message: 'Update downloaded. Tap restart to apply.',
        ),
      );
    } on UpdateException catch (error) {
      emit(
        state.copyWith(status: UpdateFlowStatus.error, message: error.message),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: UpdateFlowStatus.error,
          message: 'Error downloading update: $e',
        ),
      );
    }
  }

  /// Patch pending restart (download) or current; null if unavailable / read error.
  Future<int?> executeReadPendingPatchNumber() async {
    if (!_updater.isAvailable) {
      return null;
    }
    try {
      final Patch? nextPatch = await _updater.readNextPatch();
      if (nextPatch != null) {
        return nextPatch.number;
      }
      final Patch? currentPatch = await _updater.readCurrentPatch();
      return currentPatch?.number;
    } catch (_) {
      return null;
    }
  }

  /// Số patch đang được apply trên binary hiện tại (null nếu chưa có patch nào
  /// từng apply, hoặc lỗi đọc).
  Future<int?> executeReadCurrentPatchNumber() async {
    if (!_updater.isAvailable) {
      return null;
    }
    try {
      final Patch? currentPatch = await _updater.readCurrentPatch();
      return currentPatch?.number;
    } catch (_) {
      return null;
    }
  }

  /// Số patch đã download xong, chờ apply ở cold-start kế tiếp (null nếu
  /// không có patch chờ, hoặc lỗi đọc). Khác với [executeReadPendingPatchNumber]
  /// — method này CHỈ trả về nextPatch, không fallback về currentPatch.
  Future<int?> executeReadNextPatchNumber() async {
    if (!_updater.isAvailable) {
      return null;
    }
    try {
      final Patch? nextPatch = await _updater.readNextPatch();
      return nextPatch?.number;
    } catch (_) {
      return null;
    }
  }

  /// True khi chưa có patch nào từng apply trên binary đang chạy.
  ///
  /// Signal duy nhất: [readCurrentPatch] == null.
  ///
  /// Lý do KHÔNG check thêm [readNextPatch]:
  /// - Handler chỉ được gọi khi bloc fire [UpdateFlowStatus.restartRequired],
  ///   tức là bloc đã confirm có patch vừa download xong. Check lại qua API
  ///   là thừa.
  /// - Trên iOS, [readNextPatch] có thể trả [null] hoặc throw ngay sau
  ///   [update()] do timing / internal state khác Android → sẽ khiến check
  ///   kép fail oan và rẽ sang nhánh sai.
  ///
  /// Reset tự nhiên theo binary (fresh install / store update) vì Shorebird
  /// lưu patches trong app container (bị clear khi uninstall). Bền hơn
  /// SharedPreferences flag (NSUserDefaults có thể restore qua iCloud).
  ///
  /// Defensive: mọi exception → trả [false] (không liều silent-restart khi
  /// Shorebird state không đọc được).
  Future<bool> executeIsFirstPatchOnBinary() async {
    if (!_updater.isAvailable) {
      print(
        '[Unlock Shorebird] executeIsFirstPatchOnBinary: updater not available → false',
      );
      return false;
    }
    try {
      final Patch? currentPatch = await _updater.readCurrentPatch();
      final bool isFirst = currentPatch == null;
      print(
        '[Unlock Shorebird] executeIsFirstPatchOnBinary: '
        'currentPatch=${currentPatch?.number} → isFirst=$isFirst',
      );
      return isFirst;
    } catch (e) {
      print(
        '[Unlock Shorebird] executeIsFirstPatchOnBinary: exception=$e → false',
      );
      return false;
    }
  }
}
