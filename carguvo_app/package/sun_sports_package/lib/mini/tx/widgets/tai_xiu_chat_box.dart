import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sun_sports/providers/auth_provider.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/mini_game/presentation/state/tai_xiu_state_provider.dart';
import 'package:sun_sports/mini/tx/widgets/tai_xiu_square_button.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';
import 'package:sun_sports/shared/widgets/cards/inner_shadow_card.dart';

const Color _selfNameColor = Color(0xFFF9BF5A);
const Color _systemColor = Color(0xFFFF5252);
const Color _otherNameColor = Color(0xFFF38744);
const Color _messageColor = Color(0xFFFFFEF5);

class TaiXiuChatBox extends ConsumerStatefulWidget {
  final VoidCallback? onClose;

  const TaiXiuChatBox({this.onClose, super.key});

  @override
  ConsumerState<TaiXiuChatBox> createState() => _TaiXiuChatBoxState();
}

class _TaiXiuChatBoxState extends ConsumerState<TaiXiuChatBox> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    ref.read(taiXiuSocketStateProvider.notifier).sendChat(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(taiXiuSocketStateProvider).chatLines;
    final currentUserName = ref.watch(currentUserProvider)?.displayName;
    return InnerShadowCard(
      child: Container(
        decoration: const BoxDecoration(
          color: AppColorStyles.backgroundTertiary,
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Chat box tài xỉu',
                    style: AppTextStyles.displayStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFFFFCDA),
                    ),
                  ),
                ),
                if (widget.onClose case final onClose?)
                  TaiXiuSquareButton(
                    icon: Icons.close_rounded,
                    size: 24,
                    iconSize: 14,
                    onTap: onClose,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  scrollbars: false,
                  dragDevices: PointerDeviceKind.values.toSet(),
                ),
                child: MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  removeBottom: true,
                  child: ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[messages.length - 1 - index];
                      final isSelf =
                          currentUserName != null &&
                          currentUserName.isNotEmpty &&
                          message.name == currentUserName;
                      return _MessageItem(
                        line: message,
                        nameColor: isSelf ? _selfNameColor : _otherNameColor,
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            _InputBar(
              controller: _controller,
              focusNode: _focusNode,
              onSend: _handleSend,
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageItem extends StatelessWidget {
  final TaiXiuChatLine line;
  final Color nameColor;

  const _MessageItem({required this.line, required this.nameColor});

  @override
  Widget build(BuildContext context) {
    if (line.name.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          line.message,
          style: AppTextStyles.textStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: _systemColor,
            height: 1.3,
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '${line.name}: ',
              style: AppTextStyles.textStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: nameColor,
                height: 1.3,
              ),
            ),
            TextSpan(
              text: line.message,
              style: AppTextStyles.textStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: _messageColor,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSend;

  const _InputBar({
    required this.controller,
    required this.focusNode,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) => Container(
    height: 40,
    padding: const EdgeInsets.symmetric(horizontal: 14),
    decoration: BoxDecoration(
      color: AppColorStyles.backgroundQuaternary,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            maxLength: 50,
            buildCounter:
                (
                  context, {
                  required currentLength,
                  required isFocused,
                  maxLength,
                }) => null,
            cursorColor: const Color(0xFFE3A637),
            style: AppTextStyles.textStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColorStyles.contentPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Nhập tin nhắn',
              hintStyle: AppTextStyles.textStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColorStyles.contentTertiary,
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => onSend(),
          ),
        ),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: SoundTap.wrap(onSend),
            child: const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(
                Icons.send_rounded,
                size: 20,
                color: Color(0xFFE3A637),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
