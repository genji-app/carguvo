import 'dart:math';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/providers/auth_provider.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/widgets/cards/inner_shadow_card.dart';
import 'package:sun_sports/core/services/websocket/sb_chat_websocket.dart';
import 'package:sun_sports/core/services/providers/websocket_provider.dart';
import 'package:sun_sports/core/providers/live_chat_expanded_provider.dart';
import 'package:sun_sports/shared/widgets/toast/app_toast.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

abstract final class ChatLineMetrics {
  static const double fontSize = 14;

  static const double chatLineText = 18;

  static const double chatLineGap = 4;

  static const double chatLine = chatLineText + chatLineGap;

  static const double chatLineHeightFactor = chatLineText / fontSize;

  static const double listPaddingTop = 3;
  static const double listPaddingBottom = 3;

  static const int chatVisibleLines = 3;

  static const int chatVisibleLinesExpanded = 6;

  static const double inputBlock = 6 + 8 + 24 + 8 + 12;

  static const double listPadding = listPaddingTop + listPaddingBottom;

  static const double topPeek = 8;

  static const double collapsed =
      listPadding + chatLine * chatVisibleLines + topPeek;

  static const double expanded =
      listPadding + chatLine * chatVisibleLinesExpanded + topPeek + inputBlock;

  static double voltaCollapsedFor(int lines) => listPadding + chatLine * lines;

  static const double topFade = 12;

  static const double topFadeUnderHeader = 20;
}

class SportLiveChat extends ConsumerStatefulWidget {
  final String onlineCount;
  final String placeholderText;
  final bool isMobile;
  final String? currentUserName;

  final Color? headerColor;

  const SportLiveChat({
    super.key,
    this.onlineCount = '65,000',
    this.placeholderText = ' Nhắn tin',
    this.isMobile = false,
    this.currentUserName,
    this.headerColor,
  });

  @override
  ConsumerState<SportLiveChat> createState() => _SportLiveChatState();
}

const double _cardRadius = 16;

