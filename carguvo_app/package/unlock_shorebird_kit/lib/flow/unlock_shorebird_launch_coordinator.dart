import 'dart:async';

import 'package:unlock_shorebird_kit/flow/store_version_gate.dart';
import 'package:unlock_shorebird_kit/flow/unlock_flow_coordinator.dart';
import 'package:unlock_shorebird_kit/shorebird/update/bloc/update_bloc.dart';
import 'package:unlock_shorebird_kit/shorebird/update/bloc/update_event.dart';
import 'package:unlock_shorebird_kit/shorebird/update/bloc/update_state.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

/// Runs [UnlockFlowCoordinator] and blocks entry to [AppMode.betting] until
/// Shorebird reaches a terminal state ([UpdateFlowStatus.upToDate],
/// [UpdateFlowStatus.restartRequired], or [UpdateFlowStatus.error]).
final class UnlockShorebirdLaunchCoordinator {
  UnlockShorebirdLaunchCoordinator({
    UnlockFlowCoordinator? unlockFlowCoordinator,
    ShorebirdUpdater? shorebirdUpdater,
    UpdateTrack shorebirdTrack = UpdateTrack.stable,
    StoreVersionGate storeVersionGate = const StoreVersionGate(),
  }) : _storeVersionGate = storeVersionGate,
       _unlockFlowCoordinator =
           unlockFlowCoordinator ?? UnlockFlowCoordinator(),
       _shorebirdUpdateBloc = UpdateBloc(
         updater: shorebirdUpdater ?? ShorebirdUpdater(),
         track: shorebirdTrack,
         autoUpdateEnabled: false,
         skipInitialCheck: true,
       );

  final UnlockFlowCoordinator _unlockFlowCoordinator;
  final StoreVersionGate _storeVersionGate;
  final UpdateBloc _shorebirdUpdateBloc;
  bool _isShorebirdGateRunning = false;

  UpdateBloc get shorebirdUpdateBloc => _shorebirdUpdateBloc;
  int? get minPatchForceUpdate => _unlockFlowCoordinator.minPatchForceUpdate;

  Future<int?> executeReadPendingPatchNumber() {
    return _shorebirdUpdateBloc.executeReadPendingPatchNumber();
  }

  /// Xem [UpdateBloc.executeReadCurrentPatchNumber].
  Future<int?> executeReadCurrentPatchNumber() {
    return _shorebirdUpdateBloc.executeReadCurrentPatchNumber();
  }

  /// Xem [UpdateBloc.executeReadNextPatchNumber].
  Future<int?> executeReadNextPatchNumber() {
    return _shorebirdUpdateBloc.executeReadNextPatchNumber();
  }

  /// Xem [UpdateBloc.executeIsFirstPatchOnBinary].
  Future<bool> executeIsFirstPatchOnBinary() {
    return _shorebirdUpdateBloc.executeIsFirstPatchOnBinary();
  }

  /// Releases Shorebird [UpdateBloc]. Call from [State.dispose] (e.g. via
  /// [unawaited]).
  Future<void> executeCloseResources() async {
    await _shorebirdUpdateBloc.close();
  }

  /// Parameters use [isActive] (typically `mounted`) so no UI runs after dispose.
  Future<void> executeUnlockFlowWithShorebirdGate({
    required void Function(AppMode mode) onAppModeSet,
    required Future<bool> Function() onConnectionErrorPrompt,
    required bool Function() isActive,
    required void Function({required bool isShorebirdSyncing})
    onShorebirdSyncVisibilityChanged,
    required Future<void> Function() onShorebirdRestartRequired,
    Future<void> Function(StoreUpdateInfo info)? onStoreUpdateAvailable,
  }) async {
    await _unlockFlowCoordinator.executeFlow(
      onModeChanged: (AppMode mode) {
        if (mode == AppMode.betting) {
          unawaited(
            _executeShorebirdGateThenContinue(
              onAppModeSet: onAppModeSet,
              isActive: isActive,
              onShorebirdSyncVisibilityChanged:
                  onShorebirdSyncVisibilityChanged,
              onShorebirdRestartRequired: onShorebirdRestartRequired,
              onStoreUpdateAvailable: onStoreUpdateAvailable,
            ),
          );
        } else {
          onAppModeSet(mode);
        }
      },
      onConnectionErrorPrompt: onConnectionErrorPrompt,
    );
  }

