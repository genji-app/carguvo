import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';

class HomeTabletBettingSection extends StatelessWidget {
  const HomeTabletBettingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
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
          child: Column(
            children: [
              Container(
                height: 32,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: AppColorStyles.borderSecondary,
                      width: 1,
                    ),
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
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
                        style: AppTextStyles.labelXSmall(
                          color: AppColorStyles.contentSecondary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Tỷ lệ',
                        style: AppTextStyles.labelXSmall(
                          color: AppColorStyles.contentSecondary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Thành toán',
                        style: AppTextStyles.labelXSmall(
                          color: AppColorStyles.contentSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: List.generate(
                  10,
                  (index) => _buildBettingRow(
                    sport: 'Bóng đá',
                    username: 'hello123',
                    time: '100K',
                    odds: '0.95',
                    amount: '195K',
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader() {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 12),
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
          _buildTab('Tất cả', isSelected: true),
          const Gap(8),
          _buildTab('Của tôi', isSelected: false),
          const Gap(8),
          _buildTab('Thắng lớn', isSelected: false),
        ],
      ),
    );
  }

  Widget _buildTab(String label, {required bool isSelected}) {
    return Container(
      height: 28,
      decoration: BoxDecoration(
        color: isSelected
            ? AppColorStyles.backgroundQuaternary
            : Colors.transparent,
        borderRadius: BorderRadius.circular(100),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Center(
        child: Text(
          label,
          style: AppTextStyles.labelXSmall(
            color: isSelected
                ? AppColorStyles.contentPrimary
                : AppColorStyles.contentSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildBettingRow({
    required String sport,
    required String username,
    required String time,
    required String odds,
    required String amount,
  }) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Color(0xFF262626),
                    shape: BoxShape.circle,
                  ),
                ),
                const Gap(8),
                Expanded(
                  child: Text(
                    sport,
                    style: AppTextStyles.labelXSmall(
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
              style: AppTextStyles.labelXSmall(
                color: AppColorStyles.contentPrimary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '\$$time',
              style: AppTextStyles.labelXSmall(
                color: AppColorStyles.contentPrimary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              odds,
              style: AppTextStyles.labelXSmall(
                color: AppColorStyles.contentPrimary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '\$$amount',
              style: AppTextStyles.labelXSmall(color: const Color(0xFF10B981)),
            ),
          ),
        ],
      ),
    );
  }
}
