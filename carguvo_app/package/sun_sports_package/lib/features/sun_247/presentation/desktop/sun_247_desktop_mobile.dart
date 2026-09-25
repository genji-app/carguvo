import 'package:flutter/material.dart';
import 'package:sun_sports/core/services/config/sb_config.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Sun247DesktopImpl extends StatefulWidget {
  const Sun247DesktopImpl({super.key});

  @override
  State<Sun247DesktopImpl> createState() => _Sun247DesktopImplState();
}

class _Sun247DesktopImplState extends State<Sun247DesktopImpl> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(SbConfig.livechatUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: WebViewWidget(controller: _controller),
    );
  }
}
