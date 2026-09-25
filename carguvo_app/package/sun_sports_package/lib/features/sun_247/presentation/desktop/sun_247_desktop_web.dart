import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:sun_sports/core/services/config/sb_config.dart';
import 'package:sun_sports/shared/responsive/responsive_builder.dart';

class Sun247DesktopImpl extends StatefulWidget {
  const Sun247DesktopImpl({super.key});

  @override
  State<Sun247DesktopImpl> createState() => _Sun247DesktopImplState();
}

class _Sun247DesktopImplState extends State<Sun247DesktopImpl> {
  static const double _bottomNavHeight = 80.0;

  late final String _viewType;

  @override
  void initState() {
    super.initState();
    _viewType =
        'sun247-iframe-${DateTime.now().millisecondsSinceEpoch}';
    _registerIFrame();
  }

  void _registerIFrame() {
    final url = SbConfig.livechatUrl;

    // ignore: undefined_prefixed_name
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      final container = html.DivElement()
        ..style.position = 'relative'
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.overflow = 'hidden'
        ..style.backgroundColor = 'black';

      final iframe = html.IFrameElement()
        ..src = url
        ..style.border = 'none'
        ..style.position = 'absolute'
        ..style.top = '0'
        ..style.left = '0'
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.backgroundColor = 'black'
        ..allowFullscreen = true
        ..allow = 'autoplay; encrypted-media';

      container.append(iframe);
      return container;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBuilder.isDesktop(context);
    final mq = MediaQuery.of(context);

    final bottomPadding = isDesktop
        ? 0.0
        : _bottomNavHeight + mq.padding.bottom;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: ClipRect(
          child: SizedBox.expand(
            child: HtmlElementView(viewType: _viewType),
          ),
        ),
      ),
    );
  }
}
