import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/services/provider_game/jackpot_provider.dart';
import 'package:sun_sports/features/bet_detail/presentation/providers/detail_swap_guard_provider.dart';
import 'package:sun_sports/features/parlay/presentation/mobile/providers/parlay_state_provider.dart';
import 'package:sun_sports/features/sport/presentation/providers/league_provider.dart';
import 'package:sun_sports/features/sport/presentation/providers/market_status_provider.dart';
import 'package:sun_sports/features/sport/presentation/providers/match_notice_provider.dart';
import 'package:sun_sports/features/sport/presentation/providers/odds_change_provider.dart';
import 'package:sun_sports/features/sport/presentation/providers/vibrating_odds_provider.dart';
import 'package:sun_sports/core/perf/frame_monitor.dart';

final class PerfProviderObserver extends ProviderObserver {
  PerfProviderObserver();

  static final Map<Object, String> _names = {
    isMarketSuspendedProvider: 'mktSuspended',
    isEventSuspendedProvider: 'evtSuspended',
    marketStatusProvider: 'marketStatus',
    isBetInSlipProvider: 'inSlip',
    inSlipKeysProvider: 'inSlipKeys',
    oddsDirectionProvider: 'oddsDirection',
    oddsValueProvider: 'oddsValue',
    oddsChangeProvider: 'oddsChange',
    isVibratingProvider: 'vibrating',
    vibratingOddsProvider: 'vibratingOdds',
    matchNoticeProvider: 'matchNotice',
    detailSwapGuardProvider: 'swapGuard',
    oddsStyleProvider: 'oddsStyle',
    jackpotForGameProvider: 'jackpotForGame',
    jackpotStreamProvider: 'jackpotStream',
  };

  static String _name(ProviderBase<Object?> provider) {
    final family = provider.from;
    final known =
        (family != null ? _names[family] : null) ?? _names[provider];
    if (known != null) return known;
    final type = provider.name ?? provider.runtimeType.toString();
    final generic = type.indexOf('<');
    return generic > 0 ? type.substring(0, generic) : type;
  }

  @override
  void didAddProvider(
    ProviderBase<Object?> provider,
    Object? value,
    ProviderContainer container,
  ) {
    PerfCounters.hit('+${_name(provider)}');
    PerfCounters.hit('+*');
  }

  @override
  void didDisposeProvider(
    ProviderBase<Object?> provider,
    ProviderContainer container,
  ) {
    PerfCounters.hit('-${_name(provider)}');
    PerfCounters.hit('-*');
  }

  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    PerfCounters.hit('~${_name(provider)}');
    PerfCounters.hit('~*');
  }
}
