import 'package:meta/meta.dart';

@immutable
class JackpotTierState {
  const JackpotTierState({
    required this.betting,
    required this.realBalance,
    required this.displayBalance,
    this.ratePerMs = 0.0,
  });

  final num betting;

  final num realBalance;

  final num displayBalance;

  final double ratePerMs;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JackpotTierState &&
          runtimeType == other.runtimeType &&
          betting == other.betting &&
          realBalance == other.realBalance &&
          displayBalance == other.displayBalance &&
          ratePerMs == other.ratePerMs;

  @override
  int get hashCode => Object.hash(betting, realBalance, displayBalance, ratePerMs);

  @override
  String toString() =>
      'JackpotTierState(betting: $betting, realBalance: $realBalance, displayBalance: $displayBalance, ratePerMs: $ratePerMs)';
}

@immutable
class JackpotDisplayState {
  const JackpotDisplayState({
    required this.gameId,
    required this.tiers,
    this.isLoading = false,
    this.hasError = false,
    this.lastUpdated,
  });

  final int gameId;

  final List<JackpotTierState> tiers;

  final bool isLoading;

  final bool hasError;

  final DateTime? lastUpdated;

  JackpotDisplayState copyWith({
    int? gameId,
    List<JackpotTierState>? tiers,
    bool? isLoading,
    bool? hasError,
    DateTime? lastUpdated,
  }) {
    return JackpotDisplayState(
      gameId: gameId ?? this.gameId,
      tiers: tiers ?? this.tiers,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JackpotDisplayState &&
          runtimeType == other.runtimeType &&
          gameId == other.gameId &&
          _listEquals(tiers, other.tiers) &&
          isLoading == other.isLoading &&
          hasError == other.hasError &&
          lastUpdated == other.lastUpdated;

  @override
  int get hashCode => Object.hash(gameId, Object.hashAll(tiers), isLoading, hasError, lastUpdated);

  @override
  String toString() =>
      'JackpotDisplayState(gameId: $gameId, tiers: $tiers, isLoading: $isLoading, hasError: $hasError, lastUpdated: $lastUpdated)';
}

extension JackpotDisplayStateX on JackpotDisplayState {
  JackpotTierState? get grandTier {
    for (final tier in tiers) {
      if (tier.betting == 0 && tier.displayBalance > 0) {
        return tier;
      }
    }
    return null;
  }

  List<JackpotTierState> get tierJackpots {
    final list = tiers.where((t) => t.betting > 0 && t.displayBalance > 0).toList();
    list.sort((a, b) => b.betting.compareTo(a.betting));
    return list;
  }

  JackpotTierState? get primaryTier => grandTier ?? tierJackpots.firstOrNull;

  List<JackpotTierState> get displayTiers {
    if (grandTier != null) {
      return [grandTier!];
    }
    final active = tiers.where((t) => t.displayBalance > 0).toList();
    if (active.length <= 3) {
      return active;
    }

    final standardTiers = active.where((t) => _isPowerOfTen(t.betting)).toList();
    if (standardTiers.isNotEmpty) {
      return standardTiers.take(3).toList();
    }
    return active.take(3).toList();
  }

  static bool _isPowerOfTen(num n) {
    if (n <= 0) return false;
    double val = n.toDouble();
    while (val >= 10.0) {
      val /= 10.0;
    }
    return (val - 1.0).abs() < 1e-5;
  }

  int get activeTierCount => tiers.where((t) => t.displayBalance > 0).length;

  bool get hasActiveJackpot => tiers.any((t) => t.displayBalance > 0);
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
