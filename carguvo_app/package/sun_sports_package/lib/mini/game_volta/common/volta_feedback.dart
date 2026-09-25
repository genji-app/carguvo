import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sun_sports/core/utils/sound_effects.dart';
import 'package:sun_sports/core/utils/styles/app_audios.dart';
import 'package:sun_sports/shared/utils/auth_gate.dart';
import 'package:sun_sports/shared/widgets/loading/s88_loading.dart';
import 'package:sun_sports/shared/widgets/toast/app_toast.dart';

import 'domain/volta_bet_rules.dart';

class VoltaFeedback {
  const VoltaFeedback._();

  static void error(BuildContext context, String message) {
    SoundEffects.instance.playMiniGame(MiniGameSound.voltaBetError);
    if (!context.mounted) return;
    AppToast.show(
      context,
      type: AppToastType.error,
      message: '$message!',
      playSound: false,
    );
  }

  static void info(BuildContext context, String message, {Duration? duration}) {
    if (!context.mounted) return;
    AppToast.show(
      context,
      type: AppToastType.generic,
      message: message,
      playSound: false,
      duration: duration,
    );
  }

  static void success(BuildContext context, String message) {
    SoundEffects.instance.playMiniGame(MiniGameSound.voltaBetOk);
    if (!context.mounted) return;
    AppToast.showSuccess(context, message: message, playSound: false);
  }

  static void copied(BuildContext context, String message) {
    click();
    if (!context.mounted) return;
    AppToast.show(
      context,
      type: AppToastType.generic,
      message: message,
      playSound: false,
    );
  }

  static void click() =>
      SoundEffects.instance.playMiniGame(MiniGameSound.voltaClick);

  static void oddsChanged() =>
      SoundEffects.instance.playMiniGame(MiniGameSound.voltaOdds);

  static bool requireSignedIn(BuildContext context, WidgetRef ref) =>
      requireLogin(context, ref);
}

class VoltaBetFeedback {
  const VoltaBetFeedback._();

  static void show(BuildContext context, VoltaBetOutcome outcome) {
    switch (outcome.kind) {
      case VoltaBetOutcomeKind.ok:
        VoltaFeedback.success(context, outcome.message);

      case VoltaBetOutcomeKind.rejected:
        VoltaFeedback.error(
          context,
          outcome.placed > 0
              ? 'Đã đặt được ${outcome.placed} cửa, cửa còn lại '
                    '${outcome.message.toLowerCase()}'
              : outcome.message,
        );

      case VoltaBetOutcomeKind.uncertain:
        VoltaFeedback.info(context, outcome.message);

      case VoltaBetOutcomeKind.notice:
        VoltaFeedback.info(context, outcome.message);

      case VoltaBetOutcomeKind.busy:
        break;
    }
  }
}

class VoltaBetLoading {
  const VoltaBetLoading._();

  static const Duration _graceDelay = Duration(milliseconds: 250);

  static Future<T> run<T>(
    BuildContext context,
    Future<T> Function() task,
  ) async {
    S88LoadingHandle? handle;
    final Timer timer = Timer(_graceDelay, () {
      if (!context.mounted) return;
      handle = S88Loading.show(context, indicatorSize: 96);
    });
    try {
      return await task();
    } finally {
      timer.cancel();
      handle?.remove();
    }
  }
}
