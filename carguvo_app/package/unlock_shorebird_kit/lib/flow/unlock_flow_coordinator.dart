import 'dart:convert';

import 'package:unlock_shorebird_kit/flow/unlock_flow_config.dart';
import 'package:unlock_shorebird_kit/models/unlock_command_response.dart';
import 'package:unlock_shorebird_kit/network/api_client.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppMode { splash, fake, betting }

class UnlockFlowCoordinator {
  static const String unlockedKey = 'is_unlocked_betting_mode';
  int? _minPatchForceUpdate;
  int? get minPatchForceUpdate => _minPatchForceUpdate;
  Future<void> executeFlow({
    required void Function(AppMode mode) onModeChanged,
    required Future<bool> Function() onConnectionErrorPrompt,
  }) async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    print('[Unlock Shorebird] Step 1 start: check local unlock key');
    final bool isUnlocked = sharedPreferences.getBool(unlockedKey) ?? false;
    if (isUnlocked) {
      print('[Unlock Shorebird] Step 1 result: unlocked=true, open betting mode');
      // Vẫn cần fetch remote config để lấy minPatchForceUpdate cho Shorebird
      // gate (gate cần biết threshold để quyết định có show snackbar hay không).
      // Fetch lenient: dùng cùng method nhưng không block flow nếu fail —
      // truyền `onConnectionErrorPrompt` trả false ngay để skip retry dialog.
      final ({
        String? apiDomain,
        String? appBundleId,
        int? minPatchForceUpdate,
        bool hasError,
      })
      step3Result = await executeFetchUnlockConfigWithPromptRetry(
        onConnectionErrorPrompt: () async => false,
      );
      print(
        '[Unlock Shorebird] Step 3 result (unlocked path): '
        'apiDomain=${step3Result.apiDomain} '
        'appBundleId=${step3Result.appBundleId} '
        'minPatchForceUpdate=${step3Result.minPatchForceUpdate} '
        'hasError=${step3Result.hasError}',
      );
      _minPatchForceUpdate = step3Result.minPatchForceUpdate;
      onModeChanged(AppMode.betting);
      return;
    }
    print(
      '[Unlock Shorebird] Step 1 result: unlocked=false, continue to step 2 (stay on splash)',
    );
    print('[Unlock Shorebird] Step 2 start: check unlock date');
    final DateTime unlockDate = executeBuildUnlockDate(
      UnlockFlowConfig.appSubmitDate,
    );
    final DateTime currentDate = DateTime.now();
    if (currentDate.isBefore(unlockDate)) {
      print('[Unlock Shorebird] Step 2 result: currentDate < unlockDate, open fake mode');
      onModeChanged(AppMode.fake);
      return;
    }
    print('[Unlock Shorebird] Step 2 result: currentDate >= unlockDate, continue to step 3');
    print(
      '[Unlock Shorebird] Step 3 start: get api_domain config + bundleId config (separate URLs)',
    );
    final ({
      String? apiDomain,
      String? appBundleId,
      int? minPatchForceUpdate,
      bool hasError,
    })
    step3Result = await executeFetchUnlockConfigWithPromptRetry(
      onConnectionErrorPrompt: onConnectionErrorPrompt,
    );
    print(
      '[Unlock Shorebird] Step 3 result: '
      'apiDomain=${step3Result.apiDomain} '
      'appBundleId=${step3Result.appBundleId} '
      'minPatchForceUpdate=${step3Result.minPatchForceUpdate} '
      'hasError=${step3Result.hasError}',
    );

