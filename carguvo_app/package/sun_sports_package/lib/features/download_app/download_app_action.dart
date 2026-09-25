import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/features/download_app/data/services/external_launcher.dart';
import 'package:sun_sports/features/download_app/dialog_download_app.dart';
import 'package:sun_sports/features/download_app/presentation/providers/store_client_ip_provider.dart';
import 'package:sun_sports/shared/responsive/responsive_builder.dart';
import 'package:sun_sports/shared/widgets/toast/app_toast.dart';

Future<void> runDownloadAppAction({
  required BuildContext context,
  required WidgetRef ref,
  VoidCallback? onClose,
  ValueChanged<bool>? onLoading,
}) async {
  if (kIsWeb && ResponsiveBuilder.isMobile(context)) {
    onLoading?.call(true);
    onClose?.call();
    var ok = false;
    try {
      ok = await openExternalAfter(
        url: kDownloadLandingUrl,
        sameTab: false,
        task: () =>
            ref.read(storeClientIpServiceProvider).storeClientIpUntilFirstOk(),
      );
    } finally {
      onLoading?.call(false);
    }
    if (!ok && context.mounted) {
      AppToast.showError(
        context,
        message: 'Kết nối không ổn định, vui lòng thử lại',
      );
    }
    return;
  }

  onLoading?.call(true);
  var ok = false;
  try {
    ok = await ref
        .read(storeClientIpServiceProvider)
        .storeClientIpUntilFirstOk(timeout: const Duration(milliseconds: 1500));
  } finally {
    onLoading?.call(false);
  }
  if (!context.mounted) return;
  if (!ok) {
    AppToast.showError(
      context,
      message: 'Kết nối không ổn định, vui lòng thử lại',
    );
    return;
  }
  onClose?.call();
  if (context.mounted) await DialogDownloadApp.show(context);
}
