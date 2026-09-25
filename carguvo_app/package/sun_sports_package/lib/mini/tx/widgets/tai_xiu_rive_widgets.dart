import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;

import 'package:sun_sports/core/utils/extensions/rive_helper.dart';
import 'package:sun_sports/core/utils/styles/app_rive.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class TaiXiuRiveAnim extends StatefulWidget {
  final String url;
  final bool selected;
  final bool win;
  final rive.Fit fit;

  const TaiXiuRiveAnim({
    required this.url,
    this.selected = false,
    this.win = false,
    this.fit = rive.Fit.cover,
    super.key,
  });

  @override
  State<TaiXiuRiveAnim> createState() => _TaiXiuRiveAnimState();
}

class _TaiXiuRiveAnimState extends State<TaiXiuRiveAnim> {
  static const String _kIsSelectedProp = 'isSelected';
  static const String _kIsWinProp = 'isWin';

  static const String _kSelectedInput = 'selected';
  static const String _kWinInput = 'win';

  rive.RiveWidgetController? _controller;

  rive.ViewModelInstance? _vmi;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final file = await RiveHelper.getFile(widget.url);
      if (file != null && mounted) {
        final controller = rive.RiveWidgetController(file);
        rive.ViewModelInstance? vmi;
        try {
          vmi = controller.dataBind(rive.DataBind.auto());
          if (vmi.boolean(_kIsSelectedProp) == null) {
            vmi.dispose();
            vmi = null;
          }
        } catch (_) {
          vmi = null;
        }
        setState(() {
          _controller = controller;
          _vmi = vmi;
        });
        _applyInputs();
      }
    } catch (_) {
    }
  }

  @override
  void didUpdateWidget(TaiXiuRiveAnim oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected || oldWidget.win != widget.win) {
      _applyInputs();
    }
  }

  void _applyInputs() {
    final vmi = _vmi;
    if (vmi != null) {
      vmi.boolean(_kIsSelectedProp)?.value = widget.win
          ? false
          : widget.selected;
      vmi.boolean(_kIsWinProp)?.value = widget.win;
      return;
    }
    final sm = _controller?.stateMachine;
    if (sm == null) return;
    // ignore: deprecated_member_use
    sm.boolean(_kSelectedInput)?.value = widget.win ? false : widget.selected;
    // ignore: deprecated_member_use
    sm.boolean(_kWinInput)?.value = widget.win;
  }

  @override
  void dispose() {
    _vmi?.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _controller == null
      ? const SizedBox.shrink()
      : rive.RiveWidget(controller: _controller!, fit: widget.fit);
}

class TaiXiuBtnNanRive extends StatefulWidget {
  final bool active;

  final ValueChanged<bool>? onChanged;

  const TaiXiuBtnNanRive({this.active = false, this.onChanged, super.key});

  @override
  State<TaiXiuBtnNanRive> createState() => _TaiXiuBtnNanRiveState();
}

class _TaiXiuBtnNanRiveState extends State<TaiXiuBtnNanRive> {
  static const String _kInactive = 'inactive';
  static const String _kActive = 'active';

  rive.File? _file;
  late rive.SingleAnimationPainter _painter;

  @override
  void initState() {
    super.initState();
    _painter = _painterFor(widget.active);
    _load();
  }

  @override
  void didUpdateWidget(TaiXiuBtnNanRive oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active != widget.active) {
      setState(() => _painter = _painterFor(widget.active));
    }
  }

  rive.SingleAnimationPainter _painterFor(bool active) =>
      rive.RivePainter.animation(
        active ? _kActive : _kInactive,
        fit: rive.Fit.contain,
      );

  Future<void> _load() async {
    final url = AppRive.txAnimBtnNan;
    try {
      final file = await RiveHelper.getFile(url);
      if (file != null && mounted) {
        setState(() => _file = file);
      }
    } catch (_) {
    }
  }

  void _toggle() => widget.onChanged?.call(!widget.active);

  @override
  Widget build(BuildContext context) {
    final file = _file;
    if (file == null) return const SizedBox.shrink();
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: SoundTap.wrap(_toggle),
        child: rive.RiveFileWidget(file: file, painter: _painter),
      ),
    );
  }
}

class TaiXiuDiceResultRive extends StatefulWidget {
  final int d1;
  final int d2;
  final int d3;

  const TaiXiuDiceResultRive({
    required this.d1,
    required this.d2,
    required this.d3,
    super.key,
  });

  @override
  State<TaiXiuDiceResultRive> createState() => _TaiXiuDiceResultRiveState();
}

class _TaiXiuDiceResultRiveState extends State<TaiXiuDiceResultRive> {
  static const String _kInput1 = 'kq_xn1';
  static const String _kInput2 = 'kq_xn2';
  static const String _kInput3 = 'kq_xn3';

