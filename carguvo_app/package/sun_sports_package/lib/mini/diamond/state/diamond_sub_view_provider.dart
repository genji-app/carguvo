import 'package:flutter_riverpod/flutter_riverpod.dart';

enum DiamondSubView { none, lines, rank, history, guide }

final diamondSubViewProvider = StateProvider.autoDispose<DiamondSubView>(
  (ref) => DiamondSubView.none,
);
