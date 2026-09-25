import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;
import 'package:sport_notice/sport_notice.dart' as notice;
import 'package:sun_sports/core/utils/app_logger.dart';
import 'package:sun_sports/core/utils/extensions/rive_helper.dart';
import 'package:sun_sports/core/utils/styles/app_rive.dart';

enum MatchNoticeType {
  theVang('the_vang'),

  theDo('the_do'),

  phatGoc('phat_goc'),

  ghiBan('ghi_ban');

  const MatchNoticeType(this.artboardName);

  final String artboardName;
}

notice.MatchNoticeKind toNoticeKind(MatchNoticeType type) => switch (type) {
      MatchNoticeType.theVang => notice.MatchNoticeKind.yellowCard,
      MatchNoticeType.theDo => notice.MatchNoticeKind.redCard,
      MatchNoticeType.phatGoc => notice.MatchNoticeKind.corner,
      MatchNoticeType.ghiBan => notice.MatchNoticeKind.goal,
    };

MatchNoticeType fromNoticeKind(notice.MatchNoticeKind kind) => switch (kind) {
      notice.MatchNoticeKind.yellowCard => MatchNoticeType.theVang,
      notice.MatchNoticeKind.redCard => MatchNoticeType.theDo,
      notice.MatchNoticeKind.corner => MatchNoticeType.phatGoc,
      notice.MatchNoticeKind.goal => MatchNoticeType.ghiBan,
    };

@immutable
class MatchNoticeOverlayData {
  const MatchNoticeOverlayData({
    this.homeNotice,
    this.awayNotice,
    this.homeNoticeSeq = 0,
    this.awayNoticeSeq = 0,
    this.onHomeNoticeCompleted,
    this.onAwayNoticeCompleted,
  });

  final MatchNoticeType? homeNotice;
  final MatchNoticeType? awayNotice;
  final int homeNoticeSeq;
  final int awayNoticeSeq;
  final VoidCallback? onHomeNoticeCompleted;
  final VoidCallback? onAwayNoticeCompleted;
}

class MatchNoticeRiveAnimation extends StatefulWidget {
  const MatchNoticeRiveAnimation({
    required this.type,
    this.onCompleted,
    super.key,
  });

  final MatchNoticeType type;

  final VoidCallback? onCompleted;

  static void preload() => _MatchNoticeRiveAnimationState.preload();

  @override
  State<MatchNoticeRiveAnimation> createState() =>
      _MatchNoticeRiveAnimationState();
}

class _MatchNoticeRiveAnimationState extends State<MatchNoticeRiveAnimation> {
  static final _log = AppLogger(tag: 'MatchNotice');

  static Future<rive.File?>? _fileFuture;

  static void preload() {
    _fileFuture ??= RiveHelper.getFile(AppRive.matchNotice);
  }

  _NoticeRiveController? _controller;

  bool _completed = false;

  Timer? _durationTimer;

  rive.ViewModelInstanceNumber? _widthInput;
  rive.ViewModelInstanceNumber? _heightInput;

  Size? _appliedSize;

  @override
  void initState() {
    super.initState();
    _loadRiveFile();
  }

  @override
  void didUpdateWidget(covariant MatchNoticeRiveAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.type != widget.type) {
      _disposeController();
      _buildController();
    }
  }

  Future<void> _loadRiveFile() async {
    preload();
    await _buildController();
  }

  Future<void> _buildController() async {
    try {
      final file = await _fileFuture;
      if (file == null || !mounted) return;
      _completed = false;
      final controller = _NoticeRiveController(
        file,
        artboardSelector: rive.ArtboardNamed(widget.type.artboardName),
      );
      controller.onSettled = _notifyCompleted;
      controller.stateMachine.addEventListener(_onRiveEvent);
      rive.ViewModelInstanceNumber? widthInput;
      rive.ViewModelInstanceNumber? heightInput;
      try {
        final vmi = controller.dataBind(rive.DataBind.auto());
        widthInput = vmi.number('width');
        heightInput = vmi.number('height');
      } catch (e) {
        _log.w(
          'no default view model for artboard=${widget.type.artboardName} '
          '(render không scale; thêm VMI width/height trong file .riv nếu cần)',
          e,
        );
      }
      setState(() {
        _controller = controller;
        _widthInput = widthInput;
        _heightInput = heightInput;
        _appliedSize = null;
      });
      _startDurationTimer(controller.artboard);
    } catch (e, st) {
      _log.w('build controller fail artboard=${widget.type.artboardName}', e, st);
      _fileFuture = null;
    }
  }

  void _startDurationTimer(rive.Artboard artboard) {
    _durationTimer?.cancel();
    var maxDuration = 0.0;
    final count = artboard.animationCount();
    for (var i = 0; i < count; i++) {
      final anim = artboard.animationAt(i);
      if (anim.duration > maxDuration) maxDuration = anim.duration;
      anim.dispose();
    }
    if (maxDuration <= 0) return;
    final ms = (maxDuration * 1000).ceil() + 80;
    _durationTimer = Timer(Duration(milliseconds: ms), _notifyCompleted);
  }

  void _onRiveEvent(rive.Event event) => _notifyCompleted();

  void _notifyCompleted() {
    if (_completed) return;
    _completed = true;
    widget.onCompleted?.call();
  }

  void _applySize(double width, double height) {
    if (!width.isFinite || !height.isFinite) return;
    final size = Size(width, height);
    if (_appliedSize == size) return;
    _appliedSize = size;
    _widthInput?.value = width;
    _heightInput?.value = height;
  }

  void _disposeController() {
    _durationTimer?.cancel();
    _durationTimer = null;
    _controller?.stateMachine.removeEventListener(_onRiveEvent);
    _controller?.dispose();
    _controller = null;
    _widthInput = null;
    _heightInput = null;
    _appliedSize = null;
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null) return const SizedBox.shrink();

    return RepaintBoundary(
      child: IgnorePointer(
        child: LayoutBuilder(
          builder: (context, constraints) {
            _applySize(constraints.maxWidth, constraints.maxHeight);
            return rive.RiveWidget(controller: controller, fit: rive.Fit.fill);
          },
        ),
      ),
    );
  }
}

final class _NoticeRiveController extends rive.RiveWidgetController {
  _NoticeRiveController(
    super.file, {
    required super.artboardSelector,
  });

  VoidCallback? onSettled;

  bool _everActive = false;
  bool _settledNotified = false;

  @override
  bool advance(double elapsedSeconds) {
    final keepGoing = super.advance(elapsedSeconds);
    if (keepGoing) {
      _everActive = true;
    } else if (_everActive && !_settledNotified) {
      _settledNotified = true;
      onSettled?.call();
    }
    return keepGoing;
  }
}
