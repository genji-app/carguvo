library;

import 'dart:async';
import 'dart:convert';

import 'package:app_env/app_env.dart';

export 'package:game_taxonomy/game_taxonomy.dart'
    show ActivityGroup, ActivityGroupClassifier;

part 'src/card_last_join.dart';
part 'src/game_item_type.dart';
part 'src/game_launch_ui_failure.dart';
part 'src/lobby_category.dart';
part 'src/lobby_game.dart';
part 'src/manager.dart';
part 'src/manager_category.dart';
part 'src/manager_game_url.dart';
part 'src/manager_lobby_game.dart';
part 'src/manager_search.dart';
part 'src/manager_sun.dart';
part 'src/models.dart';
part 'src/play_decision.dart';
part 'src/sun_game.dart';

void Function(String message, {required bool isError})? providerGameManagerLog;
