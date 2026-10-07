import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/widgets.dart';

class WebIframeView extends StatefulWidget {
  const WebIframeView({
    super.key,
    required this.src,
    this.allow = 'autoplay; encrypted-media; fullscreen',
    this.background = 'black',
    this.borderRadiusCss = '',
    this.startPointerEventsNone = false,
    this.onElementCreated,
  });

  final String src;

  final String allow;

  final String background;

  final String borderRadiusCss;

  final bool startPointerEventsNone;

  final void Function(html.IFrameElement element)? onElementCreated;

  @override
  State<WebIframeView> createState() => _WebIframeViewState();
}

class _WebIframeViewState extends State<WebIframeView> {
  static const String _viewType = 's88-web-iframe';
  static bool _factoryRegistered = false;

  static final Map<int, html.IFrameElement> _elements =
      <int, html.IFrameElement>{};

  html.IFrameElement? _element;
  int? _viewId;

  static void _ensureFactory() {
    if (_factoryRegistered) return;
    _factoryRegistered = true;
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (
      int viewId, {
      Object? params,
    }) {
      final p = (params! as Map).cast<String, Object?>();
      final iframe = html.IFrameElement()
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.backgroundColor = p['background']! as String;
      final radiusCss = p['borderRadius']! as String;
      if (radiusCss.isNotEmpty) {
        iframe.style
          ..borderRadius = radiusCss
          ..overflow = 'hidden';
      }
      if (p['pointerEventsNone']! as bool) {
        iframe.style.pointerEvents = 'none';
      }
      iframe
        ..allowFullscreen = true
        ..allow = p['allow']! as String
        ..src = p['src']! as String;
      _elements[viewId] = iframe;
      return iframe;
    });
  }

  void _onPlatformViewCreated(int viewId) {
    _viewId = viewId;
    final element = _elements[viewId];
    if (element == null) return;
    _element = element;
    widget.onElementCreated?.call(element);
  }

  @override
  void didUpdateWidget(WebIframeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.src != widget.src) {
      _element?.src = widget.src;
    }
  }

  @override
  void dispose() {
    final id = _viewId;
    if (id != null) _elements.remove(id);
    _element = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _ensureFactory();
    return HtmlElementView(
      viewType: _viewType,
      creationParams: <String, Object?>{
        'src': widget.src,
        'allow': widget.allow,
        'background': widget.background,
        'borderRadius': widget.borderRadiusCss,
        'pointerEventsNone': widget.startPointerEventsNone,
      },
      onPlatformViewCreated: _onPlatformViewCreated,
    );
  }
}
