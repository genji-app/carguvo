import 'dart:math' as math;

import 'package:flutter/foundation.dart'
    show ValueListenable, ValueNotifier, debugPrint;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/core/utils/styles/mini_game_icons.dart';
import 'package:sun_sports/features/mini_game/presentation/state/tai_xiu_state_provider.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

import 'tai_xiu_sub_view_scaffold.dart';

class SessionHistoryView extends ConsumerStatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onClose;

  const SessionHistoryView({
    required this.onBack,
    required this.onClose,
    super.key,
  });

  @override
  ConsumerState<SessionHistoryView> createState() => _SessionHistoryViewState();
}

class _SessionHistoryViewState extends ConsumerState<SessionHistoryView> {
  bool _showRoad = false;

  void _openRoad() => setState(() => _showRoad = true);
  void _closeRoad() => setState(() => _showRoad = false);

  @override
  Widget build(BuildContext context) {
    final sessions = ref
        .watch(taiXiuSocketStateProvider)
        .sessionHistory
        .map((item) => _Session([item.d1, item.d2, item.d3], item.sessionId))
        .toList(growable: false);

    return TaiXiuSubViewScaffold(
      title: TaiXiuSubView.sessionHistory.title,
      onBack: _showRoad ? _closeRoad : widget.onBack,
      onClose: widget.onClose,
      child: sessions.isEmpty
          ? const Center(
              child: Text(
                'Chưa có lịch sử phiên',
                style: TextStyle(color: AppColorStyles.contentSecondary),
              ),
            )
          : _showRoad
          ? _RoadBody(sessions: sessions)
          : _SessionHistoryBody(sessions: sessions, onMore: _openRoad),
    );
  }
}

class _Session {
  final List<int> dice;

  final int? sessionId;

  const _Session(this.dice, [this.sessionId]);

  int get sum => dice[0] + dice[1] + dice[2];

  bool get isTai => sum >= 11;
}

const double _kAxisWidth = 20;
const double _kAxisGap = 8;

const double _kPlotInsetV = 14;

const double _kPlotPadH = 16;

const double _kMinPointSpacing = 20;

const List<Color> _kDiceColors = [
  AppColors.green400,
  Color(0xFFFF75ED),
  AppColors.blue500,
];

const List<String> _kDiceLabels = ['Xí ngầu 1', 'Xí ngầu 2', 'Xí ngầu 3'];

ScrollBehavior _dragScrollBehavior(BuildContext context) =>
    ScrollConfiguration.of(
      context,
    ).copyWith(dragDevices: PointerDeviceKind.values.toSet());

class _SessionHistoryBody extends StatefulWidget {
  final List<_Session> sessions;

  final VoidCallback onMore;

  const _SessionHistoryBody({required this.sessions, required this.onMore});

  @override
  State<_SessionHistoryBody> createState() => _SessionHistoryBodyState();
}

class _SessionHistoryBodyState extends State<_SessionHistoryBody> {
  final List<bool> _diceVisible = [true, true, true];
  final ScrollController _sumChartScrollController = ScrollController();
  final ScrollController _diceChartScrollController = ScrollController();
  bool _isSyncingChartScroll = false;

