import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:sun_sports/features/download_app/footer_download_fade.dart';
import 'package:sun_sports/shared/layouts/shell_desktop_sidebar.dart'
    show DownloadAppButton;
import 'package:sun_sports/shared/responsive/responsive_builder.dart';

class FooterDownloadAppButton extends StatefulWidget {
  const FooterDownloadAppButton({super.key});

  @override
  State<FooterDownloadAppButton> createState() =>
      _FooterDownloadAppButtonState();
}

class _FooterDownloadAppButtonState extends State<FooterDownloadAppButton> {
  ScrollPosition? _position;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final next = Scrollable.maybeOf(context)?.position;
    if (identical(next, _position)) return;
    _position?.removeListener(_reportDistance);
    _position = next;
    _position?.addListener(_reportDistance);
    WidgetsBinding.instance.addPostFrameCallback((_) => _reportDistance());
  }

  @override
  void dispose() {
    _position?.removeListener(_reportDistance);
    FooterDownloadFade.instance.reset();
    super.dispose();
  }

  void _reportDistance() {
    if (!mounted) return;
    if (!kIsWeb || !ResponsiveBuilder.isMobile(context)) {
      FooterDownloadFade.instance.reset();
      return;
    }
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize || !box.attached) return;
    final media = MediaQuery.maybeOf(context);
    if (media == null) return;
    final floatingTop =
        media.size.height - FooterDownloadFade.floatingButtonInsetBottom;
    double top;
    try {
      top = box.localToGlobal(Offset.zero).dy;
    } catch (_) {
      FooterDownloadFade.instance.reset();
      return;
    }
    if (!top.isFinite ||
        top < -media.size.height ||
        top > media.size.height * 2) {
      FooterDownloadFade.instance.reset();
      return;
    }
    FooterDownloadFade.instance.report(top - floatingTop);
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _reportDistance());
    return const DownloadAppButton(horizontalPadding: 0);
  }
}
