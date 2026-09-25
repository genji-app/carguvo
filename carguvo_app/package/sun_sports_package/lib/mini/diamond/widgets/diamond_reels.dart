import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:sun_sports/core/utils/bundle_manager.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/sprite/sprite_atlas.dart';
import 'package:sun_sports/mini/diamond/state/diamond_paylines.dart';
import 'package:sun_sports/mini/diamond/state/diamond_state.dart';
import 'package:sun_sports/mini/diamond/state/diamond_state_provider.dart';
import 'package:sun_sports/mini/diamond/widgets/diamond_common.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

const List<int> kDiamondLeftRailOrder = [7, 3, 5, 2, 6, 4, 0, 1, 8, 9];

const List<int> kDiamondRightRailOrder = [10, 18, 14, 15, 13, 19, 12, 16, 11, 17];

const double kReelColGap = 4;
const double kReelPadH = 6;
const double kReelPadV = 12;
const double _kRailW = 28;
const double _kRailPadV = 4;
const double _kBadgeSize = 20;

const double _kSymbolHeightFactor = 0.65;

const double _kBlurSigmaX = 0.5;
const double _kBlurSigmaY = 7;

const double _kBlurPadX = 3;
const double _kBlurPadY = 21;

const double kReelRollFps = 24;
const double kReelSettleFps = 36;
const double kReelRollFpsHot = 20;
const double kReelSettleFpsHot = 30;
bool kReelFpsHot = false;

int _wrapCode(int code) =>
    ((code % kDiamondSymbolCount) + kDiamondSymbolCount) % kDiamondSymbolCount;

class DiamondReels extends ConsumerStatefulWidget {
  final double aspectRatio;

  const DiamondReels({this.aspectRatio = 338 / 252, super.key});

  @override
  ConsumerState<DiamondReels> createState() => _DiamondReelsState();
}

class _DiamondReelsState extends ConsumerState<DiamondReels> {
  int? _previewLine;
  Timer? _previewTimer;

  List<int> _winLines = const [];

  int _winPhase = 0;

  int _shownCount = 0;
  int _cycleIdx = 0;
  Timer? _winTimer;

  static const Duration _columnSettle = Duration(milliseconds: 2200);
  static const Duration _columnSettleFast = Duration(milliseconds: 450);

  static const int _showAllMs = 700;

  void _preview(int lineId) {
    setState(() => _previewLine = lineId);
    _previewTimer?.cancel();
    _previewTimer = Timer(const Duration(seconds: 1), () {
      if (mounted) setState(() => _previewLine = null);
    });
  }

  void _startWinSequence(List<int> lines) {
    _winTimer?.cancel();
    final s = ref.read(diamondStateProvider);
    final fast = s.fastSpin;
    final auto = s.autoSpin;
    setState(() {
      _winLines = lines;
      _winPhase = 0;
      _shownCount = 0;
      _cycleIdx = 0;
    });
    _winTimer = Timer(fast ? _columnSettleFast : _columnSettle, () {
      if (!mounted || _winLines.isEmpty) return;
      _revealAll(fast: fast, auto: auto);
    });
  }

