import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/error/app_error_messages.dart';
import 'package:sun_sports/features/game/new_tab_opener/new_tab_opener.dart';
import 'package:sun_sports/features/home/domain/ncc_sportbook.dart';
import 'package:sun_sports/features/home/domain/ncc_tab_opener.dart';
import 'package:sun_sports/providers/main_content_provider.dart';
import 'package:sun_sports/shared/utils/auth_gate.dart';
import 'package:sun_sports/shared/widgets/toast/app_toast.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> handleNccTap(
  WidgetRef ref,
  BuildContext context,
  NccProvider type,
) async {
  if (!type.isSportbookLaunch) {
    ref.read(mainContentProvider.notifier).goToSport();
    return;
  }

  if (!requireLogin(context, ref)) return;

  if (ref.read(nccLaunchProvider) != null) return;

  final pendingTab = kIsWeb ? openPendingTab() : null;

  final result = await ref.read(nccLaunchProvider.notifier).launch(type);

  switch (result) {
    case NccLaunchSuccess(:final url):
      if (kIsWeb) {
        if (pendingTab != null) {
          pendingTab.navigate(url);
        } else {
          openNewTab(url);
        }
      } else {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
    case NccLaunchFailure(:final message):
      pendingTab?.close();
      if (context.mounted) {
        AppToast.showError(
          context,
          message: localizedOrGenericError('Mở nhà cung cấp', message),
        );
      }
    case NccLaunchCancelled():
      pendingTab?.close();
  }
}
