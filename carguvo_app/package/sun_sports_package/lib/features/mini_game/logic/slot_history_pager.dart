library;

import 'package:mini_game_protocol/mini_game_protocol.dart' as mp;
import 'package:sun_sports/core/utils/app_logger.dart';

export 'package:mini_game_protocol/mini_game_protocol.dart'
    show SlotHistoryChunk, SlotHistoryFetcher;

class SlotHistoryPager<T> extends mp.SlotHistoryPager<T> {
  static const int chunkSize = mp.SlotHistoryPager.chunkSize;
  static const int pageSize = mp.SlotHistoryPager.pageSize;

  SlotHistoryPager({
    required super.fetchChunk,
    required super.createdTimeOf,
    required super.sessionIdOf,
  }) : super(warnLog: AppLoggers.api.w);
}
