import 'package:meta/meta.dart';

@immutable
class JackpotTickerConfig {
  const JackpotTickerConfig({
    this.tier100Rate = 0.08,
    this.tier1kRate = 0.40,
    this.tier10kRate = 1.80,
    this.tier100kRate = 5.00,
    this.grandMegaRate = 4.50,
    this.grandMajorRate = 1.80,
    this.grandMinorRate = 0.60,
    this.grandMiniRate = 0.15,
    this.tickInterval = const Duration(milliseconds: 60),
    this.pollInterval = const Duration(seconds: 30),
    this.maxDriftThreshold = 50000,
    this.maxRatePerMs = 50.0,
    this.maxExtrapolation = const Duration(seconds: 120),
  });

  const JackpotTickerConfig.hyperVivid({
    this.tier100Rate = 0.12,
    this.tier1kRate = 0.60,
    this.tier10kRate = 2.50,
    this.tier100kRate = 6.00,
    this.grandMegaRate = 6.00,
    this.grandMajorRate = 2.50,
    this.grandMinorRate = 0.80,
    this.grandMiniRate = 0.25,
    this.tickInterval = const Duration(milliseconds: 40),
    this.pollInterval = const Duration(seconds: 30),
    this.maxDriftThreshold = 50000,
    this.maxRatePerMs = 50.0,
    this.maxExtrapolation = const Duration(seconds: 120),
  });

  const JackpotTickerConfig.vivid({
    this.tier100Rate = 0.08,
    this.tier1kRate = 0.40,
    this.tier10kRate = 1.80,
    this.tier100kRate = 5.00,
    this.grandMegaRate = 4.50,
    this.grandMajorRate = 1.80,
    this.grandMinorRate = 0.60,
    this.grandMiniRate = 0.15,
    this.tickInterval = const Duration(milliseconds: 60),
    this.pollInterval = const Duration(seconds: 30),
    this.maxDriftThreshold = 50000,
    this.maxRatePerMs = 50.0,
    this.maxExtrapolation = const Duration(seconds: 120),
  });

  const JackpotTickerConfig.moderate({
    this.tier100Rate = 0.03,
    this.tier1kRate = 0.15,
    this.tier10kRate = 0.60,
    this.tier100kRate = 1.50,
    this.grandMegaRate = 1.50,
    this.grandMajorRate = 0.60,
    this.grandMinorRate = 0.20,
    this.grandMiniRate = 0.05,
    this.tickInterval = const Duration(milliseconds: 100),
    this.pollInterval = const Duration(seconds: 30),
    this.maxDriftThreshold = 50000,
    this.maxRatePerMs = 50.0,
    this.maxExtrapolation = const Duration(seconds: 120),
  });

  const JackpotTickerConfig.lowPower({
    this.tier100Rate = 0.01,
    this.tier1kRate = 0.05,
    this.tier10kRate = 0.20,
    this.tier100kRate = 0.50,
    this.grandMegaRate = 0.50,
    this.grandMajorRate = 0.20,
    this.grandMinorRate = 0.10,
    this.grandMiniRate = 0.02,
    this.tickInterval = const Duration(milliseconds: 250),
    this.pollInterval = const Duration(seconds: 45),
    this.maxDriftThreshold = 50000,
    this.maxRatePerMs = 50.0,
    this.maxExtrapolation = const Duration(seconds: 120),
  });

  final double tier100Rate;

  final double tier1kRate;

  final double tier10kRate;

  final double tier100kRate;

  final double grandMegaRate;

  final double grandMajorRate;

  final double grandMinorRate;

  final double grandMiniRate;

  final Duration tickInterval;

  final Duration pollInterval;

  final num maxDriftThreshold;

  final double maxRatePerMs;

  final Duration maxExtrapolation;

  double estimateInitialRate(num balance, {num? betting}) {
    if (balance <= 0) return 0.0;

    if (betting != null && betting > 0) {
      if (betting <= 100) return tier100Rate;
      if (betting <= 1000) return tier1kRate;
      if (betting <= 10000) return tier10kRate;
      return tier100kRate;
    }

    if (balance >= 1000000000) return grandMegaRate;
    if (balance >= 100000000) return grandMajorRate;
    if (balance >= 10000000) return grandMinorRate;
    return grandMiniRate;
  }

