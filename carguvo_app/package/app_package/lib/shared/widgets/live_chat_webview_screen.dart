import 'package:flutter/material.dart';
import 'package:app_package/core/services/config/sb_config.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:app_package/shared/widgets/buttons/sound_tap.dart';

class LiveChatWebViewScreen extends StatefulWidget {
  const LiveChatWebViewScreen({super.key});

  @override
  State<LiveChatWebViewScreen> createState() => _LiveChatWebViewScreenState();
}

class _LiveChatWebViewScreenState extends State<LiveChatWebViewScreen> {
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
      appBar: AppBar(
        title: const Text('LiveChat'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: SoundTap.wrap(() => Navigator.of(context).pop()),
        ),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
