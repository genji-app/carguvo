import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/shared/domain/enums/betting_enums.dart';
import 'package:sun_sports/shared/widgets/cards/inner_shadow_card.dart';

class HomeDesktopBettingSection extends StatelessWidget {
  const HomeDesktopBettingSection({super.key});

  @override
  Widget build(BuildContext context) => InnerShadowCard(
    borderRadius: 16,
    child: Container(
      decoration: BoxDecoration(
        color: AppColorStyles.backgroundTertiary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(),
          const Gap(12),
          Container(
            decoration: BoxDecoration(
              color: AppColorStyles.backgroundTertiary,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.12),
                  offset: const Offset(0, 0.5),
                  blurRadius: 0,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                color: AppColorStyles.backgroundQuaternary,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _buildTableHeader(),
                  const Gap(4),
                  Column(
                    children: List.generate(
                      10,
                      (index) => Padding(
                        padding: EdgeInsets.only(top: index > 0 ? 4 : 0),
                        child: _buildBettingRow(
                          sport: 'Bóng đá',
                          username: 'hello123',
                          amount: '100K',
                          odds: '0.95',
                          payout: '195K',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildSectionHeader() {
    return Container(
      height: 52,
      padding: const EdgeInsets.only(left: 16, right: 12, top: 8, bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Live bet',
              style: AppTextStyles.labelMedium(
                color: AppColorStyles.contentPrimary,
              ),
            ),
          ),
          _buildTab('Tất cả', tab: BettingTab.all, selectedTab: BettingTab.all),
          const Gap(6),
          _buildTab(
            'Của tôi',
            tab: BettingTab.mine,
            selectedTab: BettingTab.all,
          ),
          const Gap(6),
          _buildTab(
            'Thắng lớn',
            tab: BettingTab.bigWin,
            selectedTab: BettingTab.all,
          ),
        ],
      ),
    );
  }

  Widget _buildTab(
    String label, {
    required BettingTab tab,
    required BettingTab selectedTab,
  }) {
    final isSelected = tab == selectedTab;
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: isSelected
                ? AppColorStyles.backgroundTertiary
                : Colors.transparent,
            borderRadius: BorderRadius.circular(100),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.labelSmall(
                color: isSelected
                    ? const Color(0xFFFEEE95)
                    : AppColorStyles.contentSecondary,
              ),
            ),
          ),
        ),
        if (isSelected)
          Positioned.fill(
            child: ImageHelper.load(path: AppIcons.tabActive, fit: BoxFit.fill),
          ),
      ],
    );
  }

  Widget _buildTableHeader() {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Thể thao',
              style: AppTextStyles.labelXSmall(
                color: AppColorStyles.contentSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Người chơi',
              style: AppTextStyles.labelXSmall(
                color: AppColorStyles.contentSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Tiền cược',
              textAlign: TextAlign.right,
              style: AppTextStyles.labelXSmall(
                color: AppColorStyles.contentSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Tỷ lệ',
              textAlign: TextAlign.right,
              style: AppTextStyles.labelXSmall(
                color: AppColorStyles.contentSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Thanh toán',
              textAlign: TextAlign.right,
              style: AppTextStyles.labelXSmall(
                color: AppColorStyles.contentSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBettingRow({
    required String sport,
    required String username,
    required String amount,
    required String odds,
    required String payout,
  }) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: AppColorStyles.backgroundTertiary,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                ImageHelper.load(
                  path: AppIcons.iconSoccer,
                  width: 20,
                  height: 20,
                ),
                const Gap(8),
                Expanded(
                  child: Text(
                    sport,
                    style: AppTextStyles.labelSmall(
                      color: AppColorStyles.contentPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              username,
              style: AppTextStyles.labelSmall(
                color: AppColorStyles.contentSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '\$$amount',
              textAlign: TextAlign.right,
              style: AppTextStyles.labelSmall(
                color: AppColorStyles.contentSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              odds,
              textAlign: TextAlign.right,
              style: AppTextStyles.labelSmall(
                color: AppColorStyles.contentSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '\$$payout',
              textAlign: TextAlign.right,
              style: AppTextStyles.labelSmall(color: const Color(0xFF3CCB7F)),
            ),
          ),
        ],
      ),
    );
  }
}