  @override
  void initState() {
    super.initState();
    _sumChartScrollController.addListener(
      () => _syncChartScroll(
        source: _sumChartScrollController,
        target: _diceChartScrollController,
      ),
    );
    _diceChartScrollController.addListener(
      () => _syncChartScroll(
        source: _diceChartScrollController,
        target: _sumChartScrollController,
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _jumpChartsToLatest(),
    );
  }

  @override
  void dispose() {
    _sumChartScrollController.dispose();
    _diceChartScrollController.dispose();
    super.dispose();
  }

  void _toggleDice(int index) =>
      setState(() => _diceVisible[index] = !_diceVisible[index]);

  void _syncChartScroll({
    required ScrollController source,
    required ScrollController target,
  }) {
    if (_isSyncingChartScroll || !source.hasClients || !target.hasClients) {
      return;
    }
    final offset = source.offset.clamp(0.0, target.position.maxScrollExtent);
    if ((target.offset - offset).abs() < 0.5) return;

    _isSyncingChartScroll = true;
    target.jumpTo(offset);
    _isSyncingChartScroll = false;
  }

  void _jumpChartsToLatest() {
    if (!mounted) return;
    for (final controller in [
      _sumChartScrollController,
      _diceChartScrollController,
    ]) {
      if (!controller.hasClients) continue;
      final maxExtent = controller.position.maxScrollExtent;
      if (maxExtent <= 0) continue;
      controller.jumpTo(maxExtent);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessions = widget.sessions;
    return ScrollConfiguration(
      behavior: _dragScrollBehavior(context),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Gap(12),
            _LatestSessionBand(session: sessions.last),
            const Gap(20),
            _SumChart(
              sessions: sessions,
              scrollController: _sumChartScrollController,
            ),
            const Gap(20),
            _DiceChart(
              sessions: sessions,
              visible: _diceVisible,
              scrollController: _diceChartScrollController,
            ),
            const Gap(16),
            _DiceLegend(visible: _diceVisible, onToggle: _toggleDice),
            const Gap(16),
            _LoadMoreButton(onTap: widget.onMore),
            const Gap(12),
          ],
        ),
      ),
    );
  }
}

class _LatestSessionBand extends StatelessWidget {
  final _Session session;

  const _LatestSessionBand({required this.session});

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyles.textStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 20 / 14,
      color: AppColorStyles.contentPrimary,
    );
    final resultPrefix = '${session.dice.join(', ')} - ';
    final resultLabel = session.isTai ? 'Tài' : 'Xỉu';
    final label = session.sessionId != null
        ? 'Phiên gần nhất: #${session.sessionId}'
        : 'Phiên gần nhất:';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: AppColorStyles.backgroundSecondary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: style),
            Text.rich(
              TextSpan(
                text: resultPrefix,
                children: [
                  TextSpan(
                    text: resultLabel,
                    style: TextStyle(color: _taiXiuTextColor(session.isTai)),
                  ),
                ],
              ),
              style: style,
            ),
          ],
        ),
      ),
    );
  }
}

class _SumChart extends StatelessWidget {
  final List<_Session> sessions;
  final ScrollController scrollController;

  const _SumChart({required this.sessions, required this.scrollController});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    child: SizedBox(
      height: 150,
      child: _LineChart(
        axisLabels: const [18, 15, 12, 9, 6, 3],
        minValue: 3,
        maxValue: 18,
        scrollController: scrollController,
        series: [
          _ChartSeries(
            values: [for (final s in sessions) s.sum],
            color: AppColorStyles.contentTertiary,
          ),
        ],
        markerBuilder: (context, index) => _SumMarker(session: sessions[index]),
      ),
    ),
  );
}

class _SumMarker extends StatelessWidget {
  final _Session session;

  const _SumMarker({required this.session});

  @override
  Widget build(BuildContext context) => Stack(
    alignment: Alignment.center,
    children: [
      ImageHelper.load(
        path: session.isTai
            ? MiniGameIcons.txTaiCircle
            : MiniGameIcons.txXiuCircle,
        width: 20,
        height: 20,
        fit: BoxFit.fill,
      ),
      Text(
        '${session.sum}',
        style: AppTextStyles.textStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          height: 1,
          color: Colors.white,
        ),
      ),
    ],
  );
}

class _DiceChart extends StatelessWidget {
  final List<_Session> sessions;
  final List<bool> visible;
  final ScrollController scrollController;

  const _DiceChart({
    required this.sessions,
    required this.visible,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    child: SizedBox(
      height: 160,
      child: _LineChart(
        axisLabels: const [6, 5, 4, 3, 2, 1],
        minValue: 1,
        maxValue: 6,
        scrollController: scrollController,
        series: [
          for (var i = 0; i < 3; i++)
            _ChartSeries(
              values: [for (final s in sessions) s.dice[i]],
              color: _kDiceColors[i],
              visible: visible[i],
              drawDots: true,
            ),
        ],
      ),
    ),
  );
}

class _DiceLegend extends StatelessWidget {
  final List<bool> visible;
  final ValueChanged<int> onToggle;

