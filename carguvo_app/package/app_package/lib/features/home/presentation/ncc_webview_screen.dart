import 'package:flutter/material.dart';
import 'package:app_package/core/utils/styles/app_color_styles.dart';
import 'package:app_package/shared/widgets/buttons/sound_tap.dart';
import 'package:webview_flutter/webview_flutter.dart';

class NccWebViewScreen extends StatefulWidget {
  const NccWebViewScreen({required this.url, required this.title, super.key});

  final String url;
  final String title;

  static Route<void> route({required String url, required String title}) =>
      MaterialPageRoute<void>(
        builder: (_) => NccWebViewScreen(url: url, title: title),
      );

  @override
  State<NccWebViewScreen> createState() => _NccWebViewScreenState();
}

class _NccWebViewScreenState extends State<NccWebViewScreen> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _loading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
          onWebResourceError: (_) {
            if (mounted) setState(() => _loading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _controller.canGoBack()) {
          await _controller.goBack();
        } else if (context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColorStyles.backgroundPrimary,
        appBar: AppBar(
          title: Text(widget.title),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: SoundTap.wrap(() => Navigator.of(context).pop()),
          ),
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_loading) const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}
