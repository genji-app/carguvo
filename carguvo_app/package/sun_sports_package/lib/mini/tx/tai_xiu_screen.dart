import 'package:flutter/material.dart';

import 'tai_xiu_floating_panels.dart';
import 'widgets/tai_xiu_chat_box.dart';
import 'widgets/tai_xiu_game_view.dart';

class TaiXiuScreen extends StatelessWidget {
  final VoidCallback onClose;

  const TaiXiuScreen({required this.onClose, super.key});

  static const double _contentWidth = 378;

  static const double _chatHeight = 230;

  static const double _gameHeight = 612;

  static const double _gap = 8;

  static const double _phoneBreakpoint = 600;

  static const double _mobileScale = 0.95;

  @override
  Widget build(BuildContext context) {
    return TaiXiuFloatingPanels(
      logLabel: 'TaiXiuScreen',
      gameDesignSize: const Size(_contentWidth, _gameHeight),
      chatDesignSize: const Size(_contentWidth, _chatHeight),
      layoutBounds: const Size(
        _contentWidth,
        _chatHeight + _gap + _gameHeight,
      ),
      chatDefaultOffset: Offset.zero,
      gameDefaultOffset: const Offset(0, _chatHeight + _gap),
      chatButtonAlignment: Alignment.topRight,
      baseScale: (constraints) =>
          constraints.biggest.shortestSide < _phoneBreakpoint
          ? _mobileScale
          : 1.0,
      gameBuilder: (context) => Align(
        alignment: Alignment.topCenter,
        child: TaiXiuGameView(onClose: onClose),
      ),
      chatBuilder: (context, closeChat) => TaiXiuChatBox(onClose: closeChat),
    );
  }
}
