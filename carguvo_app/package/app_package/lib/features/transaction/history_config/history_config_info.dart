import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:app_package/core/utils/extensions/image_helper.dart';
import 'package:app_package/core/utils/styles/app_color.dart';
import 'package:app_package/core/utils/styles/app_color_styles.dart';
import 'package:app_package/core/utils/styles/app_icons.dart';
import 'package:app_package/core/utils/styles/app_text_styles.dart';
import 'package:app_package/shared/widgets/buttons/sound_tap.dart';
import 'package:app_package/shared/widgets/cards/inner_shadow_card.dart';

class HistoryConfigInfoButton extends StatelessWidget {
  const HistoryConfigInfoButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 40,
      child: IconButton(
        tooltip: 'Thời gian lưu lịch sử giao dịch',
        onPressed: SoundTap.wrap(() => HistoryConfigInfoDialog.show(context)),
        icon: ImageHelper.load(
          path: AppIcons.helpCircle,
          width: 24,
          height: 24,
        ),
        style: IconButton.styleFrom(
          backgroundColor: AppColorStyles.backgroundQuaternary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          iconSize: 24,
        ),
      ),
    );
  }
}

class _SecurityLevel {
  const _SecurityLevel({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.titleColor,
    required this.tagColor,
    required this.glowColors,
    required this.glowStops,
    required this.borderColor,
  });

  final String icon;
  final String title;
  final String subtitle;
  final String tag;
  final Color titleColor;
  final Color tagColor;

  final List<Color> glowColors;
  final List<double> glowStops;

  final Color borderColor;
}

const _greenGlow = [
  Color.fromRGBO(0, 195, 255, 1),
  Color.fromRGBO(16, 193, 239, 0.9375),
  Color.fromRGBO(32, 190, 223, 0.875),
  Color.fromRGBO(64, 184, 191, 0.75),
  Color.fromRGBO(96, 178, 159, 0.625),
  Color.fromRGBO(128, 172, 128, 0.5),
  Color.fromRGBO(191, 161, 64, 0.25),
  Color.fromRGBO(255, 149, 0, 0),
];
const _greenGlowStops = [0.0, 0.0625, 0.125, 0.25, 0.375, 0.5, 0.75, 1.0];

final _levels = <_SecurityLevel>[
  _SecurityLevel(
    icon: AppIcons.iconSecurity0P,
    title: '0 phút',
    subtitle: 'Xóa ngay',
    tag: 'An toàn tuyệt đối',
    titleColor: AppColors.green400,
    tagColor: AppColors.green400,
    glowColors: _greenGlow,
    glowStops: _greenGlowStops,
    borderColor: Color(0xFF00FFF2),
  ),
  _SecurityLevel(
    icon: AppIcons.iconSecurity2P,
    title: '2 phút',
    subtitle: 'Đề xuất sử dụng',
    tag: 'Khuyến nghị',
    titleColor: AppColors.green400,
    tagColor: AppColors.green400,
    glowColors: _greenGlow,
    glowStops: _greenGlowStops,
    borderColor: Color(0xFF00FFF2),
  ),
  _SecurityLevel(
    icon: AppIcons.iconSecurity15P,
    title: '15 phút',
    subtitle: 'Mặc định',
    tag: 'Mặc định',
    titleColor: AppColors.yellow500,
    tagColor: AppColors.yellow400,
    glowColors: [
      Color.fromRGBO(238, 255, 0, 1),
      Color.fromRGBO(242, 229, 0, 0.75),
      Color.fromRGBO(247, 202, 0, 0.5),
      Color.fromRGBO(251, 176, 0, 0.25),
      Color.fromRGBO(255, 149, 0, 0),
    ],
    glowStops: [0.0, 0.25, 0.5, 0.75, 1.0],
    borderColor: Color(0xFFFFD000),
  ),
  _SecurityLevel(
    icon: AppIcons.iconSecurity60P,
    title: '60 phút',
    subtitle: 'Rủi ro cao',
    tag: 'Không khuyến khích',
    titleColor: AppColors.red500,
    tagColor: AppColors.red500,
    glowColors: [
      Color.fromRGBO(255, 34, 0, 1),
      Color.fromRGBO(255, 63, 0, 0.75),
      Color.fromRGBO(255, 92, 0, 0.5),
      Color.fromRGBO(255, 149, 0, 0),
    ],
    glowStops: [0.0, 0.25, 0.5, 1.0],
    borderColor: Color(0xFFFF4D00),
  ),
];

class HistoryConfigInfoDialog extends StatelessWidget {
  const HistoryConfigInfoDialog({super.key});

  static const double _designWidth = 378;

  static Future<void> show(BuildContext context) => showGeneralDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    barrierDismissible: true,
    useRootNavigator: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (context, animation, secondaryAnimation) =>
        const HistoryConfigInfoDialog(),
  );

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final width = screenWidth - 32 < _designWidth
        ? screenWidth - 32
        : _designWidth;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: InnerShadowCard(
          color: AppColorStyles.backgroundTertiary,
          child: SizedBox(
            width: width,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildHeader(),
                      const Gap(24),
                      for (var i = 0; i < _levels.length; i++) ...[
                        if (i > 0) const Gap(8),
                        _LevelCard(level: _levels[i]),
                      ],
                    ],
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: SoundTap.wrap(() => Navigator.of(context).pop()),
                    child: const Icon(
                      Icons.close,
                      size: 24,
                      color: AppColorStyles.contentSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          Text(
            'Bảo mật',
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.labelLarge(
              color: AppColorStyles.contentPrimary,
            ),
          ),
          const Gap(8),
          Text(
            'Thời gian lưu lịch sử giao dịch',
            textAlign: TextAlign.center,
            style: AppTextStyles.paragraphMedium(
              color: AppColorStyles.contentSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({required this.level});

  final _SecurityLevel level;

  @override
  Widget build(BuildContext context) {
    return InnerShadowCard(
      color: AppColorStyles.backgroundSecondary,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.2,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: level.glowColors,
                      stops: level.glowStops,
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _GradientBorderPainter(level.borderColor),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 13),
              child: Row(
                children: [
                  ImageHelper.load(path: level.icon, width: 39, height: 39),
                  const Gap(16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          level.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.labelSmall(
                            color: level.titleColor,
                          ),
                        ),
                        const Gap(2),
                        Text(
                          level.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.paragraphXSmall(
                            color: AppColorStyles.contentPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(16),
                  Text(
                    level.tag,
                    maxLines: 1,
                    style: AppTextStyles.labelSmall(color: level.tagColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GradientBorderPainter extends CustomPainter {
  _GradientBorderPainter(this.color);

  final Color color;

  static const _fadeColor = Color(0xFFFF9500);
  static const _stops = [0.0, 0.25, 0.5, 0.75, 1.0];

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..shader = LinearGradient(
        begin: const Alignment(-0.956, 0.404),
        end: const Alignment(-1.0, -1.013),
        colors: [
          for (final f in _stops)
            Color.lerp(_fadeColor, color, f)!.withValues(alpha: f),
        ],
        stops: _stops,
      ).createShader(rect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(0.5), const Radius.circular(15.5)),
      paint,
    );
  }

  @override
  bool shouldRepaint(_GradientBorderPainter oldDelegate) =>
      oldDelegate.color != color;
}
