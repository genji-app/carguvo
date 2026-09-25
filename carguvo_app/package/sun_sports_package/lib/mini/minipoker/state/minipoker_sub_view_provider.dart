import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sun_sports/mini/minipoker/sub_views/minipoker_sub_view_scaffold.dart';

final minipokerSubViewProvider = StateProvider.autoDispose<MinipokerSubView?>(
  (ref) => null,
);
