library;

import 'package:betting_domain/betting_domain.dart' show H2hResult, HeadToHead;
import 'package:flutter/material.dart';
import 'package:app_package/core/utils/styles/app_color.dart';
import 'package:app_package/core/utils/styles/app_color_styles.dart';
import 'package:app_package/core/utils/styles/app_text_styles.dart';

class BdH2hPanelMobile extends StatelessWidget {
  const BdH2hPanelMobile({
    required this.data,
    required this.homeName,
    required this.awayName,
    super.key,
  });

  final HeadToHead data;
  final String homeName;
  final String awayName;

  static const Color _drawColor = Color(0xFF565552);
  static const Color _awayColor = Color(0xFF8FB5FF);
  static const Color _winColor = Color(0xFF86CB3C);
  static const Color _lossColor = Color(0xFFF97066);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Đối đầu · ${data.meetings} lần gặp nhau',
          style: AppTextStyles.labelXSmall(
            context: context,
            color: AppColorStyles.contentSecondary,
          ),
        ),
        const SizedBox(height: 10),
        _bar(),
        const SizedBox(height: 10),
        _barLegend(context),
        const SizedBox(height: 10),
        Container(height: 1, color: const Color.fromRGBO(255, 255, 255, 0.06)),
        const SizedBox(height: 10),
        _formRow(context, homeName, data.homeForm, data.homeWinCount),
        const SizedBox(height: 10),
        _formRow(context, awayName, data.awayForm, data.awayWinCount),
      ],
    ),
  );

  Widget _bar() => ClipRRect(
    borderRadius: BorderRadius.circular(999),
    child: SizedBox(
      height: 6,
      child: Row(
        children: [
          if (data.homeWins > 0)
            Expanded(flex: data.homeWins, child: const ColoredBox(
              color: AppColors.orange400,
              child: SizedBox.expand(),
            )),
          if (data.draws > 0)
            Expanded(flex: data.draws, child: const ColoredBox(
              color: _drawColor,
              child: SizedBox.expand(),
            )),
          if (data.awayWins > 0)
            Expanded(flex: data.awayWins, child: const ColoredBox(
              color: _awayColor,
              child: SizedBox.expand(),
            )),
        ],
      ),
    ),
  );

  Widget _barLegend(BuildContext context) => Row(
    children: [
      Expanded(child: _legendItem(context, '${data.homeWins}', homeName,
          alignEnd: false)),
      Text(
        '${data.draws} hoà',
        style: AppTextStyles.paragraphXXSmall(
          context: context,
          color: AppColorStyles.contentSecondary,
        ),
      ),
      Expanded(child: _legendItem(context, '${data.awayWins}', awayName,
          alignEnd: true)),
    ],
  );

  static Widget _legendItem(
    BuildContext context,
    String count,
    String name, {
    required bool alignEnd,
  }) {
    final countText = Text(
      count,
      style: AppTextStyles.labelXXSmall(
        context: context,
        color: AppColorStyles.contentPrimary,
      ),
    );
    final nameText = Flexible(
      child: Text(
        name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.paragraphXXSmall(
          context: context,
          color: AppColorStyles.contentSecondary,
        ),
      ),
    );
    return Row(
      mainAxisAlignment:
          alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: alignEnd
          ? [nameText, const SizedBox(width: 6), countText]
          : [countText, const SizedBox(width: 6), nameText],
    );
  }

  Widget _formRow(
    BuildContext context,
    String name,
    List<H2hResult> form,
    int wins,
  ) => Row(
    children: [
      Expanded(
        child: Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.labelXSmall(
            context: context,
            color: AppColorStyles.contentPrimary,
          ),
        ),
      ),
      if (form.isEmpty)
        Text(
          'Chưa có dữ liệu',
          style: AppTextStyles.paragraphXXSmall(
            context: context,
            color: AppColorStyles.contentTertiary,
          ),
        )
      else ...[
        for (final r in form) ...[_pip(context, r), const SizedBox(width: 4)],
        const SizedBox(width: 4),
        SizedBox(
          width: 30,
          child: Text(
            '$wins/${form.length}',
            textAlign: TextAlign.right,
            style: AppTextStyles.paragraphXXSmall(
              context: context,
              color: AppColorStyles.contentSecondary,
            ),
          ),
        ),
      ],
    ],
  );

  static Widget _pip(BuildContext context, H2hResult r) {
    final (bg, fg) = switch (r) {
      H2hResult.win => (_winColor, const Color(0xFF0C0C0C)),
      H2hResult.draw => (_drawColor, const Color(0xFFE8E7E0)),
      H2hResult.loss => (_lossColor, const Color(0xFF0C0C0C)),
    };
    return Container(
      width: 19,
      height: 19,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Text(
        r.label,
        style: AppTextStyles.labelXXSmall(context: context, color: fg),
      ),
    );
  }
}
