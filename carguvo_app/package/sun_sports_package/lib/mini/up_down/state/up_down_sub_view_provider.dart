import 'package:flutter_riverpod/flutter_riverpod.dart';

enum UpDownSubView { none, guide, rank, history }

final upDownSubViewProvider = StateProvider.autoDispose<UpDownSubView>(
  (ref) => UpDownSubView.none,
);