  void _revealAll({required bool fast, required bool auto}) {
    final n = _winLines.length;
    if (fast) {
      setState(() => _shownCount = n);
      _afterShowAll(auto);
      return;
    }
    setState(() => _shownCount = 1);
    final stepMs = (_showAllMs / n).round().clamp(60, 700).toInt();
    final step = Duration(milliseconds: stepMs);
    _winTimer = Timer.periodic(step, (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_shownCount >= n) {
        t.cancel();
        _afterShowAll(auto);
        return;
      }
      setState(() => _shownCount += 1);
    });
  }

  void _afterShowAll(bool auto) {
    if (auto) return;
    _winTimer = Timer(const Duration(seconds: 1), () {
      if (!mounted || _winLines.isEmpty) return;
      setState(() {
        _winPhase = 1;
        _cycleIdx = 0;
      });
      _winTimer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted) {
          t.cancel();
          return;
        }
        final next = _cycleIdx + 1;
        if (next >= _winLines.length) {
          t.cancel();
          setState(() {
            _winLines = const [];
            _winPhase = 0;
          });
        } else {
          setState(() => _cycleIdx = next);
        }
      });
    });
  }

  void _clearWin() {
    _winTimer?.cancel();
    if (_winLines.isNotEmpty) setState(() => _winLines = const []);
  }

  @override
  void dispose() {
    _previewTimer?.cancel();
    _winTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(diamondStateProvider.select((s) => s.spinning), (_, next) {
      if (next) {
        _clearWin();
      } else {
        final wins = ref.read(diamondStateProvider).winLineIds;
        if (wins.isNotEmpty) _startWinSequence(wins);
      }
    });

    final (spinning, fastSpin, symbols) = ref.watch(
      diamondStateProvider.select((s) => (s.spinning, s.fastSpin, s.symbols)),
    );

    final List<int> overlayLines;
    if (_previewLine != null) {
      overlayLines = [_previewLine!];
    } else if (spinning || _winLines.isEmpty) {
      overlayLines = const [];
    } else if (_winPhase == 0) {
      overlayLines = _winLines.take(_shownCount).toList();
    } else {
      overlayLines = [_winLines[_cycleIdx.clamp(0, _winLines.length - 1)]];
    }

    return AspectRatio(
      aspectRatio: widget.aspectRatio,
      child: Stack(
        children: [
          _reelRow(
            chrome: true,
            symbols: symbols,
            spinning: spinning,
            fast: fastSpin,
          ),
          if (overlayLines.isNotEmpty)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _ReelWinLinesPainter(overlayLines),
                ),
              ),
            ),
          _reelRow(
            chrome: false,
            symbols: symbols,
            spinning: spinning,
            fast: fastSpin,
          ),
        ],
      ),
    );
  }

  Widget _reelRow({
    required bool chrome,
    required List<int> symbols,
    required bool spinning,
    required bool fast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _NumberColumn(
          lineIds: kDiamondLeftRailOrder,
          onTap: _preview,
          chrome: chrome,
        ),
        const SizedBox(width: kReelColGap),
        Expanded(
          child: Container(
            decoration: chrome
                ? BoxDecoration(
                    color: const Color(0xFF1B1A19),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0),
                      width: 0.5,
                    ),
                  )
                : null,
            foregroundDecoration: chrome
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x4D000000),
                        Color(0x00000000),
                        Color(0x00000000),
                        Color(0x14FFFFFF),
                      ],
                      stops: [0, 0.06, 0.94, 1],
                    ),
                  )
                : null,
            padding: const EdgeInsets.symmetric(
              horizontal: kReelPadH,
              vertical: kReelPadV,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var col = 0; col < 3; col++) ...[
                  Expanded(
                    child: chrome
                        ? const SizedBox.shrink()
                        : DiamondReelColumn(
                            columnIndex: col,
                            target: [
                              diamondSymbolAt(symbols, col, 2),
                              diamondSymbolAt(symbols, col, 1),
                              diamondSymbolAt(symbols, col, 0),
                            ],
                            spinning: spinning,
                            fast: fast,
                          ),
                  ),
                  if (col < 2)
                    chrome ? const _ReelDivider() : const SizedBox(width: 1),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(width: kReelColGap),
        _NumberColumn(
          lineIds: kDiamondRightRailOrder,
          onTap: _preview,
          chrome: chrome,
        ),
      ],
    );
  }
}

class _NumberColumn extends StatelessWidget {
  final List<int> lineIds;
  final ValueChanged<int> onTap;

  final bool chrome;

  const _NumberColumn({
    required this.lineIds,
    required this.onTap,
    this.chrome = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: chrome
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: Colors.white.withValues(alpha: 0), width: 0.5),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF141312), Color(0xFF201F1D)],
              ),
            )
          : null,
      child: chrome
          ? const SizedBox.expand()
          : Column(
              children: [
                for (final id in lineIds)
                  Expanded(
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: _NumberBadge(lineId: id, onTap: () => onTap(id)),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

class _NumberBadge extends StatelessWidget {
  final int lineId;
  final VoidCallback onTap;

  const _NumberBadge({required this.lineId, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SoundTap(
      onTap: onTap,
      child: Container(
        width: _kBadgeSize,
        height: _kBadgeSize,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF393836), width: 0.5),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF484746), Color(0xFF393836)],
          ),
        ),
        child: Text(
          '${lineId + 1}',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: kDiamondTextPrimary,
          ),
        ),
      ),
    );
  }
}