  const _DiceLegend({required this.visible, required this.onToggle});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      for (var i = 0; i < 3; i++) ...[
        if (i > 0) const Gap(12),
        _DiceLegendButton(
          label: _kDiceLabels[i],
          color: _kDiceColors[i],
          enabled: visible[i],
          onTap: () => onToggle(i),
        ),
      ],
    ],
  );
}

class _DiceLegendButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool enabled;
  final VoidCallback onTap;

  const _DiceLegendButton({
    required this.label,
    required this.color,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = enabled ? color : AppColorStyles.borderPrimary;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: SoundTap.wrap(onTap),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColorStyles.backgroundTertiary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: accent),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const Gap(6),
              Text(
                label,
                style: AppTextStyles.textStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  height: 18 / 12,
                  color: enabled
                      ? AppColorStyles.contentSecondary
                      : AppColorStyles.contentTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadMoreButton extends StatelessWidget {
  final VoidCallback onTap;

  const _LoadMoreButton({required this.onTap});

  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor: SystemMouseCursors.click,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: SoundTap.wrap(onTap),
      child: Container(
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColorStyles.backgroundQuaternary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColorStyles.borderPrimary, width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Xem thêm',
              style: AppTextStyles.textStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                height: 20 / 14,
                color: AppColorStyles.contentPrimary,
              ),
            ),
            const Gap(6),
            const Icon(
              Icons.chevron_right_rounded,
              size: 16,
              color: AppColorStyles.contentPrimary,
            ),
          ],
        ),
      ),
    ),
  );
}

class _ChartSeries {
  final List<num> values;
  final Color color;
  final bool visible;

  final bool drawDots;

  const _ChartSeries({
    required this.values,
    required this.color,
    this.visible = true,
    this.drawDots = false,
  });
}

class _LineChart extends StatelessWidget {
  final List<num> axisLabels;
  final double minValue;
  final double maxValue;
  final List<_ChartSeries> series;
  final IndexedWidgetBuilder? markerBuilder;
  final ScrollController scrollController;

  const _LineChart({
    required this.axisLabels,
    required this.minValue,
    required this.maxValue,
    required this.series,
    required this.scrollController,
    this.markerBuilder,
  });

  int get _pointCount => series.fold(0, (m, s) => math.max(m, s.values.length));

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final height = constraints.maxHeight;
      final plotViewport = constraints.maxWidth - _kAxisWidth - _kAxisGap;
      final n = _pointCount;
      final neededWidth = n <= 1
          ? plotViewport
          : _kPlotPadH * 2 + (n - 1) * _kMinPointSpacing;
      final contentWidth = math.max(plotViewport, neededWidth);

      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _YAxisLabels(labels: axisLabels, height: height),
          const Gap(_kAxisGap),
          Expanded(
            child: ScrollConfiguration(
              behavior: _dragScrollBehavior(context),
              child: SingleChildScrollView(
                controller: scrollController,
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: contentWidth,
                  height: height,
                  child: _ChartPlot(
                    minValue: minValue,
                    maxValue: maxValue,
                    levelCount: axisLabels.length,
                    series: series,
                    markerBuilder: markerBuilder,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}

class _YAxisLabels extends StatelessWidget {
  final List<num> labels;
  final double height;

  const _YAxisLabels({required this.labels, required this.height});

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyles.textStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 20 / 14,
      color: AppColorStyles.contentSecondary,
    );
    final plotTop = _kPlotInsetV;
    final plotBottom = height - _kPlotInsetV;
    final count = labels.length;
    return SizedBox(
      width: _kAxisWidth,
      height: height,
      child: Stack(
        children: [
          for (var i = 0; i < count; i++)
            Positioned(
              left: 0,
              width: _kAxisWidth,
              top:
                  plotTop +
                  (count <= 1 ? 0.0 : i / (count - 1)) *
                      (plotBottom - plotTop) -
                  10,
              child: Text(
                '${labels[i]}',
                textAlign: TextAlign.right,
                style: style,
              ),
            ),
        ],
      ),
    );
  }
}

class _ChartPlot extends StatelessWidget {
  final double minValue;
  final double maxValue;
  final int levelCount;
  final List<_ChartSeries> series;
  final IndexedWidgetBuilder? markerBuilder;

  const _ChartPlot({
    required this.minValue,
    required this.maxValue,
    required this.levelCount,
    required this.series,
    this.markerBuilder,
  });

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final size = Size(constraints.maxWidth, constraints.maxHeight);
      final geo = _ChartGeometry(
        size: size,
        minValue: minValue,
        maxValue: maxValue,
      );
      final markerSeries = series.isNotEmpty ? series.first : null;
      return Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _LineChartPainter(
                levelCount: levelCount,
                series: series,
                geo: geo,
              ),
            ),
          ),
          if (markerBuilder != null && markerSeries != null)
            for (var i = 0; i < markerSeries.values.length; i++)
              Positioned(
                left: geo.x(i, markerSeries.values.length) - 10,
                top: geo.y(markerSeries.values[i]) - 10,
                width: 20,
                height: 20,
                child: markerBuilder!(context, i),
              ),
        ],
      );
    },
  );
}

