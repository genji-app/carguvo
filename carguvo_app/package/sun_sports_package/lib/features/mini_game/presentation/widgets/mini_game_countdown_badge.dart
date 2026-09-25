import 'package:flutter/material.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';

class MiniGameTaiXiuResultBadge extends StatelessWidget {
  final bool isTai;
  final double size;

  const MiniGameTaiXiuResultBadge({
    required this.isTai,
    super.key,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    return _BadgePill(
      text: isTai ? 'TÀI' : 'XỈU',
      textColor: isTai ? const Color(0xFFFFFEF5) : AppColors.yellow400,
      size: size,
    );
  }
}

class MiniGameTimePillFrame extends StatelessWidget {
  final double size;

  const MiniGameTimePillFrame({this.size = 28, super.key});

  @override
  Widget build(BuildContext context) => _BadgePill(text: '', size: size);
}

class _BadgePill extends StatelessWidget {
  final String text;
  final Color textColor;
  final double size;

  const _BadgePill({
    required this.text,
    required this.size,
    this.textColor = const Color(0xFFFFFEF5),
  });

  @override
  Widget build(BuildContext context) {
    final scale = size / 28.0;
    return Container(
      height: size,
      constraints: BoxConstraints(minWidth: 36 * scale),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x33FFFFFF), width: 0.5),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2F000C), Color(0xFF180005)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 2,
            offset: Offset(0, 2),
          ),
          BoxShadow(
            color: Color(0x80000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -1),
                  radius: 1.95,
                  colors: [
                    Color(0xB8FFBBC9),
                    Color(0x5CFFBBC9),
                    Color(0x00FFBBC9),
                  ],
                  stops: [0.0, 0.3, 1.0],
                ),
              ),
            ),
          ),
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, 1),
                  radius: 0.7,
                  colors: [Color(0x80FF7197), Color(0x00FF7197)],
                ),
              ),
            ),
          ),
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0x91FF99D3), width: 1),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6 * scale),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor,
                fontSize: 16 * scale,
                height: 1.0,
                leadingDistribution: TextLeadingDistribution.even,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.none,
                shadows: const [
                  Shadow(
                    color: Colors.black,
                    blurRadius: 2,
                    offset: Offset(0, 1),
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