  /// Safety-net timeout: chỉ dùng khi Shorebird treo hoàn toàn (không throw,
  /// không respond). Đủ lớn để cover cả check lẫn download trên mạng chậm.
  static const Duration _shorebirdTotalTimeout = Duration(minutes: 3);

  Future<void> _executeShorebirdGateThenContinue({
    required void Function(AppMode mode) onAppModeSet,
    required bool Function() isActive,
    required void Function({required bool isShorebirdSyncing})
    onShorebirdSyncVisibilityChanged,
    required Future<void> Function() onShorebirdRestartRequired,
    Future<void> Function(StoreUpdateInfo info)? onStoreUpdateAvailable,
  }) async {
    if (_isShorebirdGateRunning || !isActive()) {
      return;
    }
    _isShorebirdGateRunning = true;
    bool syncUiActive = false;
    try {
      syncUiActive = true;
      onShorebirdSyncVisibilityChanged(isShorebirdSyncing: true);
      onAppModeSet(AppMode.splash);

      // Store version gate (chỉ chạy trên nhánh betting = user đã unlock):
      // nếu bản cài cũ hơn bản trên store → popup "Cập nhật / Để sau".
      // Chạy TRƯỚC Shorebird để không tải patch cho binary sắp bị thay.
      // Lỗi / không có bản mới → bỏ qua, đi tiếp như cũ.
      if (onStoreUpdateAvailable != null) {
        final StoreUpdateInfo? storeUpdate =
            await _storeVersionGate.executeCheckStoreUpdate();
        if (!isActive()) {
          return;
        }
        if (storeUpdate != null) {
          print(
            '[Unlock Shorebird] store has newer version: '
            '${storeUpdate.currentVersion} → ${storeUpdate.newVersion}',
          );
          await onStoreUpdateAvailable(storeUpdate);
          if (!isActive()) {
            return;
          }
        }
      }

      _shorebirdUpdateBloc.add(const UpdateCheckRequested());

      // Chờ đến khi Shorebird trả kết quả cuối cùng: upToDate, restartRequired,
      // hoặc error (bao gồm cả check lẫn download nếu có patch mới).
      // Timeout chỉ là safety-net khi mạng treo hoàn toàn.
      final UpdateState terminalState = await _shorebirdUpdateBloc.stream
          .firstWhere(
            (UpdateState state) =>
                state.status == UpdateFlowStatus.upToDate ||
                state.status == UpdateFlowStatus.restartRequired ||
                state.status == UpdateFlowStatus.error,
          )
          .timeout(
            _shorebirdTotalTimeout,
            onTimeout: () => const UpdateState(status: UpdateFlowStatus.upToDate),
          );

      if (!isActive()) {
        return;
      }
      onShorebirdSyncVisibilityChanged(isShorebirdSyncing: false);
      syncUiActive = false;
      if (terminalState.status == UpdateFlowStatus.restartRequired) {
        await onShorebirdRestartRequired();
        // Safety-net: sau khi onShorebirdRestartRequired() trả về, luôn
        // navigate sang betting để tránh kẹt splash mãi (trừ khi restart
        // thật sự kill process — lúc đó isActive() = false).
        // Handler có thể đã tự set betting (non-force path), nhưng set lại
        // là no-op an toàn; snackbar (force path) sẽ hiển thị trên betting
        // screen qua ScaffoldMessenger.
        if (!isActive()) {
          return;
        }
        onAppModeSet(AppMode.betting);
        return;
      }
      onAppModeSet(AppMode.betting);
    } finally {
      _isShorebirdGateRunning = false;
      if (syncUiActive && isActive()) {
        onShorebirdSyncVisibilityChanged(isShorebirdSyncing: false);
      }
    }
  }
}