  rive.RiveWidgetController? _controller;
  rive.ViewModelInstance? _vmi;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final url = AppRive.txAnimXingauInput;
    try {
      final file = await RiveHelper.getFile(url);
      if (file != null && mounted) {
        final controller = rive.RiveWidgetController(file);
        final vmi = controller.dataBind(rive.DataBind.auto());
        setState(() {
          _controller = controller;
          _vmi = vmi;
        });
        _applyDice();
      }
    } catch (_) {
    }
  }

  @override
  void didUpdateWidget(TaiXiuDiceResultRive oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.d1 != widget.d1 ||
        oldWidget.d2 != widget.d2 ||
        oldWidget.d3 != widget.d3) {
      _applyDice();
    }
  }

  void _applyDice() {
    final vmi = _vmi;
    if (vmi == null) return;
    vmi.number(_kInput1)?.value = widget.d1.toDouble();
    vmi.number(_kInput2)?.value = widget.d2.toDouble();
    vmi.number(_kInput3)?.value = widget.d3.toDouble();
  }

  @override
  void dispose() {
    _vmi?.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _controller == null
      ? const SizedBox.shrink()
      : rive.RiveWidget(controller: _controller!, fit: rive.Fit.contain);
}

class TaiXiuDiceStaticRive extends StatefulWidget {
  final int d1;
  final int d2;
  final int d3;

  const TaiXiuDiceStaticRive({
    required this.d1,
    required this.d2,
    required this.d3,
    super.key,
  });

  @override
  State<TaiXiuDiceStaticRive> createState() => _TaiXiuDiceStaticRiveState();
}

class _TaiXiuDiceStaticRiveState extends State<TaiXiuDiceStaticRive> {
  static const String _kInput1 = 'kq_xn1';
  static const String _kInput2 = 'kq_xn2';
  static const String _kInput3 = 'kq_xn3';

  rive.RiveWidgetController? _controller;
  rive.ViewModelInstance? _vmi;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final url = AppRive.txAnimXingauResult;
    try {
      final file = await RiveHelper.getFile(url);
      if (file != null && mounted) {
        final controller = rive.RiveWidgetController(file);
        final vmi = controller.dataBind(rive.DataBind.auto());
        setState(() {
          _controller = controller;
          _vmi = vmi;
        });
        _applyDice();
      }
    } catch (_) {
    }
  }

  @override
  void didUpdateWidget(TaiXiuDiceStaticRive oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.d1 != widget.d1 ||
        oldWidget.d2 != widget.d2 ||
        oldWidget.d3 != widget.d3) {
      _applyDice();
    }
  }

  void _applyDice() {
    final vmi = _vmi;
    if (vmi == null) return;
    vmi.number(_kInput1)?.value = widget.d1.toDouble();
    vmi.number(_kInput2)?.value = widget.d2.toDouble();
    vmi.number(_kInput3)?.value = widget.d3.toDouble();
  }

  @override
  void dispose() {
    _vmi?.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _controller == null
      ? const SizedBox.shrink()
      : rive.RiveWidget(controller: _controller!, fit: rive.Fit.contain);
}

class TaiXiuLatestCircle extends StatelessWidget {
  final int? total;
  final double size;

  const TaiXiuLatestCircle({required this.total, this.size = kSize, super.key});

  static const double kSize = 24;

  @override
  Widget build(BuildContext context) {
    final total = this.total;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          TaiXiuRecentResultRive(total: total ?? 0),
          if (total != null)
            Text(
              '$total',
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

class TaiXiuRecentResultRive extends StatefulWidget {
  final int total;

  const TaiXiuRecentResultRive({required this.total, super.key});

  @override
  State<TaiXiuRecentResultRive> createState() => _TaiXiuRecentResultRiveState();
}

class _TaiXiuRecentResultRiveState extends State<TaiXiuRecentResultRive> {
  static const String _kTotalInput = 'total_number';

  rive.RiveWidgetController? _controller;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final url = AppRive.txAnimRecentResult;
    try {
      final file = await RiveHelper.getFile(url);
      if (file != null && mounted) {
        final controller = rive.RiveWidgetController(file);
        setState(() => _controller = controller);
        _applyTotal();
      }
    } catch (_) {
    }
  }

  @override
  void didUpdateWidget(TaiXiuRecentResultRive oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.total != widget.total) _applyTotal();
  }

  void _applyTotal() {
    final sm = _controller?.stateMachine;
    if (sm == null) return;
    // ignore: deprecated_member_use
    final input = sm.number(_kTotalInput) ?? _firstNumberInput(sm);
    input?.value = widget.total.toDouble();
  }

  // ignore: deprecated_member_use
  rive.NumberInput? _firstNumberInput(rive.StateMachine sm) {
    // ignore: deprecated_member_use
    for (final input in sm.inputs) {
      if (input is rive.NumberInput) return input;
    }
    return null;
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _controller == null
      ? const SizedBox.shrink()
      : rive.RiveWidget(controller: _controller!, fit: rive.Fit.contain);
}