class _ChartGeometry {
  final Size size;
  final double minValue;
  final double maxValue;

  const _ChartGeometry({
    required this.size,
    required this.minValue,
    required this.maxValue,
  });

  double get _plotTop => _kPlotInsetV;
  double get _plotBottom => size.height - _kPlotInsetV;
  double get _plotLeft => _kPlotPadH;
  double get _plotRight => size.width - _kPlotPadH;

  double levelY(int i, int count) {
    final f = count <= 1 ? 0.0 : i / (count - 1);
    return _plotTop + f * (_plotBottom - _plotTop);
  }

  double x(int i, int n) {
    if (n <= 1) return (_plotLeft + _plotRight) / 2;
    return _plotLeft + i * (_plotRight - _plotLeft) / (n - 1);
  }

  double y(num v) {
    final f = (v - minValue) / (maxValue - minValue);
    return _plotBottom - f * (_plotBottom - _plotTop);
  }
}

class _LineChartPainter extends CustomPainter {
  final int levelCount;
  final List<_ChartSeries> series;
  final _ChartGeometry geo;

  const _LineChartPainter({
    required this.levelCount,
    required this.series,
    required this.geo,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppColorStyles.borderPrimary
      ..strokeWidth = 0.5;
    for (var i = 0; i < levelCount; i++) {
      final y = geo.levelY(i, levelCount);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    for (final s in series) {
      if (!s.visible || s.values.isEmpty) continue;
      final n = s.values.length;
      final points = [
        for (var i = 0; i < n; i++) Offset(geo.x(i, n), geo.y(s.values[i])),
      ];

      final linePaint = Paint()
        ..color = s.color
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;
      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (var i = 1; i < n; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      canvas.drawPath(path, linePaint);

      if (s.drawDots) {
        final dotPaint = Paint()..color = s.color;
        for (final p in points) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(center: p, width: 12, height: 12),
              const Radius.circular(4),
            ),
            dotPaint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(_LineChartPainter old) =>
      old.series != series ||
      old.levelCount != levelCount ||
      old.geo.size != geo.size;
}

class _Bead {
  final int index;
  final bool isTai;
  final int? number;

  const _Bead({required this.index, required this.isTai, this.number});
}

class _RoadBody extends StatefulWidget {
  final List<_Session> sessions;

  const _RoadBody({required this.sessions});

  @override
  State<_RoadBody> createState() => _RoadBodyState();
}

class _RoadBodyState extends State<_RoadBody> {
  final ScrollController _topRoadScrollController = ScrollController();
  final ScrollController _bottomRoadScrollController = ScrollController();
  final ValueNotifier<Set<int>> _visibleRoadBeadIndexes = ValueNotifier(
    const {},
  );
  List<_Bead> _topBeads = const [];
  List<_Bead> _bottomBeads = const [];
  _RoadLayout _topRoadLayout = const _RoadLayout(0, {});
  _ColRange? _visibleRoadColRange;
  int? _bottomRoadTargetCol;

  @override
  void initState() {
    super.initState();
    _refreshRoadData();
    _topRoadScrollController.addListener(_handleTopRoadScroll);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _updateVisibleRoadBeadIndexes(),
    );
  }

  @override
  void didUpdateWidget(_RoadBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_sameSessions(oldWidget.sessions, widget.sessions)) {
      _refreshRoadData();
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _updateVisibleRoadBeadIndexes(),
      );
    }
  }

  @override
  void dispose() {
    _visibleRoadBeadIndexes.dispose();
    _topRoadScrollController.dispose();
    _bottomRoadScrollController.dispose();
    super.dispose();
  }

  void _refreshRoadData() {
    _topBeads = _beadsOf(withNumber: true);
    _bottomBeads = _latestBeadsOf(limit: _RecentRoadGrid.cellCount);
    _topRoadLayout = _layoutRoad(_topBeads, _RoadGrid.rows);
    _visibleRoadColRange = null;
    _bottomRoadTargetCol = null;
    _visibleRoadBeadIndexes.value = const {};
  }

  List<_Bead> _beadsOf({required bool withNumber}) => [
    for (var i = 0; i < widget.sessions.length; i++)
      _Bead(
        index: i,
        isTai: widget.sessions[i].isTai,
        number: withNumber ? widget.sessions[i].sum : null,
      ),
  ];

  List<_Bead> _latestBeadsOf({required int limit}) {
    final sessions = widget.sessions;
    final recent = sessions.length <= limit
        ? sessions
        : sessions.sublist(sessions.length - limit);
    final startIndex = sessions.length - recent.length;
    return [
      for (var i = 0; i < recent.length; i++)
        _Bead(index: startIndex + i, isTai: recent[i].isTai),
    ];
  }

  void _handleTopRoadScroll() {
    _updateVisibleRoadBeadIndexes();
  }

  void _updateVisibleRoadBeadIndexes() {
    if (!_topRoadScrollController.hasClients || !mounted) {
      return;
    }

    final offset = _topRoadScrollController.offset;
    final viewportWidth = _topRoadScrollController.position.viewportDimension;
    final colRange = _RoadLayout.visibleColRange(
      offset: offset,
      viewportWidth: viewportWidth,
      cellSize: _RoadGrid.numberedCell,
    );
    if (colRange == _visibleRoadColRange) return;
    _visibleRoadColRange = colRange;

    final visible = _topRoadLayout.visibleBeadIndexes(colRange: colRange);
    if (_setEquals(_visibleRoadBeadIndexes.value, visible)) return;
    debugPrint(
      '[TX_HISTORY_HIGHLIGHT] update: '
      'cols=${colRange.first}-${colRange.last} '
      'offset=${offset.toStringAsFixed(1)} '
      'viewport=${viewportWidth.toStringAsFixed(1)} '
      'count=${visible.length} indexes=${visible.toList()..sort()}',
    );
    _visibleRoadBeadIndexes.value = visible;
    _scrollBottomRoadToHighlighted(visible);
  }

  void _scrollBottomRoadToHighlighted(Set<int> highlightedIndexes) {
    if (!_bottomRoadScrollController.hasClients || highlightedIndexes.isEmpty) {
      return;
    }

    final firstHighlightedPosition = _bottomBeads.indexWhere(
      (bead) => highlightedIndexes.contains(bead.index),
    );
    if (firstHighlightedPosition < 0) return;

    final leadingEmptyCells = math.max(
      0,
      _RecentRoadGrid.cellCount - _bottomBeads.length,
    );
    final cellIndex = leadingEmptyCells + firstHighlightedPosition;
    final targetCol = cellIndex ~/ _RecentRoadGrid.rows;
    if (targetCol == _bottomRoadTargetCol) return;
    _bottomRoadTargetCol = targetCol;

    final targetOffset = (targetCol * _RecentRoadGrid.cellSize).clamp(
      0.0,
      _bottomRoadScrollController.position.maxScrollExtent,
    );
    _bottomRoadScrollController.jumpTo(targetOffset);
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: _dragScrollBehavior(context),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _CountBands(beads: _topBeads),
            const Gap(8),
            _RoadGrid(
              beads: _topBeads,
              layout: _topRoadLayout,
              withNumber: true,
              scrollController: _topRoadScrollController,
            ),
            const Gap(24),
            _CountBands(beads: _bottomBeads),
            const Gap(8),
            _RecentRoadGrid(
              beads: _bottomBeads,
              highlightedIndexes: _visibleRoadBeadIndexes,
              scrollController: _bottomRoadScrollController,
            ),
          ],
        ),
      ),
    );
  }
}

