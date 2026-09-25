import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sun_sports/shared/widgets/toast/app_toast.dart';

class ClipboardUtils {
  static Future<void> copyToClipboard(BuildContext context, String text) async {
    if (text.isEmpty) return;
    if (!context.mounted) return;

    try {
      await Clipboard.setData(ClipboardData(text: text));

      if (!context.mounted) return;

      AppToast.showSuccess(context, message: 'Đã sao chép vào clipboard');
    } catch (e) {
    }
  }

  @Deprecated(
    'SnackBar bị che bởi dialog/bottom sheet. Dùng copyToClipboard '
    '(toast-based, hiển thị trên mọi overlay) thay thế.',
  )
  static Future<void> copyToClipboardWithSnackBar(
    BuildContext context,
    String text,
  ) async {
    if (text.isEmpty) return;
    if (!context.mounted) return;

    try {
      await Clipboard.setData(ClipboardData(text: text));

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã sao chép vào clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
    }
  }

  static Future<String?> getClipboardText() async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      return clipboardData?.text;
    } catch (e) {
      return null;
    }
  }

  static Future<void> pasteToController({
    required TextEditingController controller,
    void Function(String text)? onPaste,
  }) async {
    try {
      final clipboardText = await getClipboardText();
      if (clipboardText != null && clipboardText.isNotEmpty) {
        controller.text = clipboardText;
        onPaste?.call(clipboardText);
      }
    } catch (e) {
    }
  }
}
