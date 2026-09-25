import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sun_sports/core/utils/styles/app_text_styles.dart';

import '../../common/domain/volta_fairness.dart';
import '../../common/state/volta_state.dart';
import '../../common/state/volta_state_provider.dart';
import '../../common/volta_colors.dart';
import '../../common/volta_feedback.dart';
import '../../common/volta_layout_spec.dart';
import '../../common/volta_icons.dart';
import '../../common/volta_metrics.dart';

const double _kGap = 3;

class VoltaMd5Bar extends ConsumerWidget {
  const VoltaMd5Bar({
    required this.onOpenBetHistory,
    required this.onOpenRanking,
    required this.onOpenGuide,
    super.key,
  });

  final VoidCallback onOpenBetHistory;
  final VoidCallback onOpenRanking;
  final VoidCallback onOpenGuide;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final VoltaMd5View view =
        ref.watch(voltaStateProvider.select((s) => s.md5View));
    final String eventId = ref.watch(
      voltaStateProvider.select((s) => s.round?.eventId ?? ''),
    );
    final VoltaLayoutSpec spec = VoltaLayoutScope.of(context);
    final double icon = spec.md5ActionSize / 2;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: spec.gutter),
      child: SizedBox(
        height: spec.md5BlockHeight,
        child: Row(
          children: <Widget>[
            if (eventId.isNotEmpty) ...<Widget>[
              _MatchCode(eventId: eventId),
              const SizedBox(width: _kGap),
            ],
            Expanded(
              child: _Md5Field(view: view, height: spec.md5FieldHeight),
            ),
            const SizedBox(width: _kGap),
            _RoundAction(
              icon: VoltaIcons.history(size: icon),
              size: spec.md5ActionSize,
              onTap: onOpenBetHistory,
            ),
            const SizedBox(width: _kGap),
            _RoundAction(
              icon: VoltaIcons.ranking(size: icon),
              size: spec.md5ActionSize,
              onTap: onOpenRanking,
            ),
            const SizedBox(width: _kGap),
            _RoundAction(
              icon: VoltaIcons.guide(size: icon),
              size: spec.md5ActionSize,
              onTap: onOpenGuide,
            ),
          ],
        ),
      ),
    );
  }
}

class _MatchCode extends StatelessWidget {
  const _MatchCode({required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: _decoration,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(2, 5, 3, 5),
        child: Text(
          '#$eventId',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.textStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: VoltaColors.contentTertiary,
          ),
        ),
      ),
    );
  }

  static final BoxDecoration _decoration = BoxDecoration(
    color: Colors.black,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(
      color: const Color(0xFFFFFEF5).withAlpha(60),
      width: 0.5,
    ),
  );
}

class _Md5Field extends StatelessWidget {
  const _Md5Field({required this.view, required this.height});

  final VoltaMd5View view;
  final double height;

  @override
  Widget build(BuildContext context) {
    final String? code = view.code;

    return Row(
      children: <Widget>[
        Flexible(
          child: Container(
            height: height,
            padding: const EdgeInsets.only(left: 12, right: 3),
            decoration: _fieldDecoration,
            child: Row(
              children: <Widget>[
                Text(view.label, style: _labelStyle),
                const SizedBox(width: 5),
                Text('|', style: _dividerStyle),
                const SizedBox(width: 5),
                Flexible(
                  child: Semantics(
                    label: '${view.label}: ${code ?? ''}',
                    child: ExcludeSemantics(
                      child: _TypingText(
                        text: code ?? '—',
                        style: _valueStyle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: _kGap),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: view.hasCode ? () => _copy(context, view) : null,
          child: VoltaIcons.copy(size: VoltaMetrics.md5CopySize),
        ),
      ],
    );
  }

  static Future<void> _copy(BuildContext context, VoltaMd5View view) async {
    await Clipboard.setData(ClipboardData(text: view.code!));
    unawaited(HapticFeedback.selectionClick());
    if (!context.mounted) return;
    final String? badge = VoltaFairness.badgeFor(view.verdict);
    VoltaFeedback.copied(
      context,
      badge == null ? view.copyMessage : '${view.copyMessage} · $badge',
    );
  }

  static final BoxDecoration _fieldDecoration = BoxDecoration(
    color: VoltaColors.md5Field,
    borderRadius: BorderRadius.circular(VoltaMetrics.md5FieldRadius),
    border: Border.all(color: VoltaColors.contentPrimary.withAlpha(40)),
  );

  static final TextStyle _labelStyle = AppTextStyles.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: VoltaColors.contentTertiary,
  );

  static final TextStyle _dividerStyle = AppTextStyles.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: VoltaColors.contentTertiary,
  );

  static final TextStyle _valueStyle = AppTextStyles.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: VoltaColors.contentTertiary,
  );
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({
    required this.icon,
    required this.size,
    required this.onTap,
  });

  final Widget icon;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: _decoration,
        child: icon,
      ),
    );
  }

  static final BoxDecoration _decoration = BoxDecoration(
    color: VoltaColors.surface,
    borderRadius: BorderRadius.circular(VoltaMetrics.md5ActionRadius),
  );
}

class _TypingText extends StatefulWidget {
  const _TypingText({required this.text, required this.style});

  static const bool enabled = true;

  final String text;
  final TextStyle style;

  @override
  State<_TypingText> createState() => _TypingTextState();
}

class _TypingTextState extends State<_TypingText>
    with SingleTickerProviderStateMixin {
  static const Duration _perChar = Duration(milliseconds: 20);
  static const Duration _minTotal = Duration(milliseconds: 200);
  static const Duration _maxTotal = Duration(milliseconds: 800);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _totalFor(widget.text),
  )..addListener(_onTick);

  int _shown = 0;

  static Duration _totalFor(String text) {
    final int raw = text.length * _perChar.inMilliseconds;
    final int capped = raw < _minTotal.inMilliseconds
        ? _minTotal.inMilliseconds
        : (raw > _maxTotal.inMilliseconds ? _maxTotal.inMilliseconds : raw);
    return Duration(milliseconds: capped);
  }

  @override
  void initState() {
    super.initState();
    _restart();
  }

  int get _visible => _TypingText.enabled
      ? voltaSafeCutIndex(widget.text, _shown)
      : widget.text.length;

  @override
  void didUpdateWidget(_TypingText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) _restart();
  }

  void _restart() {
    _shown = 0;
    if (!_TypingText.enabled) return;
    _controller
      ..duration = _totalFor(widget.text)
      ..forward(from: 0);
  }

  void _onTick() {
    final int length = widget.text.length;
    final int raw = (_controller.value * length).floor();
    final int next = raw < 0 ? 0 : (raw > length ? length : raw);
    if (next == _shown) return;
    setState(() => _shown = next);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onTick)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      widget.text.substring(0, _visible),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: widget.style,
      softWrap: false,
    );
  }
}

@visibleForTesting
int voltaSafeCutIndex(String text, int index) {
  if (index <= 0) return 0;
  if (index >= text.length) return text.length;
  final int unit = text.codeUnitAt(index);
  if (unit < 0xDC00 || unit > 0xDFFF) return index;
  final int previous = text.codeUnitAt(index - 1);
  final bool isPairStart = previous >= 0xD800 && previous <= 0xDBFF;
  return isPairStart ? index - 1 : index;
}