class DiamondReelColumn extends StatefulWidget {
  final int columnIndex;
  final List<int?> target;
  final bool spinning;
  final bool fast;

  const DiamondReelColumn({
    required this.columnIndex,
    required this.target,
    required this.spinning,
    required this.fast,
    super.key,
  });

  @override
  State<DiamondReelColumn> createState() => _DiamondReelColumnState();
}

class _DiamondReelColumnState extends State<DiamondReelColumn>
    with SingleTickerProviderStateMixin {
  late final _ReelColumnController _anim;

  @override
  void initState() {
    super.initState();
    _anim = _ReelColumnController(
      vsync: this,
      columnIndex: widget.columnIndex,
      target: widget.target,
      fast: widget.fast,
    );
    if (widget.spinning) _anim.startRoll();
  }

  @override
  void didUpdateWidget(DiamondReelColumn old) {
    super.didUpdateWidget(old);
    _anim.target = widget.target;
    _anim.fast = widget.fast;
    if (widget.spinning && !old.spinning) {
      _anim.startRoll();
    } else if (!widget.spinning && old.spinning) {
      _anim.scheduleStop();
    } else if (!widget.spinning) {
      _anim.applyStatic();
    }
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: BundleManager.assetsGeneration,
      builder: (context, _, __) {
        final atlas = _DiamondSymbolAtlas.instance;
        final useAtlas = atlas.resolve();
        final dpr = MediaQuery.devicePixelRatioOf(context);
        return LayoutBuilder(
          builder: (context, c) {
            final cell = c.maxHeight / 3;
            if (useAtlas) atlas.ensureBlur(cell * _kSymbolHeightFactor, dpr);
            return RepaintBoundary(
              child: ClipRect(
                child: SizedBox(
                  width: c.maxWidth,
                  height: c.maxHeight,
                  child: useAtlas
                      ? CustomPaint(
                          size: Size(c.maxWidth, c.maxHeight),
                          painter: _ReelStripPainter(_anim),
                        )
                      : _FallbackStrip(anim: _anim, cell: cell),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _ReelColumnController extends ChangeNotifier {
  _ReelColumnController({
    required TickerProvider vsync,
    required this.columnIndex,
    required List<int?> target,
    required bool fast,
  }) : _target = target,
       _fast = fast {
    _ticker = vsync.createTicker(_onTick);
    _strip = [_rng.nextInt(kDiamondSymbolCount), ..._targetOr(_randomTriple())];
  }

  final int columnIndex;
  final Random _rng = Random();
  late final Ticker _ticker;
  Timer? _stopTimer;

  List<int?> _target;
  bool _fast;

  late List<int> _strip;

  double _offset = 0;
  bool _rolling = false;
  Duration _lastTick = Duration.zero;
  double _acc = 0;

  static const double _speed = 16;

  double get _rollInterval => 1 / (kReelFpsHot ? kReelRollFpsHot : kReelRollFps);
  double get _settleInterval =>
      1 / (kReelFpsHot ? kReelSettleFpsHot : kReelSettleFps);

  bool _settling = false;
  double _settleP = 0;
  double _settleStart = -3;
  List<int> _settleStrip = const [];
  List<int> _settleTargets = const [];
  static const double _settleDuration = 0.36;

  List<int> get tiles => _settling ? _settleStrip : _strip;

  double get top0Cells => _settling ? _settleSlideCells(_settleP) : _offset - 1;

  bool get blur => _settling ? _settleP < 0.5 : _rolling;

  bool get idle => !_rolling && !_settling;

  set target(List<int?> value) => _target = value;
  set fast(bool value) => _fast = value;

  List<int> _randomTriple() =>
      List<int>.generate(3, (_) => _rng.nextInt(kDiamondSymbolCount));

  List<int> _targetOr(List<int> fallback) =>
      List<int>.generate(3, (i) => _target[i] ?? fallback[i]);

  void startRoll() {
    _stopTimer?.cancel();
    _settling = false;
    _rolling = true;
    if (!_ticker.isTicking) {
      _lastTick = Duration.zero;
      _ticker.start();
    }
  }

  void scheduleStop() {
    final stagger = _fast ? 0 : 600 * (columnIndex + 1);
    _stopTimer?.cancel();
    _stopTimer = Timer(Duration(milliseconds: stagger), _startSettle);
  }

  void applyStatic() {
    if (!idle) return;
    _offset = 0;
    _strip = [_strip[0], ..._targetOr(_strip.sublist(1))];
    notifyListeners();
  }

  void _startSettle() {
    final cur = List<int>.from(_strip.sublist(1));
    _settleTargets = _targetOr(cur);
    _settleStrip = [..._settleTargets, ...cur];
    _settleStart = _offset - 3;
    _rolling = false;
    _settling = true;
    _settleP = 0;
    if (!_ticker.isTicking) {
      _lastTick = Duration.zero;
      _ticker.start();
    }
    notifyListeners();
  }

  void _onTick(Duration elapsed) {
    _acc += (elapsed - _lastTick).inMicroseconds / 1e6;
    _lastTick = elapsed;
    final target = _settling ? _settleInterval : _rollInterval;
    var stepped = false;
    while (_acc >= target) {
      _acc -= target;
      if (_rolling) {
        _offset += _speed * target;
        while (_offset >= 1) {
          _offset -= 1;
          _strip = [
            _rng.nextInt(kDiamondSymbolCount),
            _strip[0],
            _strip[1],
            _strip[2],
          ];
        }
      } else if (_settling) {
        _settleP += target / _settleDuration;
        if (_settleP >= 1) {
          _settleP = 1;
          _finishSettle();
        }
      } else {
        _acc = 0;
        break;
      }
      stepped = true;
    }

    if (stepped) notifyListeners();
  }

  void _finishSettle() {
    _settling = false;
    _strip = [_rng.nextInt(kDiamondSymbolCount), ..._settleTargets];
    _offset = 0;
    if (_ticker.isTicking) _ticker.stop();
  }

  double _settleSlideCells(double p) {
    final base = _settleStart * (1 - Curves.easeOutCubic.transform(p));
    final bounce = p < 0.72 ? 0.0 : sin((p - 0.72) / 0.28 * pi) * 0.1;
    return base + bounce;
  }

  @override
  void dispose() {
    _stopTimer?.cancel();
    _ticker.dispose();
    super.dispose();
  }
}

class _ReelStripPainter extends CustomPainter {
  _ReelStripPainter(this.anim) : super(repaint: anim);

  final _ReelColumnController anim;

  @override
  void paint(Canvas canvas, Size size) {
    final atlas = _DiamondSymbolAtlas.instance;
    if (!atlas.ready) return;
    final cell = size.height / 3;
    if (cell <= 0) return;

    final tiles = anim.tiles;
    final top0 = anim.top0Cells * cell;
    final wantBlur = anim.blur;
    final paint = Paint()..filterQuality = FilterQuality.medium;

    for (var i = 0; i < tiles.length; i++) {
      final code = _wrapCode(tiles[i]);
      final pair = atlas.sharp(code);
      if (pair == null) continue;
      final s = atlas.symbolSize(code, cell);
      final left = (size.width - s.width) / 2;
      final top = top0 + i * cell + (cell - s.height) / 2;

      final blurImg = wantBlur ? atlas.blurred(code) : null;
      if (blurImg != null) {
        canvas.drawImageRect(
          blurImg,
          Rect.fromLTWH(
            0,
            0,
            blurImg.width.toDouble(),
            blurImg.height.toDouble(),
          ),
          Rect.fromLTWH(
            left - _kBlurPadX,
            top - _kBlurPadY,
            s.width + 2 * _kBlurPadX,
            s.height + 2 * _kBlurPadY,
          ),
          paint,
        );
      } else {
        paintAtlasFrame(
          canvas,
          pair.$1,
          pair.$2,
          Rect.fromLTWH(left, top, s.width, s.height),
          paint: paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_ReelStripPainter old) => true;
}

class _FallbackStrip extends StatelessWidget {
  const _FallbackStrip({required this.anim, required this.cell});

  final _ReelColumnController anim;
  final double cell;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: anim,
      builder: (context, _) {
        final tiles = anim.tiles;
        final top0 = anim.top0Cells * cell;
        Widget strip = Stack(
          clipBehavior: Clip.none,
          children: [
            for (var i = 0; i < tiles.length; i++)
              Positioned(
                top: top0 + i * cell,
                left: 0,
                right: 0,
                height: cell,
                child: _fallbackSymbol(
                  _wrapCode(tiles[i]),
                  cell * _kSymbolHeightFactor,
                ),
              ),
          ],
        );
        if (anim.blur) {
          strip = ImageFiltered(
            imageFilter: ui.ImageFilter.blur(
              sigmaX: _kBlurSigmaX,
              sigmaY: _kBlurSigmaY,
            ),
            child: strip,
          );
        }
        return strip;
      },
    );
  }
}

final Map<(int, int), Widget> _fallbackSymbolCache = {};

Widget _fallbackSymbol(int code, double height) {
  final key = (code, (height * 2).round());
  final cached = _fallbackSymbolCache[key];
  if (cached != null) return cached;
  if (_fallbackSymbolCache.length > 24) _fallbackSymbolCache.clear();
  final built = Center(
    child: ImageHelper.load(
      path: diamondSymbolAsset(code),
      height: height,
      fit: BoxFit.fitHeight,
    ),
  );
  _fallbackSymbolCache[key] = built;
  return built;
}

class _DiamondSymbolAtlas {
  _DiamondSymbolAtlas._() {
    BundleManager.assetsGeneration.addListener(_invalidate);
  }

  static final _DiamondSymbolAtlas instance = _DiamondSymbolAtlas._();

  final List<(ui.Image, AtlasFrame)?> _sharp = List<(ui.Image, AtlasFrame)?>
      .filled(kDiamondSymbolCount, null);
  bool _ready = false;

  List<ui.Image>? _blurred;
  double? _blurHeight;
  bool _blurBuilding = false;

  bool get ready => _ready;

  (ui.Image, AtlasFrame)? sharp(int code) => _sharp[code];

  ui.Image? blurred(int code) => _blurred?[code];

  void _invalidate() {
    _ready = false;
    _sharp.fillRange(0, _sharp.length, null);
    _disposeBlur();
  }

  void _disposeBlur() {
    final old = _blurred;
    _blurred = null;
    _blurHeight = null;
    if (old == null) return;
    for (final img in old) {
      img.dispose();
    }
  }

  bool resolve() {
    if (_ready) return true;
    for (var code = 0; code < kDiamondSymbolCount; code++) {
      final pair = BundleManager.instance.getAtlasImageAndFrame(
        diamondSymbolAsset(code),
      );
      if (pair == null) return false;
      _sharp[code] = pair;
    }
    _ready = true;
    return true;
  }

  Size symbolSize(int code, double cell) =>
      _sizeForHeight(code, cell * _kSymbolHeightFactor);

  Size _sizeForHeight(int code, double h) {
    final src = _sharp[code]?.$2.sourceSize;
    if (src == null || src.height <= 0) return Size(h, h);
    return Size(h * src.width / src.height, h);
  }

  void ensureBlur(double h, double dpr) {
    if (!_ready || _blurBuilding || h <= 0) return;
    if (_blurred != null && _blurHeight != null && (_blurHeight! - h).abs() < 0.5) {
      return;
    }
    _blurBuilding = true;
    unawaited(_rebuildBlur(h, dpr));
  }

  Future<void> _rebuildBlur(double h, double dpr) async {
    List<ui.Image>? images;
    try {
      images = await _renderBlurSet(h, dpr);
    } catch (_) {
      images = null;
    }
    _blurBuilding = false;
    if (images == null) return;
    if (!_ready) {
      for (final img in images) {
        img.dispose();
      }
      return;
    }
    _disposeBlur();
    _blurred = images;
    _blurHeight = h;
  }

  Future<List<ui.Image>> _renderBlurSet(double h, double dpr) async {
    final out = <ui.Image>[];
    try {
      for (var code = 0; code < kDiamondSymbolCount; code++) {
        final pair = _sharp[code];
        if (pair == null) throw StateError('symbol $code chưa resolve');
        out.add(
          await _renderBlur(pair.$1, pair.$2, _sizeForHeight(code, h), dpr),
        );
      }
    } catch (_) {
      for (final img in out) {
        img.dispose();
      }
      rethrow;
    }
    return out;
  }

  Future<ui.Image> _renderBlur(
    ui.Image atlas,
    AtlasFrame frame,
    Size size,
    double dpr,
  ) async {
    final total = Size(
      size.width + 2 * _kBlurPadX,
      size.height + 2 * _kBlurPadY,
    );
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final outDpr = dpr / 2;
    canvas.scale(outDpr);
    canvas.saveLayer(
      Offset.zero & total,
      Paint()
        ..imageFilter = ui.ImageFilter.blur(
          sigmaX: _kBlurSigmaX,
          sigmaY: _kBlurSigmaY,
        ),
    );
    paintAtlasFrame(
      canvas,
      atlas,
      frame,
      Rect.fromLTWH(_kBlurPadX, _kBlurPadY, size.width, size.height),
    );
    canvas.restore();
    final picture = recorder.endRecording();
    try {
      return await picture.toImage(
        max(1, (total.width * outDpr).ceil()),
        max(1, (total.height * outDpr).ceil()),
      );
    } finally {
      picture.dispose();
    }
  }
}

class _ReelDivider extends StatelessWidget {
  const _ReelDivider();

  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0x00FFFFFF),
              Color(0x1FFFFFFF),
              Color(0x00FFFFFF),
            ],
          ),
        ),
      );
}

class _ReelWinLinesPainter extends CustomPainter {
  final List<int> winLineIds;
  const _ReelWinLinesPainter(this.winLineIds);

  Offset _symbol(int col, int row, Size size) {
    final contentX = _kRailW + kReelColGap + kReelPadH;
    final contentW = size.width - 2 * (_kRailW + kReelColGap) - 2 * kReelPadH;
    final contentH = size.height - 2 * kReelPadV;
    return Offset(
      contentX + (col + 0.5) * contentW / 3,
      kReelPadV + ((2 - row) + 0.5) * contentH / 3,
    );
  }

  Offset _badge(int slot, bool left, Size size) {
    final innerH = size.height - 2 * _kRailPadV;
    final y = _kRailPadV + (slot + 0.5) * innerH / 10;
    final x = left ? _kRailW / 2 : size.width - _kRailW / 2;
    return Offset(x, y);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = const Color(0xFFFFC24B);

    for (final id in winLineIds) {
      if (id < 0 || id >= kDiamondLineCount) continue;
      final def = kDiamondPaylines[id];
      final pts = <Offset>[
        _symbol(0, def[0], size),
        _symbol(1, def[1], size),
        _symbol(2, def[2], size),
      ];
      final leftSlot = kDiamondLeftRailOrder.indexOf(id);
      if (leftSlot >= 0) {
        pts.insert(0, _badge(leftSlot, true, size));
      } else {
        final rightSlot = kDiamondRightRailOrder.indexOf(id);
        if (rightSlot >= 0) pts.add(_badge(rightSlot, false, size));
      }

      final path = Path()..moveTo(pts.first.dx, pts.first.dy);
      for (var i = 1; i < pts.length; i++) {
        path.lineTo(pts[i].dx, pts[i].dy);
      }
      canvas.drawPath(path, line);
    }
  }

  @override
  bool shouldRepaint(_ReelWinLinesPainter old) =>
      old.winLineIds != winLineIds;
}