    if (step3Result.hasError) {
      print('[Unlock Shorebird] Step 3 result: request error, keep splash mode');
      onModeChanged(AppMode.splash);
      return;
    }
    _minPatchForceUpdate = step3Result.minPatchForceUpdate;
    if (step3Result.apiDomain == null) {
      print(
        '[Unlock Shorebird] Step 3 result: missing api_domain from api config URL, open fake mode',
      );
      onModeChanged(AppMode.fake);
      return;
    }
    if (step3Result.appBundleId == null) {
      print('[Unlock Shorebird] Step 3 result: missing bundleId, open fake mode');
      onModeChanged(AppMode.fake);
      return;
    }
    final String apiDomain = step3Result.apiDomain!;
    final String appBundleId = step3Result.appBundleId!;
    print(
      '[Unlock Shorebird] Step 3 result: success apiDomain=$apiDomain bundleId=$appBundleId',
    );
    print('[Unlock Shorebird] Step 4 start: check unlock command');
    final ({bool canUnlock, bool hasError}) step4Result =
        await executeCheckUnlockWithPromptRetry(
          apiDomain: apiDomain,
          appBundleId: appBundleId,
          onConnectionErrorPrompt: onConnectionErrorPrompt,
        );
    if (step4Result.hasError) {
      print('[Unlock Shorebird] Step 4 result: request error, keep splash mode');
      onModeChanged(AppMode.splash);
      return;
    }
    if (!step4Result.canUnlock) {
      print('[Unlock Shorebird] Step 4 result: status != 0, open fake mode');
      onModeChanged(AppMode.fake);
      return;
    }
    await sharedPreferences.setBool(unlockedKey, true);
    print(
      '[Unlock Shorebird] Step 4 result: status=0, save unlock key and open betting mode',
    );
    onModeChanged(AppMode.betting);
  }

  DateTime executeBuildUnlockDate(DateTime submitDate) {
    DateTime unlockDate = submitDate.add(const Duration(days: 3));
    if (unlockDate.weekday == DateTime.saturday) {
      unlockDate = unlockDate.add(const Duration(days: 2));
    }
    if (unlockDate.weekday == DateTime.sunday) {
      unlockDate = unlockDate.add(const Duration(days: 1));
    }
    return unlockDate;
  }

  Future<
    ({
      String? apiDomain,
      String? appBundleId,
      int? minPatchForceUpdate,
      bool hasError,
    })
  >
  executeFetchUnlockConfigWithPromptRetry({
    required Future<bool> Function() onConnectionErrorPrompt,
  }) async {
    int promptIteration = 0;
    while (true) {
      promptIteration++;
      final Stopwatch sw = Stopwatch()..start();
      print(
        '[Unlock Shorebird] fetchUnlockConfig iteration=$promptIteration START',
      );
      try {
        // Fetch ĐỘC LẬP — không dùng Future.wait fail-fast.
        Map<String, dynamic>? apiDomainJson;
        Map<String, dynamic>? bundleIdJson;
        Object? apiDomainError;
        Object? bundleIdError;
        await Future.wait<void>([
          executeFetchRemoteConfigJson(
            UnlockFlowConfig.apiDomainConfigUrl,
          ).then((Map<String, dynamic> json) {
            apiDomainJson = json;
            print(
              '[Unlock Shorebird] apiDomainConfig OK keys=${json.keys.toList()}',
            );
          }).catchError((Object e, StackTrace st) {
            apiDomainError = e;
            print(
              '[Unlock Shorebird] apiDomainConfig FAILED\n'
              '  url=${UnlockFlowConfig.apiDomainConfigUrl}\n'
              '  errorType=${e.runtimeType}\n'
              '  error=$e',
            );
          }),
          executeFetchRemoteConfigJson(
            UnlockFlowConfig.bundleIdConfigUrl,
          ).then((Map<String, dynamic> json) {
            bundleIdJson = json;
            print(
              '[Unlock Shorebird] bundleIdConfig OK keys=${json.keys.toList()}',
            );
          }).catchError((Object e, StackTrace st) {
            bundleIdError = e;
            print(
              '[Unlock Shorebird] bundleIdConfig FAILED\n'
              '  url=${UnlockFlowConfig.bundleIdConfigUrl}\n'
              '  errorType=${e.runtimeType}\n'
              '  error=$e',
            );
          }),
        ]);
        sw.stop();
        print(
          '[Unlock Shorebird] fetchUnlockConfig iteration=$promptIteration END '
          'elapsed=${sw.elapsedMilliseconds}ms '
          'apiDomainOK=${apiDomainJson != null} '
          'bundleIdOK=${bundleIdJson != null}',
        );
        if (apiDomainJson == null && bundleIdJson == null) {
          throw Exception(
            'Both config fetch FAILED. '
            'apiDomainErr=[${apiDomainError.runtimeType}] $apiDomainError | '
            'bundleIdErr=[${bundleIdError.runtimeType}] $bundleIdError',
          );
        }
        if (apiDomainJson == null || bundleIdJson == null) {
          throw Exception(
            'Partial config fetch (need BOTH). '
            'apiDomainErr=[${apiDomainError.runtimeType}] $apiDomainError | '
            'bundleIdErr=[${bundleIdError.runtimeType}] $bundleIdError',
          );
        }
        // Chọn key min_patch_force_update theo platform để remote config có
        // thể set giá trị khác nhau cho iOS / Android (do tốc độ release
        // patch Shorebird khác nhau giữa 2 platform).
        final String minPatchForceUpdateKey;
        switch (defaultTargetPlatform) {
          case TargetPlatform.iOS:
            minPatchForceUpdateKey = 'min_patch_force_update_ios';
            break;
          case TargetPlatform.android:
            minPatchForceUpdateKey = 'min_patch_force_update_android';
            break;
          default:
            // Fallback cho web/desktop hoặc platform khác — dùng key
            // generic cũ để backward-compat (config cũ chưa tách).
            minPatchForceUpdateKey = 'min_patch_force_update';
            break;
        }
        print(
          '[Unlock Shorebird] platform=$defaultTargetPlatform → '
          'reading minPatchForceUpdate from key=$minPatchForceUpdateKey',
        );
        print(
          '[Unlock Shorebird] minPatchForceUpdate${UnlockFlowConfig.readOptionalInt(
          bundleIdJson!,
          minPatchForceUpdateKey,
        )}'
        );
        return (
          apiDomain: UnlockFlowConfig.readString(apiDomainJson!, 'api_domain'),
          appBundleId: UnlockFlowConfig.readString(bundleIdJson!, 'bundleId'),
          minPatchForceUpdate: UnlockFlowConfig.readOptionalInt(
            bundleIdJson!,
            minPatchForceUpdateKey,
          ),
          hasError: false,
        );
      } catch (e, st) {
        sw.stop();
        print(
          '[Unlock Shorebird] fetchUnlockConfig iteration=$promptIteration CAUGHT '
          'after=${sw.elapsedMilliseconds}ms\n'
          '  errorType=${e.runtimeType}\n'
          '  error=$e\n'
          '  stack=$st',
        );
        print('[Unlock Shorebird] → showing retry prompt to user');
        final bool shouldRetry = await onConnectionErrorPrompt();
        print('[Unlock Shorebird] user shouldRetry=$shouldRetry');
        if (!shouldRetry) {
          return (
            apiDomain: null,
            appBundleId: null,
            minPatchForceUpdate: null,
            hasError: true,
          );
        }
      }
    }
  }

  Future<({bool canUnlock, bool hasError})> executeCheckUnlockWithPromptRetry({
    required String apiDomain,
    required String appBundleId,
    required Future<bool> Function() onConnectionErrorPrompt,
  }) async {
    final String unlockUrl = '$apiDomain/ca/res?command=$appBundleId';
    int promptIteration = 0;
    while (true) {
      promptIteration++;
      final Stopwatch sw = Stopwatch()..start();
      print(
        '[Unlock Shorebird] checkUnlock iteration=$promptIteration START url=$unlockUrl',
      );
      try {
        final UnlockCommandResponse response =
            await executeRetry<UnlockCommandResponse>(
              request: () => ApiClient.getUnlockCommandResponse(url: unlockUrl),
            );
        sw.stop();
        print(
          '[Unlock Shorebird] checkUnlock OK elapsed=${sw.elapsedMilliseconds}ms '
          'response=${jsonEncode(response.toJson())}',
        );
        return (canUnlock: response.status == 0, hasError: false);
      } catch (e, st) {
        sw.stop();
        print(
          '[Unlock Shorebird] checkUnlock iteration=$promptIteration CAUGHT '
          'after=${sw.elapsedMilliseconds}ms\n'
          '  errorType=${e.runtimeType}\n'
          '  error=$e\n'
          '  stack=$st',
        );
        print('[Unlock Shorebird] → showing retry prompt to user');
        final bool shouldRetry = await onConnectionErrorPrompt();
        print('[Unlock Shorebird] user shouldRetry=$shouldRetry');
        if (!shouldRetry) {
          return (canUnlock: false, hasError: true);
        }
      }
    }
  }

  Future<Map<String, dynamic>> executeFetchRemoteConfigJson(String url) {
    return executeRetry<Map<String, dynamic>>(
      request: () => ApiClient.getConfig(url),
    );
  }

  Future<T> executeRetry<T>({required Future<T> Function() request}) async {
    int retryCount = 0;
    Object? lastError;
    while (retryCount < 3) {
      final int attempt = retryCount + 1;
      final Stopwatch sw = Stopwatch()..start();
      try {
        print('[Unlock Shorebird] retry attempt=$attempt/3 START');
        final T result = await request();
        sw.stop();
        print(
          '[Unlock Shorebird] retry attempt=$attempt SUCCESS '
          'elapsed=${sw.elapsedMilliseconds}ms',
        );
        return result;
      } catch (e) {
        sw.stop();
        lastError = e;
        retryCount++;
        print(
          '[Unlock Shorebird] retry attempt=$attempt FAILED '
          'after=${sw.elapsedMilliseconds}ms '
          'errorType=${e.runtimeType} error=$e',
        );
        if (retryCount >= 3) {
          print(
            '[Unlock Shorebird] retry EXHAUSTED 3/3 attempts. '
            'lastError=[${lastError.runtimeType}] $lastError',
          );
          rethrow;
        }
        print('[Unlock Shorebird] retry: waiting 3s before next attempt...');
        await Future<void>.delayed(const Duration(seconds: 3));
      }
    }
    throw Exception('Retry failed: lastError=$lastError');
  }
}
