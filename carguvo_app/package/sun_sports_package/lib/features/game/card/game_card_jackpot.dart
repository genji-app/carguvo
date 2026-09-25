part of 'game_card.dart';

class GameCardJackpot extends StatelessWidget {
  const GameCardJackpot({required this.gameId, this.cardWidth, super.key});

  final int gameId;

  final double? cardWidth;

  @visibleForTesting
  static void clearMemoryCache() =>
      _GameCardJackpotBodyState._memoryCache.clear();

  @override
  Widget build(BuildContext context) {
    return ViewportVisibilityBuilder(
      builder: (context, visible) => _GameCardJackpotBody(
        gameId: gameId,
        cardWidth: cardWidth,
        live: visible,
      ),
    );
  }
}

class _GameCardJackpotBody extends ConsumerStatefulWidget {
  const _GameCardJackpotBody({
    required this.gameId,
    required this.cardWidth,
    required this.live,
  });

  final int gameId;
  final double? cardWidth;

  final bool live;

  @override
  ConsumerState<_GameCardJackpotBody> createState() =>
      _GameCardJackpotBodyState();
}

class _GameCardJackpotBodyState extends ConsumerState<_GameCardJackpotBody> {
  static final Map<int, JackpotDisplayState> _memoryCache = {};
  static const int _maxMemoryCacheSize = 100;

  static void _saveToMemoryCache(int gameId, JackpotDisplayState state) {
    if (_memoryCache.length >= _maxMemoryCacheSize &&
        !_memoryCache.containsKey(gameId)) {
      _memoryCache.remove(_memoryCache.keys.first);
    }
    _memoryCache[gameId] = state;
  }

  JackpotDisplayState? _last;

  @override
  void initState() {
    super.initState();
    _last = _memoryCache[widget.gameId];
    TabSwipeActivity.listenable.addListener(_onActivityChanged);
    ScrollAwareController.instance.addListener(_onActivityChanged);
  }

  void _onActivityChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    TabSwipeActivity.listenable.removeListener(_onActivityChanged);
    ScrollAwareController.instance.removeListener(_onActivityChanged);
    super.dispose();
  }

  @override
  void didUpdateWidget(_GameCardJackpotBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.gameId != widget.gameId) {
      _last = _memoryCache[widget.gameId];
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool swiping = TabSwipeActivity.isActive;
    final bool scrolling = ScrollAwareController.instance.isScrolling;
    if (widget.live && !swiping && !scrolling) {
      _last = ref.watch(jackpotForGameProvider(widget.gameId));
      if (_last != null && _last!.hasActiveJackpot) {
        _saveToMemoryCache(widget.gameId, _last!);
      } else {
        _memoryCache.remove(widget.gameId);
      }
    } else if (_last == null) {
      _last =
          _memoryCache[widget.gameId] ??
          ref.read(jackpotForGameProvider(widget.gameId));
      if (_last != null && _last!.hasActiveJackpot) {
        _saveToMemoryCache(widget.gameId, _last!);
      } else {
        _memoryCache.remove(widget.gameId);
      }
    }
    final state = _last;

    if (state == null || !state.hasActiveJackpot) {
      return const SizedBox.shrink();
    }

    final config = ref.read(jackpotTickerConfigProvider);

    return GameCardJackpotView(
      state: state,
      cardWidth: widget.cardWidth,
      animationDuration: config.tickInterval,
    );
  }
}

class GameCardJackpotView extends StatelessWidget {
  const GameCardJackpotView({
    required this.state,
    this.cardWidth,
    this.animationDuration = const Duration(milliseconds: 60),
    super.key,
  });

  final JackpotDisplayState state;
  final double? cardWidth;
  final Duration animationDuration;

  static final NumberFormat _formatter = NumberFormat('#,###');

  @override
  Widget build(BuildContext context) {
    if (!state.hasActiveJackpot) {
      return const SizedBox.shrink();
    }

    final displayTiers = state.displayTiers;
    final isSingleTier = displayTiers.length == 1;

    final double effectiveWidth =
        cardWidth ?? GameCardLayout.baseDesignCardWidth;
    final double iconSize = GameCardLayout.jackpotIconSize(
      effectiveWidth,
      isMultiTier: !isSingleTier,
    );
    final double fontSize = GameCardLayout.jackpotFontSize(
      effectiveWidth,
      isMultiTier: !isSingleTier,
    );
    final double iconSpacing = GameCardLayout.jackpotIconSpacing(
      effectiveWidth,
      isMultiTier: !isSingleTier,
    );
    final double vPadding = GameCardLayout.jackpotVerticalPadding(
      effectiveWidth,
      isMultiTier: !isSingleTier,
    );

    return RepaintBoundary(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: isSingleTier ? 4 : 3,
          vertical: vPadding,
        ),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.45, 1.0],
            colors: [AppColors.gray600, AppColors.gray800, AppColors.gray950],
          ),
          border: Border(top: BorderSide(color: AppColors.gray500, width: 0.8)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: isSingleTier
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          children: displayTiers.map((tier) {
            return _JackpotTierRow(
              tier: tier,
              formatter: _formatter,
              iconSize: iconSize,
              fontSize: fontSize,
              iconSpacing: iconSpacing,
              animationDuration: animationDuration,
              isSingleTier: isSingleTier,
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _JackpotTierRow extends StatefulWidget {
  const _JackpotTierRow({
    required this.tier,
    required this.formatter,
    required this.iconSize,
    required this.fontSize,
    required this.iconSpacing,
    this.animationDuration = const Duration(milliseconds: 60),
    this.isSingleTier = false,
  });

  final JackpotTierState tier;
  final NumberFormat formatter;
  final double iconSize;
  final double fontSize;
  final double iconSpacing;
  final Duration animationDuration;
  final bool isSingleTier;

  static final Map<double, Widget> _currencyIcons = {};

  @override
  State<_JackpotTierRow> createState() => _JackpotTierRowState();
}

class _JackpotTierRowState extends State<_JackpotTierRow> {
  int? _lastInt;
  String? _lastFormatted;

  @override
  Widget build(BuildContext context) {
    final textWidget = FittedBox(
      fit: BoxFit.scaleDown,
      alignment: widget.isSingleTier ? Alignment.center : Alignment.centerLeft,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(end: widget.tier.displayBalance.toDouble()),
        duration: widget.animationDuration,
        curve: Curves.linear,
        builder: (context, animatedValue, _) {
          final int rounded = animatedValue.round();
          if (rounded != _lastInt) {
            _lastInt = rounded;
            _lastFormatted = widget.formatter.format(rounded);
          }
          final formattedNumber = _lastFormatted ?? '';

          return GradientText(
            formattedNumber,
            gradient: GradientText.gold,
            textAlign: widget.isSingleTier ? TextAlign.center : TextAlign.start,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: widget.fontSize,
              height: widget.isSingleTier ? 1.15 : 1.05,
            ),
            maxLines: 1,
          );
        },
      ),
    );

    return Row(
      mainAxisSize: widget.isSingleTier ? MainAxisSize.min : MainAxisSize.max,
      mainAxisAlignment: widget.isSingleTier
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _JackpotTierRow._currencyIcons.putIfAbsent(
          widget.iconSize,
          () => ImageHelper.load(
            path: AppIcons.iconCurrencyUnit,
            width: widget.iconSize,
            height: widget.iconSize,
            fit: BoxFit.contain,
          ),
        ),
        Gap(widget.iconSpacing),
        if (widget.isSingleTier)
          Flexible(child: textWidget)
        else
          Expanded(child: textWidget),
      ],
    );
  }
}