class _CountBands extends StatelessWidget {
  final List<_Bead> beads;

  const _CountBands({required this.beads});

  @override
  Widget build(BuildContext context) {
    final tai = beads.where((b) => b.isTai).length;
    final xiu = beads.length - tai;
    return Row(
      children: [
        Expanded(
          child: _CountPill(label: 'Tài', count: tai, isTai: true),
        ),
        const Gap(4),
        Expanded(
          child: _CountPill(label: 'Xỉu', count: xiu, isTai: false),
        ),
      ],
    );
  }
}

class _CountPill extends StatelessWidget {
  final String label;
  final int count;
  final bool isTai;

  const _CountPill({
    required this.label,
    required this.count,
    required this.isTai,
  });

  @override
  Widget build(BuildContext context) => Container(
    alignment: Alignment.center,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: BoxDecoration(
      color: !isTai ? AppColors.yellow900 : AppColorStyles.backgroundSecondary,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      '$label: $count',
      style: AppTextStyles.textStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 20 / 14,
        color: _taiXiuTextColor(isTai),
      ),
    ),
  );
}

Color _taiXiuTextColor(bool isTai) =>
    isTai ? AppColorStyles.contentPrimary : AppColors.yellow400;

class _RecentRoadGrid extends StatelessWidget {
  final List<_Bead> beads;
  final ValueListenable<Set<int>> highlightedIndexes;
  final ScrollController scrollController;

