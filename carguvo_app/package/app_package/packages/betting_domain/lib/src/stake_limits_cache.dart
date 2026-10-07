library;

class StakeLimitsCache {
  StakeLimitsCache({this.ttl = const Duration(seconds: 30)});

  final Duration ttl;
  static const _maxEntries = 50;

  final Map<String, _Entry> _entries = {};

  String _key(String offerId, String selectionId, String displayOdds) =>
      '$offerId|$selectionId|$displayOdds';

  ({int minStake, int maxStake, int maxPayout})? lookup(
    String offerId,
    String selectionId,
    String displayOdds,
  ) {
    final e = _entries[_key(offerId, selectionId, displayOdds)];
    if (e == null) return null;
    if (DateTime.now().difference(e.at) > ttl) {
      _entries.remove(_key(offerId, selectionId, displayOdds));
      return null;
    }
    return (minStake: e.minStake, maxStake: e.maxStake, maxPayout: e.maxPayout);
  }

  void store(
    String offerId,
    String selectionId,
    String displayOdds, {
    required int minStake,
    required int maxStake,
    required int maxPayout,
  }) {
    if (_entries.length >= _maxEntries) {
      _entries.remove(_entries.keys.first);
    }
    _entries[_key(offerId, selectionId, displayOdds)] = _Entry(
      minStake: minStake,
      maxStake: maxStake,
      maxPayout: maxPayout,
      at: DateTime.now(),
    );
  }

  void clearOnStaleOffer() => _entries.clear();

  void clear() => _entries.clear();

  int get length => _entries.length;
}

class _Entry {
  const _Entry({
    required this.minStake,
    required this.maxStake,
    required this.maxPayout,
    required this.at,
  });
  final int minStake;
  final int maxStake;
  final int maxPayout;
  final DateTime at;
}
