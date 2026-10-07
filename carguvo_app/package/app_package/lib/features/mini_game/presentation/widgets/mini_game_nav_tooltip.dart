import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:app_package/core/utils/styles/app_text_styles.dart';
import 'package:app_package/features/mini_game/presentation/state/mini_game_nav_status.dart';
import 'package:app_package/features/mini_game/mini_game_lobby.dart';

class MiniGameNavTooltip extends ConsumerStatefulWidget {
  const MiniGameNavTooltip({super.key});

  @override
  ConsumerState<MiniGameNavTooltip> createState() => _MiniGameNavTooltipState();
}

class _MiniGameNavTooltipState extends ConsumerState<MiniGameNavTooltip> {
  static const Duration _connectedHold = Duration(milliseconds: 1800);

  static const double _tailWidth = 16;
  static const double _tailHeight = 8;
  static const double _sideMargin = 12;

  static const Color _bubble = Color(0xFF3A3A38);
  static const Color _amber = Color(0xFFE8A53C);
  static const Color _green = Color(0xFF12B76A);
  static const Color _pink = Color(0xFFFDA29B);

  Timer? _hideTimer;

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  void _setTip(MiniGameNavTip tip) {
    _hideTimer?.cancel();
    _hideTimer = null;
    if (tip == MiniGameNavTip.connected) {
      _hideTimer = Timer(_connectedHold, () {
        _hideTimer = null;
        if (mounted) _setTip(MiniGameNavTip.hidden);
      });
    }
    ref.read(miniGameNavTipProvider.notifier).state = tip;
  }

  void _syncToConn(MiniGameNavConn conn) {
    final tip = ref.read(miniGameNavTipProvider);
    if (tip == MiniGameNavTip.hidden) return;
    switch (conn) {
      case MiniGameNavConn.guest:
        _setTip(MiniGameNavTip.hidden);
      case MiniGameNavConn.ready:
        if (tip != MiniGameNavTip.connected) _setTip(MiniGameNavTip.connected);
      case MiniGameNavConn.failed:
        if (tip != MiniGameNavTip.failed) _setTip(MiniGameNavTip.failed);
      case MiniGameNavConn.connecting:
        if (tip != MiniGameNavTip.connecting) {
          _setTip(MiniGameNavTip.connecting);
        }
    }
  }

  Future<void> _onRetry() async {
    ref.read(miniGameNavFailedProvider.notifier).state = false;
    _setTip(MiniGameNavTip.connecting);
    try {
      final client = await ref.read(miniGameLobbyProvider.future);
      await client.ensureConnected();
    } catch (_) {
    }
    if (!mounted) return;
    _syncToConn(ref.read(miniGameNavConnProvider));
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<MiniGameNavConn>(miniGameNavConnProvider, (prev, next) {
      _syncToConn(next);
    });

    final tip = ref.watch(miniGameNavTipProvider);
    if (tip == MiniGameNavTip.hidden) return const SizedBox.shrink();

    final (Widget leading, String label, bool retry) = switch (tip) {
      MiniGameNavTip.failed => (
        const Icon(Icons.link_off, size: 20, color: _pink),
        'Mất kết nối Mini games',
        true,
      ),
      MiniGameNavTip.connected => (
        const Icon(Icons.check, size: 20, color: _green),
        'Đã kết nối',
        false,
      ),
      _ => (
        const SizedBox.square(
          dimension: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(_amber),
            backgroundColor: Color(0x40FFFFFF),
          ),
        ),
        'Đang kết nối Mini games',
        false,
      ),
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final tailCentre = width * 0.7 - 3.2;
        final minBodyWidth = width * 0.3 + 28;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: _sideMargin),
              child: Align(
                alignment: Alignment.centerRight,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: minBodyWidth),
                  child: _body(leading, label, retry),
                ),
              ),
            ),
            SizedBox(
              height: _tailHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: tailCentre - _tailWidth / 2,
                    top: 0,
                    child: CustomPaint(
                      size: const Size(_tailWidth, _tailHeight),
                      painter: _TailPainter(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _body(Widget leading, String label, bool retry) => DecoratedBox(
    decoration: BoxDecoration(
      color: _bubble,
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(
          color: Color(0x73000000),
          blurRadius: 16,
          offset: Offset(0, 6),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          leading,
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              label,
              style: AppTextStyles.labelSmall(color: Colors.white),
            ),
          ),
          if (retry) ...[
            const SizedBox(width: 12),
            _RetryButton(onTap: _onRetry),
          ],
        ],
      ),
    ),
  );
}

class _RetryButton extends StatelessWidget {
  const _RetryButton({required this.onTap});

  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Text(
        'Thử lại',
        style: AppTextStyles.labelSmall(color: Colors.white),
      ),
    ),
  );
}

class _TailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(
      path,
      Paint()..color = _MiniGameNavTooltipState._bubble,
    );
  }

  @override
  bool shouldRepaint(covariant _TailPainter oldDelegate) => false;
}
