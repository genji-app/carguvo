import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sun_sports/core/utils/styles/app_text_styles.dart';

import '../../common/state/volta_models.dart';
import '../../common/state/volta_state_provider.dart';
import '../../common/volta_colors.dart';
import '../../common/volta_rules.dart';
import '../../common/volta_icons.dart';
import '../../common/volta_metrics.dart';
import '../../common/widgets/volta_team_logo.dart';

class VoltaHeadToHeadBoard extends ConsumerWidget {
  const VoltaHeadToHeadBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final h2h = ref.watch(voltaStateProvider.select((s) => s.headToHead));

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 6),
      child: SizedBox(
        width: double.infinity,
        child: DecoratedBox(
          decoration: _cardDecoration,
          child: h2h == null
              ? Center(
                  child: Text(
                    'Chưa có dữ liệu đối đầu',
                    style: AppTextStyles.labelXSmall(
                      color: VoltaColors.contentTertiary,
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: _contentWidth,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(
                              height: _TeamFormRow.height,
                              child: _TeamFormRow(
                                form: h2h.home,
                                color: VoltaColors.red400,
                              ),
                            ),
                            const SizedBox(
                              height: _VsDivider.height,
                              child: _VsDivider(),
                            ),
                            SizedBox(
                              height: _TeamFormRow.height,
                              child: _TeamFormRow(
                                form: h2h.away,
                                color: VoltaColors.yellow400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  static const double _contentWidth = 322;

  static final BoxDecoration _cardDecoration = BoxDecoration(
    color: VoltaColors.surface,
    borderRadius: BorderRadius.circular(VoltaMetrics.historyCardRadius),
  );
}

class _TeamFormRow extends StatelessWidget {
  const _TeamFormRow({required this.form, required this.color});

  final VoltaTeamForm form;
  final Color color;

  static const double height = 40;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        SizedBox(width: height, height: height, child: _logo()),
        const SizedBox(width: 19),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Flexible(
                child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Flexible(
                    child: Text(
                      form.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelXSmall(color: color),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          'W ${form.wins}',
                          style: AppTextStyles.labelXSmall(color: color),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'L ${form.losses}',
                          style: AppTextStyles.labelXSmall(color: color),
                        ),
                      ],
                    ),
                  ),
                ],
                ),
              ),
              const SizedBox(height: 6),
              _FormBadges(results: form.results),
            ],
          ),
        ),
      ],
    );
  }

  Widget _logo() => VoltaTeamLogo(url: form.logoUrl, size: 40);
}

class _FormBadges extends StatelessWidget {
  const _FormBadges({required this.results});

  final List<bool> results;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          for (final won in results.take(VoltaRules.vsCells))
            won ? VoltaIcons.win(size: 16) : VoltaIcons.lose(size: 16),
        ],
      ),
    );
  }
}

class _VsDivider extends StatelessWidget {
  const _VsDivider();

  static const double height = 18;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        children: <Widget>[
          const Expanded(child: _FadedLine(fadeLeft: true)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'VS',
              style: AppTextStyles.labelXSmall(color: VoltaColors.vsLabel),
            ),
          ),
          const Expanded(child: _FadedLine(fadeLeft: false)),
        ],
      ),
    );
  }
}

class _FadedLine extends StatelessWidget {
  const _FadedLine({required this.fadeLeft});

  final bool fadeLeft;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: fadeLeft ? Alignment.centerLeft : Alignment.centerRight,
            end: fadeLeft ? Alignment.centerRight : Alignment.centerLeft,
            colors: const <Color>[
              Color(0x00565552),
              VoltaColors.vsLabel,
            ],
          ),
        ),
      ),
    );
  }
}
