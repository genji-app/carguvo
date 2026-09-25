import 'package:flutter/widgets.dart';

enum SpotlightTargetId {
  betSlipButton,

  balanceDeposit,

  avatarProfile,

  betSlipPanelTabs,

  myBetsTab,

  betSlipTab,

  myBetsTabItem,

  betNowButton,

  searchButton,
}

enum SpotlightPlacement {
  auto,
  top,
  bottom,
  left,
  right,
}

class SpotlightStep {
  const SpotlightStep({
    required this.target,
    required this.title,
    required this.body,
    this.placement = SpotlightPlacement.auto,
    this.highlightRadius = 12,
    this.highlightPadding = 8,
    this.sceneChange = false,
    this.onEnter,
    this.onExit,
  });

  final SpotlightTargetId target;
  final String title;
  final String body;
  final SpotlightPlacement placement;

  final bool sceneChange;

  final double highlightRadius;

  final double highlightPadding;

  final Future<void> Function(SpotlightNavigator nav)? onEnter;

  final Future<void> Function(SpotlightNavigator nav)? onExit;
}

class SpotlightTour {
  const SpotlightTour({required this.id, required this.steps});

  final String id;
  final List<SpotlightStep> steps;

  int get length => steps.length;
}

class SpotlightRegistry {
  SpotlightRegistry._();
  static final SpotlightRegistry instance = SpotlightRegistry._();

  final Map<SpotlightTargetId, GlobalKey> _keys = {};

  void register(SpotlightTargetId id, GlobalKey key) => _keys[id] = key;

  void unregister(SpotlightTargetId id, GlobalKey key) {
    if (_keys[id] == key) _keys.remove(id);
  }

  GlobalKey? keyOf(SpotlightTargetId id) => _keys[id];

  Rect? rectOf(SpotlightTargetId id) {
    final key = _keys[id];
    final ctx = key?.currentContext;
    if (ctx == null) return null;
    final box = ctx.findRenderObject();
    if (box is! RenderBox || !box.hasSize || !box.attached) return null;
    final topLeft = box.localToGlobal(Offset.zero);
    return topLeft & box.size;
  }
}

class SpotlightAnchor extends StatefulWidget {
  const SpotlightAnchor({
    required this.id,
    required this.child,
    super.key,
  });

  final SpotlightTargetId id;
  final Widget child;

  @override
  State<SpotlightAnchor> createState() => _SpotlightAnchorState();
}

class _SpotlightAnchorState extends State<SpotlightAnchor> {
  final GlobalKey _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    SpotlightRegistry.instance.register(widget.id, _key);
  }

  @override
  void didUpdateWidget(SpotlightAnchor old) {
    super.didUpdateWidget(old);
    if (old.id != widget.id) {
      SpotlightRegistry.instance.unregister(old.id, _key);
      SpotlightRegistry.instance.register(widget.id, _key);
    }
  }

  @override
  void dispose() {
    SpotlightRegistry.instance.unregister(widget.id, _key);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(key: _key, child: widget.child);
  }
}

abstract class SpotlightNavigator {
  Future<void> prepareTour();

  Future<void> goHome();

  Future<void> openSampleMatchWithBetSlip();

  Future<void> showMyBets();

  Future<void> closeBetSlip();

  Future<void> restoreAfterTour();
}

class NoopSpotlightNavigator implements SpotlightNavigator {
  const NoopSpotlightNavigator();
  @override
  Future<void> prepareTour() async {}
  @override
  Future<void> goHome() async {}
  @override
  Future<void> openSampleMatchWithBetSlip() async {}
  @override
  Future<void> showMyBets() async {}
  @override
  Future<void> closeBetSlip() async {}
  @override
  Future<void> restoreAfterTour() async {}
}

class CallbackSpotlightNavigator implements SpotlightNavigator {
  const CallbackSpotlightNavigator({
    Future<void> Function()? onPrepare,
    Future<void> Function()? onGoHome,
    Future<void> Function()? onOpenMatch,
    Future<void> Function()? onShowMyBets,
    Future<void> Function()? onCloseBetSlip,
    Future<void> Function()? onRestore,
  }) : _onPrepare = onPrepare,
       _onGoHome = onGoHome,
       _onOpenMatch = onOpenMatch,
       _onShowMyBets = onShowMyBets,
       _onCloseBetSlip = onCloseBetSlip,
       _onRestore = onRestore;

  final Future<void> Function()? _onPrepare;
  final Future<void> Function()? _onGoHome;
  final Future<void> Function()? _onOpenMatch;
  final Future<void> Function()? _onShowMyBets;
  final Future<void> Function()? _onCloseBetSlip;
  final Future<void> Function()? _onRestore;

  @override
  Future<void> prepareTour() async => _onPrepare?.call();
  @override
  Future<void> goHome() async => _onGoHome?.call();
  @override
  Future<void> openSampleMatchWithBetSlip() async => _onOpenMatch?.call();
  @override
  Future<void> showMyBets() async => _onShowMyBets?.call();
  @override
  Future<void> closeBetSlip() async => _onCloseBetSlip?.call();
  @override
  Future<void> restoreAfterTour() async => _onRestore?.call();
}
