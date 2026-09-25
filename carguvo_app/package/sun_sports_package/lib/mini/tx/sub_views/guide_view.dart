import 'package:flutter/material.dart';

import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_images.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/core/utils/styles/mini_game_icons.dart';
import 'package:sun_sports/shared/widgets/buttons/shine_button.dart';
import 'package:sun_sports/shared/widgets/texts/texts.dart';

import 'tai_xiu_sub_view_scaffold.dart';

class GuideView extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onClose;

  const GuideView({required this.onBack, required this.onClose, super.key});

  static const List<bool> _demoHistory = [
    true, false, true, false, true, false, false, true, false, false,
    true, true, true,
  ];

  @override
  Widget build(BuildContext context) => TaiXiuSubViewScaffold(
    title: TaiXiuSubView.guide.title,
    onBack: onBack,
    onClose: onClose,
    child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Luật chơi'),
          const SizedBox(height: 8),
          const _RuleBullet('Tiền thắng = tiền cược x 2'),
          const SizedBox(height: 4),
          const _RuleBullet(
            'Nhà cái sẽ trả lại tiền của bên cược cao hơn cho user đặt sau '
            'để cân cửa',
          ),
          const SizedBox(height: 12),
          const _BetGuideRow(
            buttons: [
              _GuideButton(text: 'Đặt cược', style: ShineButtonStyle.primaryYellowDark),
              _GuideButton(text: 'Đặt cược', style: ShineButtonStyle.primaryGray),
            ],
            description: 'Chọn cửa cược',
          ),
          const SizedBox(height: 12),
          const _BetGuideRow(
            buttons: [_GuideButton(text: 'All in', style: ShineButtonStyle.primaryPurple)],
            description: 'Cược tất cả',
          ),
          const SizedBox(height: 12),
          const _BetGuideRow(
            buttons: [_GuideButton(text: 'Cược', style: ShineButtonStyle.minigameGold)],
            description: 'Đồng ý lệnh cược',
          ),
          const SizedBox(height: 12),
          const _BetGuideRow(
            buttons: [_GuideButton(text: 'Hủy', style: ShineButtonStyle.minigameRed)],
            description: 'Hủy lệnh đặt cược',
          ),
          const SizedBox(height: 12),
          _BetGuideRow(
            buttons: [
              ImageHelper.load(path: MiniGameIcons.mpBowlGuide, width: 36, height: 36),
            ],
            description: 'Bật/tắt chế độ nặn',
          ),
          const SizedBox(height: 12),
          const _AmountGuideRow(),
          const SizedBox(height: 12),
          const _Divider(),
          const SizedBox(height: 12),
          const _SectionTitle('Tính năng'),
          const SizedBox(height: 12),
          const _FeatureGrid(),
          const SizedBox(height: 12),
          const _SoiCauRow(history: _demoHistory),
        ],
      ),
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: AppTextStyles.textStyle(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      height: 20 / 14,
      color: AppColors.green400,
    ),
  );
}

class _RuleBullet extends StatelessWidget {
  final String text;

  const _RuleBullet(this.text);

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyles.textStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 20 / 14,
      color: AppColorStyles.contentPrimary,
    );
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('•  ', style: style),
          Expanded(child: Text(text, style: style)),
        ],
      ),
    );
  }
}

class _BetGuideRow extends StatelessWidget {
  final List<Widget> buttons;
  final String description;

  const _BetGuideRow({required this.buttons, required this.description});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      for (var i = 0; i < buttons.length; i++) ...[
        if (i > 0) const SizedBox(width: 8),
        buttons[i],
      ],
      const SizedBox(width: 12),
      Expanded(child: _DescText(description)),
    ],
  );
}

class _GuideButton extends StatelessWidget {
  final String text;
  final ShineButtonStyle style;

  const _GuideButton({required this.text, required this.style});

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: ShineButton(
      text: text,
      style: style,
      height: 36,
      width: 120,
      onPressed: () {},
    ),
  );
}

class _AmountGuideRow extends StatelessWidget {
  const _AmountGuideRow();

  static const List<String> _amounts = ['5K', '50K', '500K', '5M', '50M'];

  @override
  Widget build(BuildContext context) => Row(
    children: [
      for (var i = 0; i < _amounts.length; i++) ...[
        if (i > 0) const SizedBox(width: 6),
        _AmountChip(_amounts[i]),
      ],
      const SizedBox(width: 12),
      const Expanded(child: _DescText('Chọn mệnh giá')),
    ],
  );
}

class _AmountChip extends StatelessWidget {
  final String label;

  const _AmountChip(this.label);

  @override
  Widget build(BuildContext context) => Container(
    height: 24,
    padding: const EdgeInsets.symmetric(horizontal: 10),
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: AppColors.yellow300.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(60),
    ),
    child: GradientText(
      label,
      style: AppTextStyles.textStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        height: 1,
      ),
    ),
  );
}

class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid();

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Row(
        children: [
          Expanded(
            child: _FeatureItem(icon: MiniGameIcons.txChart, label: 'Lịch sử phiên'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _FeatureItem(icon: MiniGameIcons.txSearch, label: 'Thống kê phiên'),
          ),
        ],
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(
            child: _FeatureItem(icon: MiniGameIcons.txHistory, label: 'Lịch sử cược'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _FeatureItem(icon: MiniGameIcons.txRanking, label: 'Bảng xếp hạng'),
          ),
        ],
      ),
    ],
  );
}

class _FeatureItem extends StatelessWidget {
  final String icon;
  final String label;

  const _FeatureItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColorStyles.backgroundTertiary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ImageHelper.load(
          path: icon,
          width: 16,
          height: 16,
          color: AppColorStyles.contentSecondary,
        ),
      ),
      const SizedBox(width: 8),
      Expanded(child: _DescText(label)),
    ],
  );
}

class _SoiCauRow extends StatelessWidget {
  final List<bool> history;

  const _SoiCauRow({required this.history});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
          decoration: const BoxDecoration(
            color: AppColorStyles.backgroundTertiary,
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final (i, isTai) in history.indexed)
                KeyedSubtree(
                  key: ValueKey(i),
                  child: ImageHelper.load(
                    path: isTai ? MiniGameIcons.txTaiCircle : MiniGameIcons.txXiuCircle,
                    width: 12,
                    height: 12,
                  ),
                ),
            ],
          ),
        ),
      ),
      const SizedBox(width: 8),
      const _DescText('Soi cầu'),
    ],
  );
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) => ImageHelper.load(
    path: AppIcons.hr,
    width: double.infinity,
    height: 2,
    fit: BoxFit.fill,
  );
}

class _DescText extends StatelessWidget {
  final String text;

  const _DescText(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: AppTextStyles.textStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 18 / 12,
      color: AppColorStyles.contentSecondary,
    ),
  );
}
