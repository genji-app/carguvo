import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/services/models/api_v2/event_model_v2.dart';
import 'package:sun_sports/core/services/models/api_v2/league_model_v2.dart';

final selectedEventV2Provider = StateProvider<EventModelV2?>((ref) => null);

final selectedLeagueV2Provider = StateProvider<LeagueModelV2?>((ref) => null);
