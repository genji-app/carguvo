import 'package:flutter/material.dart';

import 'package:sun_sports/mini/tx/tai_xiu_floating_panels.dart';
import 'package:sun_sports/mini/tx/widgets/tai_xiu_chat_box.dart';

import 'tai_xiu_landscape_game_view.dart';

class TaiXiuLandscapeScreen extends StatelessWidget {
  final VoidCallback onClose;

  const TaiXiuLandscapeScreen({required this.onClose, super.key});

  static const double _kHeaderStrip = 60;

  static const double _gameW = 640;
  static const double _gameH = 500 + _kHeaderStrip;
  static const double _chatW = 338;
  static const double _chatH = 500;
  static const double _gap = 16;

  static const double _kPhoneBreakpoint = 600;
  static const double _kPhoneMinimizedScale = 0.63;

  @override
  Widget build(BuildContext context) {
    return TaiXiuFloatingPanels(
      logLabel: 'TaiXiuLandscapeScreen',
      gameDesignSize: const Size(_gameW, _gameH),
      chatDesignSize: const Size(_chatW, _chatH),
      layoutBounds: const Size(_gameW + _gap + _chatW, _gameH),
      gameDefaultOffset: Offset.zero,
      chatDefaultOffset: const Offset(_gameW + _gap, _kHeaderStrip),
      chatButtonAlignment: Alignment.bottomRight,
      minimizedScaleOf: (constraints) =>
          constraints.biggest.shortestSide < _kPhoneBreakpoint
          ? _kPhoneMinimizedScale
          : TaiXiuFloatingPanels.minimizedScale,
      gameBuilder: (context) => Padding(
        padding: const EdgeInsets.only(top: _kHeaderStrip),
        child: TaiXiuLandscapeGameView(onClose: onClose),
      ),
      chatBuilder: (context, closeChat) => TaiXiuChatBox(onClose: closeChat),
    );
  }
}