  JackpotTickerConfig copyWith({
    double? tier100Rate,
    double? tier1kRate,
    double? tier10kRate,
    double? tier100kRate,
    double? grandMegaRate,
    double? grandMajorRate,
    double? grandMinorRate,
    double? grandMiniRate,
    Duration? tickInterval,
    Duration? pollInterval,
    num? maxDriftThreshold,
    double? maxRatePerMs,
  }) {
    return JackpotTickerConfig(
      tier100Rate: tier100Rate ?? this.tier100Rate,
      tier1kRate: tier1kRate ?? this.tier1kRate,
      tier10kRate: tier10kRate ?? this.tier10kRate,
      tier100kRate: tier100kRate ?? this.tier100kRate,
      grandMegaRate: grandMegaRate ?? this.grandMegaRate,
      grandMajorRate: grandMajorRate ?? this.grandMajorRate,
      grandMinorRate: grandMinorRate ?? this.grandMinorRate,
      grandMiniRate: grandMiniRate ?? this.grandMiniRate,
      tickInterval: tickInterval ?? this.tickInterval,
      pollInterval: pollInterval ?? this.pollInterval,
      maxDriftThreshold: maxDriftThreshold ?? this.maxDriftThreshold,
      maxRatePerMs: maxRatePerMs ?? this.maxRatePerMs,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JackpotTickerConfig &&
          runtimeType == other.runtimeType &&
          tier100Rate == other.tier100Rate &&
          tier1kRate == other.tier1kRate &&
          tier100kRate == other.tier100kRate &&
          tier10kRate == other.tier10kRate &&
          grandMegaRate == other.grandMegaRate &&
          grandMajorRate == other.grandMajorRate &&
          grandMinorRate == other.grandMinorRate &&
          grandMiniRate == other.grandMiniRate &&
          tickInterval == other.tickInterval &&
          pollInterval == other.pollInterval &&
          maxDriftThreshold == other.maxDriftThreshold &&
          maxRatePerMs == other.maxRatePerMs;

  @override
  int get hashCode => Object.hash(
    tier100Rate,
    tier1kRate,
    tier10kRate,
    tier100kRate,
    grandMegaRate,
    grandMajorRate,
    grandMinorRate,
    grandMiniRate,
    tickInterval,
    pollInterval,
    maxDriftThreshold,
    maxRatePerMs,
  );

  @override
  String toString() =>
      'JackpotTickerConfig(tier100: $tier100Rate, tier1k: $tier1kRate, tier10k: $tier10kRate, grandMega: $grandMegaRate, tick: $tickInterval)';
}

class JackpotTicker {
  JackpotTicker({
    JackpotTickerConfig config = const JackpotTickerConfig(),
    double? maxRatePerMs,
    num? maxDriftThreshold,
    Duration? maxExtrapolation,
  }) : _config = config,
       _maxRatePerMs = maxRatePerMs ?? config.maxRatePerMs,
       _maxDriftThreshold = maxDriftThreshold ?? config.maxDriftThreshold,
       _maxExtrapolationMs =
           (maxExtrapolation ?? config.maxExtrapolation).inMilliseconds;

  static const double kDefaultMaxRatePerMs = 50.0;

  static const num kDefaultMaxDriftThreshold = 50000;

  final JackpotTickerConfig _config;
  final double _maxRatePerMs;
  final num _maxDriftThreshold;

  final int _maxExtrapolationMs;

  num _baseValue = 0;
  double _ratePerMs = 0.0;
  DateTime _baseTime = DateTime.now();
  bool _isFrozen = false;

  void updateFromApi(num newValue, {num? betting}) {
    final now = DateTime.now();
    final elapsedMs = now.difference(_baseTime).inMilliseconds;

    if (elapsedMs > 0 && _baseValue > 0) {
      if (newValue >= _baseValue) {
        final rawRate = (newValue - _baseValue) / elapsedMs;
        _ratePerMs = rawRate.clamp(0.0, _maxRatePerMs);
      } else {
        _ratePerMs = 0.0;
      }
    } else if (newValue > 0) {
      _ratePerMs = _config.estimateInitialRate(newValue, betting: betting);
    }

    _baseValue = newValue;
    _baseTime = now;
    _isFrozen = false;
  }

  void freezeRate() {
    _ratePerMs = 0.0;
    _isFrozen = true;
  }

  num get displayValue {
    if (_isFrozen || _ratePerMs <= 0) {
      return _baseValue;
    }
    final elapsedMs = DateTime.now().difference(_baseTime).inMilliseconds;
    final capped = _maxExtrapolationMs;
    if (capped > 0 && elapsedMs > capped) {
      return _baseValue + (_ratePerMs * capped);
    }
    return _baseValue + (_ratePerMs * elapsedMs);
  }

  num get realBalance => _baseValue;

  double get ratePerMs => _ratePerMs;

  bool hasDriftExceeded(num realBalance) {
    if (_baseValue <= 0) return false;
    return (displayValue - realBalance).abs() > _maxDriftThreshold;
  }

  void forceCorrect(num targetBalance, {num? betting}) {
    _baseValue = targetBalance;
    _baseTime = DateTime.now();
    _ratePerMs = _config.estimateInitialRate(targetBalance, betting: betting);
  }
}
