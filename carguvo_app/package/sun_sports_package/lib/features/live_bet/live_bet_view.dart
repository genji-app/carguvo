import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/live_bet/live_bet_data_table.dart';
import 'package:sun_sports/shared/widgets/cards/inner_shadow_card.dart';
import 'package:sun_sports/shared/widgets/tabs/glow_filter_tabbar.dart';

class LiveBetView extends StatefulWidget {
  const LiveBetView({super.key});

  @override
  State<LiveBetView> createState() => _LiveBetViewState();
}

class _LiveBetViewState extends State<LiveBetView>
    with TickerProviderStateMixin {
  late TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 3, vsync: this);
    _controller.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (!_controller.indexIsChanging) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTabChange);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InnerShadowCard(
      borderRadius: 12,
      child: Container(
        decoration: BoxDecoration(
          color: AppColorStyles.backgroundTertiary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            LiveBetHeader(controller: _controller),
            const Gap(8),
            LiveBetDataTable(data: _getMockData(_controller.index)),
          ],
        ),
      ),
    );
  }

  List<LiveBetData> _getMockData(int index) {
    switch (index) {
      case 1:
        return List.generate(
          5,
          (i) => LiveBetData(
            'Bóng đá (Mine)',
            '2.10',
            'Tri********9',
            '50,000,000',
          ),
        );
      case 2:
        return List.generate(
          8,
          (i) => LiveBetData(
            'Bóng đá (Big Win)',
            '5.50',
            'Tri********9',
            '999,000,000',
          ),
        );
      default:
        return List.generate(
          20,
          (i) => LiveBetData('Bóng đá', '1.75', 'Tri********9', '195,000,000'),
        );
    }
  }
}

class LiveBetHeader extends StatelessWidget implements PreferredSizeWidget {
  final TabController? controller;
  static const List<String> tabs = ['Tất cả', 'Của tôi', 'Thắng lớn'];

  const LiveBetHeader({super.key, this.controller});

  @override
  Size get preferredSize => const Size.fromHeight(78);

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: preferredSize,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _LiveBetTitle(),
          GlowFilterTabbar<String>(controller: controller, tabs: tabs),
        ],
      ),
    );
  }
}

class _LiveBetTitle extends StatelessWidget {
  const _LiveBetTitle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
      child: Text(
        'Live bet',
        style: AppTextStyles.labelMedium(color: AppColorStyles.contentPrimary),
      ),
    );
  }
}