class _SportLiveChatState extends ConsumerState<SportLiveChat>
    with WidgetsBindingObserver {
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  final GlobalKey _widgetKey = GlobalKey();

  bool _hasText = false;

  bool _wasFocusedBeforeBackground = false;

  static const int _maxWidgetRetries = 3;
  int _widgetRetryCount = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _connectChat();
    });

    _messageController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (!mounted) return;
    final hasText = _messageController.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  Future<void> _connectChat() async {
    if (!mounted) return;

    final manager = ref.read(websocketProvider.notifier).manager;

    if (!manager.chat.isConnected && !manager.chat.isLoggedIn) {
      await ref.read(websocketProvider.notifier).connectChat();

      if (mounted && !manager.chat.isConnected) {
        _widgetRetryCount++;
        if (_widgetRetryCount < _maxWidgetRetries) {
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) _connectChat();
          });
        }
      } else {
        _widgetRetryCount = 0;
      }
    } else if (manager.chat.isLoggedIn) {
      final currentMessages = ref.read(chatMessagesProvider);
      if (currentMessages.isEmpty) {
        ref.read(websocketProvider.notifier).fetchChatHistory();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _messageController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _wasFocusedBeforeBackground = _focusNode.hasFocus;
    } else if (state == AppLifecycleState.resumed) {
      if (_wasFocusedBeforeBackground) {
        _wasFocusedBeforeBackground = false;

        if (kIsWeb) {
          _focusNode.unfocus();
          return;
        }

        _focusNode.unfocus();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _focusNode.requestFocus();
          }
        });
      }
    }
  }

  static const double _minBalanceToChat = 20000;

  void _handleSendMessage(bool isConnected) {
    debugPrint('[SportLiveChat] send tapped (isConnected=$isConnected)');
    final userBalance = ref.read(userBalanceProvider);
    if (userBalance < _minBalanceToChat) {
      AppToast.showError(
        context,
        message: 'Vui lòng nạp tối thiểu 20k để sử dụng tính năng này',
      );
      return;
    }
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    if (!isConnected) {
      AppToast.showError(context, message: 'Đang kết nối, vui lòng thử lại');
      return;
    }

    ref.read(websocketProvider.notifier).sendChatMessage(text);

    _messageController.clear();
  }

  Color _getUsernameColor(ChatMessageData message) {

    final currentUser = ref.read(currentUserProvider);
    if (currentUser != null && message.displayName == currentUser.displayName) {
      return const Color(0xFFF9BF5A);
    }

    if (message.isSystemMessage || message.isError) {
      return const Color(0xFFFF5252);
    }

    return const Color(0xFFF38744);
  }

  Color _getMessageColor(ChatMessageData message) {
    if (message.isError) {
      return const Color(0xFFFF5252);
    }
    return const Color(0xFFFFFEF5);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<bool>(liveChatExpandedProvider, (previous, next) {
      if (widget.isMobile && next && !_focusNode.hasFocus) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _focusNode.requestFocus();
          }
        });
      }
    });

    final isExpanded = ref.watch(liveChatExpandedProvider);
    final headerColor = widget.isMobile ? widget.headerColor : null;
    final underHeader = headerColor != null;

    final BorderRadius cardRadius = BorderRadius.only(
      bottomLeft: const Radius.circular(_cardRadius),
      bottomRight: const Radius.circular(_cardRadius),
      topLeft: underHeader ? Radius.zero : const Radius.circular(_cardRadius),
      topRight: underHeader ? Radius.zero : const Radius.circular(_cardRadius),
    );

    return GestureDetector(
      key: _widgetKey,
      onTap: SoundTap.wrap(() {
      }),
      behavior: HitTestBehavior.deferToChild,
      child: FocusScope(
        canRequestFocus: true,
        child: InnerShadowCard(
          borderRadius: _cardRadius,
          showHighlight: !underHeader,
          child: Stack(
            children: [
              Positioned.fill(
                child: Stack(
                  children: [
                    Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: AppColorStyles.backgroundTertiary,
                        borderRadius: cardRadius,
                        border: Border(
                          bottom: BorderSide(
                            color: const Color.fromRGBO(255, 255, 255, 0.12),
                            width: 1.0,
                          ),
                        ),
                        boxShadow: (widget.isMobile && isExpanded)
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.50),
                                  offset: const Offset(0, 12),
                                  blurRadius: 20,
                                  spreadRadius: 0,
                                ),
                              ]
                            : null,
                      ),
                      padding: const EdgeInsets.only(
                        top: ChatLineMetrics.listPaddingTop,
                      ),
                      child: Column(
                        children: [
                          if (!widget.isMobile)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              decoration: const BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Live chat',
                                      style: AppTextStyles.displayStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFFFFFCDA),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          Expanded(
                            child: GestureDetector(
                              onTap: SoundTap.wrap(() {
                                if (!widget.isMobile) return;
                                final expanded = ref.read(
                                  liveChatExpandedProvider,
                                );
                                if (!expanded) {
                                  ref
                                          .read(
                                            liveChatExpandedProvider.notifier,
                                          )
                                          .state =
                                      true;
                                  _focusNode.requestFocus();
                                } else {
                                  _focusNode.unfocus();
                                  ref
                                          .read(
                                            liveChatExpandedProvider.notifier,
                                          )
                                          .state =
                                      false;
                                }
                              }),
                              behavior: HitTestBehavior.opaque,
                              child: NotificationListener<ScrollNotification>(
                                onNotification: (notification) => false,
                                child: Consumer(
                                  builder: (context, ref, _) {
                                    final messages = ref.watch(
                                      chatMessagesProvider,
                                    );
                                    final isConnected = ref.watch(
                                      chatLoggedInProvider,
                                    );
                                    return Stack(
                                      children: [
                                        Positioned.fill(
                                          child: Container(
                                          padding: EdgeInsets.fromLTRB(
                                            12,
                                            0,
                                            12,
                                            widget.isMobile
                                                ? ChatLineMetrics.listPaddingBottom
                                                : 12,
                                          ),
                                          child: messages.isEmpty
                                              ? Center(
                                                  child: Text(
                                                    isConnected
                                                        ? 'Chưa có tin nhắn'
                                                        : 'Đang kết nối...',
                                                    style: AppTextStyles.textStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w400,
                                                      color: const Color(
                                                        0xFFAAA49B,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : ScrollConfiguration(
                                                  behavior: ScrollConfiguration.of(
                                                    context,
                                                  ).copyWith(scrollbars: false),
                                                  child: MediaQuery.removePadding(
                                                    context: context,
                                                    removeTop: true,
                                                    removeBottom: true,
                                                    child: ListView.builder(
                                                      controller: _scrollController,
                                                      reverse: true,
                                                      itemCount: messages.length,
                                                      itemBuilder: (context, index) {
                                                        final message =
                                                            messages[messages
                                                                    .length -
                                                                1 -
                                                                index];
                                                        return _buildMessageItem(
                                                          message,
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                          ),
                                        ),
                                        if (!underHeader)
                                        const Positioned(
                                          top: 0,
                                          left: 0,
                                          right: 0,
                                          height: ChatLineMetrics.topFade,
                                          child: IgnorePointer(
                                            child: ChatTopFade(),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          ClipRect(
                            child: Align(
                              alignment: Alignment.topCenter,
                              heightFactor: (!widget.isMobile || isExpanded)
                                  ? 1.0
                                  : 0.0,
                              child: Consumer(
                                builder: (context, ref, _) {
                                  final isConnected = ref.watch(
                                    chatLoggedInProvider,
                                  );
                                  return Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: widget.isMobile ? 14 : 16,
                                      vertical: widget.isMobile ? 8 : 0,
                                    ),
                                    margin: widget.isMobile
                                        ? const EdgeInsets.fromLTRB(
                                            12,
                                            6,
                                            12,
                                            12,
                                          )
                                        : EdgeInsets.zero,
                                    height: widget.isMobile ? null : 44,
                                    decoration: BoxDecoration(
                                      color: widget.isMobile
                                          ? AppColorStyles.backgroundQuaternary
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(
                                        widget.isMobile ? 12 : 10,
                                      ),
                                      boxShadow: widget.isMobile
                                          ? [
                                              BoxShadow(
                                                color: Colors.black.withValues(
                                                  alpha: 0.05,
                                                ),
                                                offset: const Offset(0, 1),
                                                blurRadius: 2,
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            controller: _messageController,
                                            focusNode: _focusNode,
                                            enabled:
                                                true,
                                            maxLength: 50,
                                            buildCounter:
                                                (
                                                  context, {
                                                  required currentLength,
                                                  required isFocused,
                                                  maxLength,
                                                }) => null,
                                            cursorColor: const Color(
                                              0xFFE3A637,
                                            ),
                                            style: AppTextStyles.textStyle(
                                              fontSize: widget.isMobile
                                                  ? 16
                                                  : 14,
                                              fontWeight: FontWeight.w400,
                                              color:
                                                  AppColorStyles.contentPrimary,
                                              height: widget.isMobile
                                                  ? 24 / 16
                                                  : null,
                                            ),
                                            decoration: InputDecoration(
                                              hintText: isConnected
                                                  ? widget.placeholderText
                                                  : 'Nhập tin nhắn',
                                              hintStyle:
                                                  AppTextStyles.textStyle(
                                                    fontSize: widget.isMobile
                                                        ? 16
                                                        : 14,
                                                    fontWeight: FontWeight.w400,
                                                    color: AppColorStyles
                                                        .contentTertiary,
                                                    height: widget.isMobile
                                                        ? 24 / 16
                                                        : null,
                                                  ),
                                              border: InputBorder.none,
                                              contentPadding: EdgeInsets.zero,
                                              isDense: true,
                                            ),
                                            onChanged: (_) {
                                              _onTextChanged();
                                            },
                                            onSubmitted: (_) =>
                                                _handleSendMessage(isConnected),
                                            textInputAction:
                                                TextInputAction.send,
                                            contextMenuBuilder:
                                                (context, editableTextState) {
                                                  return AdaptiveTextSelectionToolbar.editableText(
                                                    editableTextState:
                                                        editableTextState,
                                                  );
                                                },
                                            onTapOutside: widget.isMobile
                                                ? (event) {
                                                    final RenderBox? renderBox =
                                                        _widgetKey
                                                                .currentContext
                                                                ?.findRenderObject()
                                                            as RenderBox?;
                                                    if (renderBox != null) {
                                                      final localPosition =
                                                          renderBox
                                                              .globalToLocal(
                                                                event.position,
                                                              );
                                                      final isInsideWidget =
                                                          localPosition.dx >=
                                                              0 &&
                                                          localPosition.dx <=
                                                              renderBox
                                                                  .size
                                                                  .width &&
                                                          localPosition.dy >=
                                                              0 &&
                                                          localPosition.dy <=
                                                              renderBox
                                                                  .size
                                                                  .height;

                                                      if (!isInsideWidget) {
                                                        _focusNode.unfocus();
                                                        ref
                                                                .read(
                                                                  liveChatExpandedProvider
                                                                      .notifier,
                                                                )
                                                                .state =
                                                            false;
                                                      }
                                                    }
                                                  }
                                                : null,
                                          ),
                                        ),
                                        if (_hasText) ...[
                                          SizedBox(
                                            width: widget.isMobile ? 4 : 2,
                                          ),
                                          GestureDetector(
                                            behavior: HitTestBehavior.opaque,
                                            onTap: SoundTap.wrap(
                                              () => _handleSendMessage(
                                                isConnected,
                                              ),
                                            ),
                                            child: Container(
                                              width: 40,
                                              height: 40,
                                              color: Colors.transparent,
                                              alignment: Alignment.center,
                                              child: ImageHelper.load(
                                                path: AppIcons.iconSend,
                                                width: 24,
                                                height: 24,
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.isMobile && isExpanded)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(16),
                                bottomRight: Radius.circular(16),
                              ),
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.12),
                                  width: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (underHeader)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: ChatLineMetrics.topFadeUnderHeader,
                  child: IgnorePointer(
                    child: ChatTopFade(color: headerColor),
                  ),
                ),
              if (widget.isMobile && isExpanded)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 40,
                  child: IgnorePointer(
                    child: ClipRRect(
                      borderRadius: cardRadius,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFF000000),
                              Color(0x00000000),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              if (widget.isMobile)
                Positioned(
                  bottom: !isExpanded ? 8 : 60,
                  right: 8,
                  child: GestureDetector(
                    onTap: SoundTap.wrap(() {
                      final willExpand = !isExpanded;
                      ref.read(liveChatExpandedProvider.notifier).state =
                          willExpand;
                      if (widget.isMobile) {
                        if (willExpand) {
                          _focusNode.requestFocus();
                        } else {
                          _focusNode.unfocus();
                        }
                      }
                    }),
                    child: Center(
                      child: AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Transform.rotate(
                          angle: 90 * pi / 180,
                          child: ImageHelper.load(
                            path: AppIcons.btnArrowRight,
                            width: 24,
                            height: 24,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
        ),
        ),
      ),
    );
  }

  Widget _buildMessageItem(ChatMessageData message) {
    final usernameColor = _getUsernameColor(message);
    final messageColor = _getMessageColor(message);

    if (message.isSystemMessage) {
      return Padding(
        padding: const EdgeInsets.only(bottom: ChatLineMetrics.chatLineGap),
        child: Text(
          message.message,
          style: AppTextStyles.textStyle(
            fontSize: ChatLineMetrics.fontSize,
            fontWeight: FontWeight.w400,
            color: messageColor,
            height: ChatLineMetrics.chatLineHeightFactor,
          ),
          softWrap: true,
          overflow: TextOverflow.visible,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: ChatLineMetrics.chatLineGap),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${message.displayName}: ',
                    style: AppTextStyles.textStyle(
                      fontSize: ChatLineMetrics.fontSize,
                      fontWeight: FontWeight.w500,
                      color: usernameColor,
                      height: ChatLineMetrics.chatLineHeightFactor,
                    ),
                  ),
                  TextSpan(
                    text: message.message,
                    style: AppTextStyles.textStyle(
                      fontSize: ChatLineMetrics.fontSize,
                      fontWeight: FontWeight.w400,
                      color: messageColor,
                      height: ChatLineMetrics.chatLineHeightFactor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatTopFade extends StatelessWidget {
  const ChatTopFade({super.key, this.color});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    final background = color ?? AppColorStyles.backgroundTertiary;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [background, background.withValues(alpha: 0)],
        ),
      ),
    );
  }
}
