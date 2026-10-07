import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter/services.dart' show MissingPluginException, PlatformException;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_package/core/error/app_error_messages.dart';
import 'package:app_package/features/game/new_tab_opener/new_tab_opener.dart';
import 'package:app_package/features/home/domain/ncc_sportbook.dart';
import 'package:app_package/features/home/domain/ncc_tab_opener.dart';
import 'package:app_package/features/home/presentation/ncc_webview_screen.dart';
import 'package:app_package/providers/main_content_provider.dart';
import 'package:app_package/shared/utils/auth_gate.dart';
import 'package:app_package/shared/widgets/toast/app_toast.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> handleNccTap(
  WidgetRef ref,
  BuildContext context,
  NccProvider type,
) async {
  if (type.isPartnershipPaused) return;

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
        if (!context.mounted) return;
        await _launchNative(context, type, url);
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

Future<void> _launchNative(
  BuildContext context,
  NccProvider type,
  String url,
) async {
  final uri = Uri.tryParse(url);
  if (uri == null || !uri.hasScheme) {
    AppToast.showError(
      context,
      message: localizedOrGenericError('Mở nhà cung cấp', null),
    );
    return;
  }

  var opened = false;
  try {
    opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
  } on PlatformException catch (e) {
    debugPrint('[NCC] launchUrl failed (${e.code}): ${e.message} → in-app');
  } on MissingPluginException catch (e) {
    debugPrint('[NCC] url_launcher missing: ${e.message} → in-app');
  }
  if (opened || !context.mounted) return;

  await Navigator.of(context, rootNavigator: true).push(
    NccWebViewScreen.route(url: url, title: _titleOf(type)),
  );
}

String _titleOf(NccProvider type) => switch (type) {
  NccProvider.saba => 'SABA SPORT',
  NccProvider.bti => 'BTI SPORT',
  NccProvider.imSport => 'IM SPORT',
  NccProvider.ksport => 'K-SPORT',
};
