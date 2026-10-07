part of 'game_card.dart';

class GameCardLayout {

  static const double minWidth = 108;
  static const double minHeight = 144;
  static const double maxWidth = minWidth;
  static const double maxHeight = minHeight;

  static const int cacheWidth = 360;
  static const int cacheHeight = 480;

  static const double spacing = 10;
  static const double horizontalPadding = 6;
  static const double cardAspectRatio = minWidth / minHeight;

  static int getColumns(double screenWidth) {
    return screenWidth >= 600 ? 5 : 3;
  }

  static double getCarouselViewportFraction(double screenWidth) {
    return 1.0 / getColumns(screenWidth);
  }

  static double calculateHeightFromWidth(double width) =>
      width / cardAspectRatio;

  static double getCardHeight(double width) => calculateHeightFromWidth(width);

  static double calculateChildAspectRatio(double availableWidth, int columns) {
    return cardAspectRatio;
  }

  static const double _designTagHeight = 22.0;
  static const double _designCardHeight = 176.79;

  static double tagHeight(double cardWidth) {
    final cardHeight = cardWidth / cardAspectRatio;
    return cardHeight * (_designTagHeight / _designCardHeight);
  }

  static double providerTagHeight(double tagH) => tagH;

  static const double tagOffset = -1.0;

  static const double imageBottomOffset = -1.0;

  static const double jackpotBottomOffset = -1.0;

  static const double jackpotHorizontalOffset = 0.0;

  static double borderRadius(double cardWidth) => cardWidth * (12.0 / 132.19);

  static const double baseDesignCardWidth = 132.19;

  static double jackpotIconSize(double cardWidth, {bool isMultiTier = false}) {
    final scale = (cardWidth / baseDesignCardWidth).clamp(0.75, 1.4);
    final baseSize = isMultiTier ? 8.5 : 11.5;
    return baseSize * scale;
  }

  static double jackpotFontSize(double cardWidth, {bool isMultiTier = false}) {
    final scale = (cardWidth / baseDesignCardWidth).clamp(0.75, 1.4);
    final baseSize = isMultiTier ? 11.5 : 11.5;
    return baseSize * scale;
  }

  static double jackpotVerticalPadding(
    double cardWidth, {
    bool isMultiTier = false,
  }) {
    final scale = (cardWidth / baseDesignCardWidth).clamp(0.75, 1.4);
    return (isMultiTier ? 1.2 : 1.8) * scale;
  }

  static double jackpotIconSpacing(
    double cardWidth, {
    bool isMultiTier = false,
  }) {
    final scale = (cardWidth / baseDesignCardWidth).clamp(0.75, 1.4);
    return (isMultiTier ? 1.5 : 2.0) * scale;
  }

  static double cardWidthFromScreen(double screenWidth) {
    final cols = getColumns(screenWidth);
    return (screenWidth - 2 * horizontalPadding - (cols - 1) * spacing) / cols;
  }

  static double tagHeightFromCardWidth(double cardWidth) =>
      tagHeight(cardWidth);

  static GameCardDimensions calculateDimensions(
    double parentWidth, {
    int? crossAxisCount,
  }) {
    final columns = crossAxisCount ?? getColumns(parentWidth);
    final availableWidth = parentWidth - (2 * horizontalPadding);
    final cardWidth = (availableWidth - (columns - 1) * spacing) / columns;
    final cardHeight = cardWidth / cardAspectRatio;
    return GameCardDimensions(
      columns: columns,
      cardWidth: cardWidth,
      cardHeight: cardHeight,
      childAspectRatio: cardAspectRatio,
    );
  }
}

class GameCardDimensions {
  const GameCardDimensions({
    required this.columns,
    required this.cardWidth,
    required this.cardHeight,
    required this.childAspectRatio,
  });

  final int columns;
  final double cardWidth;
  final double cardHeight;
  final double childAspectRatio;
}
