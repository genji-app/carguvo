import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/widgets/cards/inner_shadow_card.dart';

import '../../common/state/volta_models.dart';
import '../../common/state/volta_state_provider.dart';
import '../../common/volta_colors.dart';
import '../../common/volta_feedback.dart';
import '../../common/volta_icons.dart';
import '../../common/volta_metrics.dart';
import '../../common/widgets/volta_team_logo.dart';

class VoltaResultsBoard extends ConsumerStatefulWidget {
  const VoltaResultsBoard({this.tablet = false, super.key});

  final bool tablet;

  @override
  ConsumerState<VoltaResultsBoard> createState() => _VoltaResultsBoardState();
}

class _VoltaResultsBoardState extends ConsumerState<VoltaResultsBoard> {
  final PageController _controller = PageController();
  int _page = 0;

  String? _anchor;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _reanchor(List<VoltaMatchResult> items) {
    final String? anchor = _anchor;
    if (anchor == null || anchor.isEmpty) return;
    final int at = items.indexWhere((VoltaMatchResult r) => r.md5Code == anchor);
    if (at < 0 || at == _page) return;
    _page = at;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _controller.hasClients) _controller.jumpToPage(at);
    });
  }

  void _goTo(List<VoltaMatchResult> items, int next) {
    if (next < 0 || next >= items.length) return;
    setState(() {
      _page = next;
      _anchor = items[next].md5Code;
    });
    _controller.animateToPage(
      next,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  Widget _arrow(IconData icon, bool enabled, VoidCallback onTap) {
    final Widget art = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Icon(
        icon,
        size: 20,
        color: enabled
            ? VoltaColors.yellow300
            : VoltaColors.contentTertiary.withAlpha(90),
      ),
    );
    if (!enabled) return art;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: art,
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<VoltaMatchResult> list = ref.watch(
      voltaStateProvider.select((s) => s.results),
    );
    final VoltaMatchResult? fallback = ref.watch(
      voltaStateProvider.select((s) => s.lastResult),
    );
    final List<VoltaMatchResult> items = list.isNotEmpty
        ? list
        : <VoltaMatchResult>[if (fallback != null) fallback];

    _reanchor(items);
    final int page = items.isEmpty ? 0 : _page.clamp(0, items.length - 1);
    if (page < items.length) _anchor = items[page].md5Code;

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 6),
      child: InnerShadowCard(
        borderRadius: VoltaMetrics.historyCardRadius,
        color: VoltaColors.surface,
        child: items.isEmpty
            ? Center(
                child: Text(
                  'Chưa có kết quả ván nào',
                  style: AppTextStyles.labelXSmall(
                    color: VoltaColors.contentTertiary,
                  ),
                ),
              )
            : Row(
                children: <Widget>[
                  _arrow(
                    Icons.chevron_left,
                    page > 0,
                    () => _goTo(items, page - 1),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _controller,
                      itemCount: items.length,
                      onPageChanged: (int next) => setState(() {
                        _page = next;
                        _anchor = items[next].md5Code;
                      }),
                      itemBuilder: (BuildContext _, int i) => _ResultBody(
                        result: items[i],
                        tablet: widget.tablet,
                      ),
                    ),
                  ),
                  _arrow(
                    Icons.chevron_right,
                    page < items.length - 1,
                    () => _goTo(items, page + 1),
                  ),
                ],
              ),
      ),
    );
  }
}

class _ResultBody extends StatelessWidget {
  const _ResultBody({required this.result, required this.tablet});

  final VoltaMatchResult result;

  final bool tablet;

  static const double _contentWidth = 304;

  static const double _logoSize = 25;
  static const double _rowHeight = 16;
  static const double _gapAfterLogos = 2;
  static const double _gapBetweenRows = 6;

  static const double _contentHeight =
      _logoSize +
      _gapAfterLogos +
      _rowHeight +
      _gapBetweenRows +
      _rowHeight +
      _gapBetweenRows +
      _rowHeight;

