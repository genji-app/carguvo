import 'package:flutter/widgets.dart';

class VoltaMetrics {
  VoltaMetrics._();

  static const double tabletBreakpoint = 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).shortestSide >= tabletBreakpoint;

  static const double tabBarHeight = 30;
  static const double tabBarRadius = 1000;
  static const double tabActiveRadius = 89;

  static const double historyBlockHeight = 97;
  static const double historyCardRadius = 12;
  static const double historySideWidth = 55;

  static const int historyColumns = 12;
  static const int historyRows = 4;
  static const double historyDotSize = 14;
  static const double historyDotGapY = 4;

  static const double historyDotGapX = 10;

  static const double md5FieldRadius = 8;
  static const double md5CopySize = 28;
  static const double md5ActionRadius = 12;

  static const double gutter = 10;
}