  const _RecentRoadGrid({
    required this.beads,
    required this.highlightedIndexes,
    required this.scrollController,
  });

  static const int rows = 5;
  static const int cols = 20;
  static const int cellCount = rows * cols;
  static const double cellSize = 24;
  static const double _marker = 14;

  @override
  Widget build(BuildContext context) {
    final leadingEmptyCells = math.max(0, cellCount - beads.length);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColorStyles.borderPrimary, width: 0.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: ScrollConfiguration(
          behavior: _dragScrollBehavior(context),
          child: SingleChildScrollView(
            controller: scrollController,
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: cols * cellSize,
              height: rows * cellSize,
              child: Column(
                children: [
                  for (var r = 0; r < rows; r++)
                    Row(
                      children: [
                        for (var c = 0; c < cols; c++)
                          ValueListenableBuilder<Set<int>>(
                            valueListenable: highlightedIndexes,
                            child: _RoadCellBox(
                              size: cellSize,
                              markerSize: _marker,
                              bead: _beadAt(c * rows + r, leadingEmptyCells),
                              isLastCol: c == cols - 1,
                              isLastRow: r == rows - 1,
                            ),
                            builder: (context, highlighted, child) {
                              final isHighlighted = _isHighlighted(
                                c * rows + r,
                                leadingEmptyCells,
                                highlighted,
                              );
                              return Opacity(
                                opacity: isHighlighted ? 1 : 0.35,
                                child: child,
                              );
                            },
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _Bead? _beadAt(int index, int leadingEmptyCells) {
    final beadIndex = index - leadingEmptyCells;
    if (beadIndex < 0 || beadIndex >= beads.length) return null;
    return beads[beadIndex];
  }

  bool _isHighlighted(
    int index,
    int leadingEmptyCells,
    Set<int> highlightedIndexes,
  ) {
    final bead = _beadAt(index, leadingEmptyCells);
    if (bead == null) return true;
    return highlightedIndexes.contains(bead.index);
  }
}

class _RoadGrid extends StatelessWidget {
  final List<_Bead> beads;
  final _RoadLayout? layout;
  final bool withNumber;
  final ScrollController? scrollController;

  const _RoadGrid({
    required this.beads,
    required this.withNumber,
    this.layout,
    this.scrollController,
  });

  static const int rows = 5;
  static const int _minCols = 20;
  static const double numberedCell = 28;

  double get _cell => withNumber ? numberedCell : 24;
  double get _marker => withNumber ? 22 : 14;

  @override
  Widget build(BuildContext context) {
    final placed = layout ?? _layoutRoad(beads, rows);
    final colCount = math.max(_minCols, placed.colCount);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColorStyles.borderPrimary, width: 0.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: ScrollConfiguration(
          behavior: _dragScrollBehavior(context),
          child: SingleChildScrollView(
            controller: scrollController,
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: colCount * _cell,
              height: rows * _cell,
              child: Column(
                children: [
                  for (var r = 0; r < rows; r++)
                    Row(
                      children: [
                        for (var c = 0; c < colCount; c++)
                          _RoadCellBox(
                            size: _cell,
                            markerSize: _marker,
                            bead: placed.at(c, r),
                            isLastCol: c == colCount - 1,
                            isLastRow: r == rows - 1,
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoadCellBox extends StatelessWidget {
  final double size;
  final double markerSize;
  final _Bead? bead;
  final bool isLastCol;
  final bool isLastRow;

  const _RoadCellBox({
    required this.size,
    required this.markerSize,
    required this.bead,
    required this.isLastCol,
    required this.isLastRow,
  });

  @override
  Widget build(BuildContext context) {
    const line = BorderSide(color: AppColorStyles.borderPrimary, width: 0.5);
    final b = bead;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border(
          right: isLastCol ? BorderSide.none : line,
          bottom: isLastRow ? BorderSide.none : line,
        ),
      ),
      child: b == null
          ? null
          : Stack(
              alignment: Alignment.center,
              children: [
                ImageHelper.load(
                  path: b.isTai
                      ? MiniGameIcons.txTaiCircle
                      : MiniGameIcons.txXiuCircle,
                  width: markerSize,
                  height: markerSize,
                  fit: BoxFit.fill,
                ),
                if (b.number != null)
                  Text(
                    '${b.number}',
                    style: AppTextStyles.textStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      height: 1,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
    );
  }
}

class _RoadLayout {
  final int colCount;
  final Map<int, _Bead> _cells;
  final Map<int, Set<int>> _indexesByCol;

  const _RoadLayout(
    this.colCount,
    this._cells, [
    this._indexesByCol = const {},
  ]);

  _Bead? at(int col, int row) => _cells[col * 1000 + row];

  static _ColRange visibleColRange({
    required double offset,
    required double viewportWidth,
    required double cellSize,
  }) => _ColRange(
    first: (offset / cellSize).floor(),
    last: ((offset + viewportWidth) / cellSize).ceil() - 1,
  );

  Set<int> visibleBeadIndexes({required _ColRange colRange}) {
    final indexes = <int>{};
    for (var col = colRange.first; col <= colRange.last; col++) {
      final colIndexes = _indexesByCol[col];
      if (colIndexes != null) indexes.addAll(colIndexes);
    }
    return indexes;
  }
}

class _ColRange {
  final int first;
  final int last;

  const _ColRange({required this.first, required this.last});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ColRange && other.first == first && other.last == last;

  @override
  int get hashCode => Object.hash(first, last);
}

bool _setEquals(Set<int> a, Set<int> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  return a.containsAll(b);
}

bool _sameSessions(List<_Session> a, List<_Session> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    final left = a[i];
    final right = b[i];
    if (left.sessionId != null || right.sessionId != null) {
      if (left.sessionId != right.sessionId) return false;
      continue;
    }
    if (left.dice[0] != right.dice[0] ||
        left.dice[1] != right.dice[1] ||
        left.dice[2] != right.dice[2]) {
      return false;
    }
  }
  return true;
}

_RoadLayout _layoutRoad(List<_Bead> beads, int rows) {
  final cells = <int, _Bead>{};
  final indexesByCol = <int, Set<int>>{};
  var maxCol = 0;
  var col = 0;
  var row = 0;
  bool? prevTai;

  void place(int c, int r, _Bead b) {
    cells[c * 1000 + r] = b;
    indexesByCol.putIfAbsent(c, () => <int>{}).add(b.index);
    if (c > maxCol) maxCol = c;
  }

  for (final b in beads) {
    if (prevTai == null || b.isTai != prevTai) {
      if (prevTai != null) col++;
      row = 0;
    } else if (row + 1 < rows) {
      row++;
    } else {
      col++;
      row = 0;
    }
    place(col, row, b);
    prevTai = b.isTai;
  }

  return _RoadLayout(maxCol + 1, cells, indexesByCol);
}