  @override
  Widget build(BuildContext context) {
    if (tablet) return _tabletBody();

    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(
          width: _contentWidth,
          height: _contentHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _logosAndTime(),
              const SizedBox(height: _gapAfterLogos),
              _teamsRow(),
              const SizedBox(height: _gapBetweenRows),
              _codeRow('Mã MD5', result.md5Code),
              const SizedBox(height: _gapBetweenRows),
              _codeRow('Mã Kết quả', result.resultCode),
            ],
          ),
        ),
      ),
    );
  }

  static const double _tContentWidth = 444.8;

  static const double _tHeadWidth = 385;
  static const double _tLogoSize = 32;

  static const double _tTeamRowHeight = 40;

  static const double _tNameWidth = 129;
  static const double _tNamePadX = 10;
  static const double _tBadgeSize = 20;

  static const double _tBadgeGap = 11;

  static const double _tLabelColWidth = 96.2;
  static const double _tLabelHeight = 20;
  static const double _tLabelGap = 14;

  static const double _tCodesGap = 9;

  static const double _tFieldGap = 7.8;
  static const double _tFieldWidth = 314.5;
  static const double _tFieldHeight = 26;
  static const double _tFieldRadius = 10.4;

  static const double _tFieldPadX = 24.61;

  static const double _tCopyGap = 9.1;
  static const double _tCopySize = 16;

  Widget _tabletBody() {
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(
        width: _tContentWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              width: _tHeadWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[_tLogosAndTime(), _tTeamsRow()],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  width: _tLabelColWidth,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      _tLabel('Mã MD5'),
                      const SizedBox(height: _tLabelGap),
                      _tLabel('Mã Kết quả'),
                    ],
                  ),
                ),
                const SizedBox(width: _tCodesGap),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _tCodeRow(result.md5Code),
                    const SizedBox(height: _tFieldGap),
                    _tCodeRow(result.resultCode),
                  ],
                ),
              ],
            ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _tLogosAndTime() => SizedBox(
    height: _tLogoSize,
    child: Row(
      children: <Widget>[
        SizedBox(
          width: _tNameWidth,
          child: Center(
            child: VoltaTeamLogo(url: result.homeLogo, size: _tLogoSize),
          ),
        ),
        Expanded(
          child: Center(
            child: Text(
              _timeOfDay(result.finishedAt),
              maxLines: 1,
              style: AppTextStyles.headingXSmall(
                color: VoltaColors.contentSecondary,
              ).copyWith(height: 24 / 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        SizedBox(
          width: _tNameWidth,
          child: Center(
            child: VoltaTeamLogo(url: result.awayLogo, size: _tLogoSize),
          ),
        ),
      ],
    ),
  );

  Widget _tTeamsRow() => SizedBox(
    height: _tTeamRowHeight,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        _tTeamGroup(
          name: result.homeName,
          color: VoltaColors.red400,
          won: result.winner == VoltaWinner.home,
          iconTrailing: true,
        ),
        _tTeamGroup(
          name: result.awayName,
          color: VoltaColors.yellow400,
          won: result.winner == VoltaWinner.away,
          iconTrailing: false,
        ),
      ],
    ),
  );

  Widget _tTeamGroup({
    required String name,
    required Color color,
    required bool won,
    required bool iconTrailing,
  }) {
    final Widget badge = won
        ? VoltaIcons.win(size: _tBadgeSize)
        : VoltaIcons.lose(size: _tBadgeSize);
    final Widget label = SizedBox(
      width: _tNameWidth,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: _tNamePadX),
        child: Text(
          name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: AppTextStyles.labelSmall(color: color),
        ),
      ),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: iconTrailing
          ? <Widget>[label, const SizedBox(width: _tBadgeGap), badge]
          : <Widget>[badge, const SizedBox(width: _tBadgeGap), label],
    );
  }

  Widget _tLabel(String text) => SizedBox(
    height: _tLabelHeight,
    width: double.infinity,
    child: Center(
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.labelSmall(color: VoltaColors.contentTertiary),
      ),
    ),
  );

  Widget _tCodeRow(String code) => Row(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      Container(
        width: _tFieldWidth,
        height: _tFieldHeight,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: _tFieldPadX),
        decoration: _tFieldDecoration,
        child: Text(
          code.isEmpty ? '—' : code,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.paragraphXSmall(
            color: VoltaColors.contentTertiary,
          ).copyWith(fontWeight: FontWeight.w500),
        ),
      ),
      const SizedBox(width: _tCopyGap),
      _CopyButton(code: code, size: _tCopySize),
    ],
  );

  static final BoxDecoration _tFieldDecoration = BoxDecoration(
    color: VoltaColors.codeField,
    borderRadius: BorderRadius.circular(_tFieldRadius),
    border: Border.all(color: VoltaColors.codeFieldBorder, width: 0.5),
  );

  Widget _logosAndTime() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _logo(result.homeLogo),
        const SizedBox(width: 24),
        Text(
          _timeOfDay(result.finishedAt),
          style: AppTextStyles.labelSmall(color: VoltaColors.contentSecondary),
        ),
        const SizedBox(width: 24),
        _logo(result.awayLogo),
      ],
    );
  }

  Widget _teamsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Flexible(
          child: _teamChip(
            name: result.homeName,
            color: VoltaColors.red400,
            won: result.winner == VoltaWinner.home,
            iconTrailing: true,
          ),
        ),
        Flexible(
          child: _teamChip(
            name: result.awayName,
            color: VoltaColors.yellow400,
            won: result.winner == VoltaWinner.away,
            iconTrailing: false,
          ),
        ),
      ],
    );
  }

  Widget _teamChip({
    required String name,
    required Color color,
    required bool won,
    required bool iconTrailing,
  }) {
    final Widget badge = won ? VoltaIcons.win(size: 16) : VoltaIcons.lose(size: 16);
    final Widget label = Flexible(
      child: Text(
        name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: AppTextStyles.labelXXSmall(color: color),
      ),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: iconTrailing
          ? <Widget>[label, const SizedBox(width: 6), badge]
          : <Widget>[badge, const SizedBox(width: 6), label],
    );
  }

  Widget _codeRow(String label, String code) {
    return Row(
      children: <Widget>[
        SizedBox(
          width: 74,
          child: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelXXSmall(
                color: VoltaColors.contentTertiary,
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 16,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: _fieldDecoration,
            child: Text(
              code.isEmpty ? '—' : code,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.inter(
                fontSize: 8,
                fontWeight: FontWeight.w500,
                color: VoltaColors.contentTertiary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 7),
        _CopyButton(code: code),
      ],
    );
  }

  Widget _logo(String? url) => VoltaTeamLogo(url: url, size: _logoSize);

  static String _timeOfDay(DateTime at) {
    final int hour12 = at.hour % 12 == 0 ? 12 : at.hour % 12;
    final String minute = at.minute.toString().padLeft(2, '0');
    final String meridiem = at.hour < 12 ? 'AM' : 'PM';
    return '$hour12:$minute $meridiem';
  }

  static final BoxDecoration _fieldDecoration = BoxDecoration(
    color: VoltaColors.codeField,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: VoltaColors.codeFieldBorder, width: 0.5),
  );
}

class _CopyButton extends StatelessWidget {
  const _CopyButton({required this.code, this.size = 16});

  final String code;

  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: code.isEmpty ? null : () => unawaited(_copy(context)),
      child: VoltaIcons.copy(size: size),
    );
  }

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: code));
    await HapticFeedback.selectionClick();
    if (!context.mounted) return;
    VoltaFeedback.copied(context, 'Đã sao chép mã kết quả');
  }
}
