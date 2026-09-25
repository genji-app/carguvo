part of 'game_card.dart';

class _GameCoverHoverable extends StatefulWidget {
  const _GameCoverHoverable({
    required this.imagePath,
    required this.gameName,
    required this.providerName,
    required this.tagHeight,
    required this.providerTagHeight,
    required this.borderRadius,
    this.cardWidth,
    this.gameId,
    this.tagPath,
    this.providerTagPath,
  });

  final String imagePath;
  final String gameName;
  final String providerName;
  final int? gameId;
  final String? tagPath;
  final String? providerTagPath;
  final double tagHeight;
  final double providerTagHeight;
  final double borderRadius;
  final double? cardWidth;

  @override
  State<_GameCoverHoverable> createState() => _GameCoverHoverableState();
}

class _GameCoverHoverableState extends State<_GameCoverHoverable> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: _GameCoverShell(
        borderRadius: widget.borderRadius,
        tagPath: widget.tagPath,
        providerTagPath: widget.providerTagPath,
        tagHeight: widget.tagHeight,
        providerTagHeight: widget.providerTagHeight,
        cardWidth: widget.cardWidth,
        gameId: widget.gameId,
        scale: _isHovered ? 1.05 : 1.0,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        image: GameAssetImage(
          imagePath: widget.imagePath,
          cacheWidth: GameCardLayout.cacheWidth,
          cacheHeight: GameCardLayout.cacheHeight,
          errorWidget: _GameCoverErrorFallback(
            gameName: widget.gameName,
            providerName: widget.providerName,
          ),
        ),
      ),
    );
  }
}

class _GameCoverStatic extends StatelessWidget {
  const _GameCoverStatic({
    required this.imagePath,
    required this.gameName,
    required this.providerName,
    required this.tagHeight,
    required this.providerTagHeight,
    required this.borderRadius,
    this.cardWidth,
    this.gameId,
    this.tagPath,
    this.providerTagPath,
  });

  final String imagePath;
  final String gameName;
  final String providerName;
  final int? gameId;
  final String? tagPath;
  final String? providerTagPath;
  final double tagHeight;
  final double providerTagHeight;
  final double borderRadius;
  final double? cardWidth;

  @override
  Widget build(BuildContext context) {
    return _GameCoverShell(
      gameId: gameId,
      cardWidth: cardWidth,
      borderRadius: borderRadius,
      tagPath: tagPath,
      providerTagPath: providerTagPath,
      tagHeight: tagHeight,
      providerTagHeight: providerTagHeight,
      image: GameAssetImage(
        imagePath: imagePath,
        fit: BoxFit.cover,
        cacheWidth: GameCardLayout.cacheWidth,
        cacheHeight: GameCardLayout.cacheHeight,
        errorWidget: _GameCoverErrorFallback(
          gameName: gameName,
          providerName: providerName,
        ),
      ),
    );
  }
}

class _GameCoverShell extends StatelessWidget {
  const _GameCoverShell({
    required this.image,
    required this.borderRadius,
    this.scale = 1.0,
    this.cardWidth,
    this.tagPath,
    this.providerTagPath,
    this.tagHeight = 0,
    this.providerTagHeight = 0,
    this.gameId,
    this.boxShadow,
  });

  final Widget image;
  final double borderRadius;
  final double scale;
  final String? tagPath;
  final String? providerTagPath;
  final double tagHeight;
  final double providerTagHeight;
  final double? cardWidth;
  final int? gameId;
  final List<BoxShadow>? boxShadow;

  @override
  Widget build(BuildContext context) {
    final innerStack = Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: GameCardLayout.imageBottomOffset,
          child: image,
        ),
        if (tagPath != null && tagPath!.isNotEmpty)
          Positioned(
            top: GameCardLayout.tagOffset,
            right: GameCardLayout.tagOffset,
            child: _GameTagIcon(tagPath: tagPath!, height: tagHeight),
          ),
        if (providerTagPath != null && providerTagPath!.isNotEmpty)
          Positioned(
            top: GameCardLayout.tagOffset,
            left: GameCardLayout.tagOffset,
            child: _GameTagIcon(
              tagPath: providerTagPath!,
              height: providerTagHeight,
            ),
          ),
      ],
    );

    final Widget visualBody = hasMouse
        ? RepaintBoundary(
            child: AnimatedScale(
              scale: scale,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              child: innerStack,
            ),
          )
        : innerStack;

    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        color: AppColorStyles.backgroundQuaternary,
        boxShadow: boxShadow,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          visualBody,
          if (gameId != null)
            Positioned(
              bottom: GameCardLayout.jackpotBottomOffset,
              left: GameCardLayout.jackpotHorizontalOffset,
              right: GameCardLayout.jackpotHorizontalOffset,
              child: GameCardJackpot(gameId: gameId!, cardWidth: cardWidth),
            ),
        ],
      ),
    );
  }
}

class _GameTagIcon extends StatelessWidget {
  const _GameTagIcon({required this.tagPath, required this.height});

  final String tagPath;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (tagPath.isEmpty) return const SizedBox.shrink();

    return GameAssetImage(
      imagePath: tagPath,
      height: height,
      fit: BoxFit.fitHeight,
      fadeIn: false,
    );
  }
}

class _GradientOverlay extends StatelessWidget {
  const _GradientOverlay();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.5, 0.85, 1.0],
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.4),
              Colors.black.withValues(alpha: 0.7),
            ],
          ),
        ),
      ),
    );
  }
}

class _GameCoverErrorFallback extends StatelessWidget {
  const _GameCoverErrorFallback({
    required this.gameName,
    required this.providerName,
  });

  final String gameName;
  final String providerName;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: AppColorStyles.backgroundQuaternary),
        const _GradientOverlay(),
        const Center(
          child: Icon(Icons.error_outline_rounded, color: Colors.grey),
        ),
        Positioned(
          bottom: 12,
          left: 8,
          right: 8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                gameName,
                overflow: TextOverflow.ellipsis,
                maxLines: 4,
                textAlign: TextAlign.center,
                style: AppTextStyles.labelLarge(
                  context: context,
                  color: AppColorStyles.contentPrimary,
                ).copyWith(height: 1.1, fontWeight: FontWeight.w800),
              ),
              const Gap(4),
              Text(
                providerName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTextStyles.labelXSmall(
                  context: context,
                  color: AppColorStyles.contentPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
