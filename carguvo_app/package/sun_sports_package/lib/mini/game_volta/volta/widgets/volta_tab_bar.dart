import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sun_sports/core/utils/styles/app_text_styles.dart';

import '../../common/state/volta_state.dart';
import '../../common/state/volta_state_provider.dart';
import '../../common/volta_colors.dart';
import '../../common/volta_layout_spec.dart';
import '../../common/volta_gradients.dart';
import '../../common/volta_metrics.dart';

class VoltaTabBar extends ConsumerWidget {
  const VoltaTabBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(voltaStateProvider.select((s) => s.tab));
    final VoltaLayoutSpec spec = VoltaLayoutScope.of(context);
    final double padY =
        (spec.tabBarBlockHeight - VoltaMetrics.tabBarHeight) / 2;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: padY),
      child: Container(
        height: VoltaMetrics.tabBarHeight,
        decoration: _barDecoration,
        child: Row(
          children: <Widget>[
            for (int i = 0; i < VoltaTab.values.length; i++) ...<Widget>[
              if (i > 0 &&
                  VoltaTab.values[i - 1] != current &&
                  VoltaTab.values[i] != current)
                const _TabDivider(),
              Expanded(
                child: _VoltaTabItem(
                  tab: VoltaTab.values[i],
                  selected: VoltaTab.values[i] == current,
                  onTap: () => ref
                      .read(voltaStateProvider.notifier)
                      .selectTab(VoltaTab.values[i]),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static final BoxDecoration _barDecoration = BoxDecoration(
    gradient: VoltaGradients.tabBar,
    borderRadius: BorderRadius.circular(VoltaMetrics.tabBarRadius),
    border: Border.all(color: VoltaColors.hairline, width: 0.5),
  );
}

class _TabDivider extends StatelessWidget {
  const _TabDivider();

  static const double _width = 1;

  static const double _heightRatio = 0.6;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: _width,
    child: Center(
      child: Container(
        width: _width,
        height: VoltaMetrics.tabBarHeight * _heightRatio,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              Color(0x00FFFFFF),
              VoltaColors.tabDivider,
              Color(0x00FFFFFF),
            ],
          ),
        ),
      ),
    ),
  );
}

class _VoltaTabItem extends StatelessWidget {
  const _VoltaTabItem({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  final VoltaTab tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Widget label = Center(
      child: Text(
        tab.label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.labelSmall(
          color: selected
              ? VoltaColors.yellow300
              : VoltaColors.contentSecondary,
        ),
      ),
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: selected ? _selectedPill(label) : label,
    );
  }

  Widget _selectedPill(Widget label) => ClipRRect(
    borderRadius: BorderRadius.circular(VoltaMetrics.tabActiveRadius),
    child: DecoratedBox(
      decoration: _selectedBase,
      child: DecoratedBox(
        decoration: _selectedSheen,
        child: Stack(
          fit: StackFit.passthrough,
          children: <Widget>[
            label,
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 1,
              child: DecoratedBox(decoration: _selectedBottomEdge),
            ),
          ],
        ),
      ),
    ),
  );

  static const BoxDecoration _selectedBottomEdge = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: <Color>[
        Color(0x47FDE272),
        Color(0xF2FDE272),
        Color(0x47FDE272),
      ],
    ),
  );

  static final BoxDecoration _selectedBase = BoxDecoration(
    color: const Color(0xFF252423),
    borderRadius: BorderRadius.circular(VoltaMetrics.tabActiveRadius),
  );

  static final BoxDecoration _selectedSheen = BoxDecoration(
    gradient: VoltaGradients.tabActiveSheen,
    borderRadius: BorderRadius.circular(VoltaMetrics.tabActiveRadius),
  );
}
