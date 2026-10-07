import 'package:url_launcher/url_launcher.dart';

Future<bool> openExternalAfter({
  required String url,
  required Future<bool> Function() task,
  bool sameTab = false,
}) async {
  final ok = await task();
  if (!ok) return false;
  final uri = Uri.tryParse(url);
  if (uri == null) return false;
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
  return true;
}
