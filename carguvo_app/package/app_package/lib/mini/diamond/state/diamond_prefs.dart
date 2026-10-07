import 'package:mini_game_protocol/mini_game_protocol.dart'
    show slotDecodeLinesOrNull, slotEncodeLines;
import 'package:shared_preferences/shared_preferences.dart';

class DiamondPrefs {
  static const String _betKey = 'diamond_bet';
  static const String _linesKey = 'diamond_lines_mask';
  static const String _turboKey = 'diamond_turbo';
  static const String _autoKey = 'diamond_auto';

  static const String _autoUidKey = 'diamond_auto_uid';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _p async =>
      _prefs ??= await SharedPreferences.getInstance();

  Future<DiamondSavedPrefs> load() async {
    try {
      final p = await _p;
      final mask = p.getInt(_linesKey);
      return DiamondSavedPrefs(
        bet: p.getInt(_betKey),
        lines: slotDecodeLinesOrNull(mask),
        turbo: p.getBool(_turboKey),
        auto: p.getBool(_autoKey),
        autoUid: p.getString(_autoUidKey),
      );
    } catch (_) {
      return const DiamondSavedPrefs();
    }
  }

  Future<void> saveBet(int bet) => _guard((p) => p.setInt(_betKey, bet));

  Future<void> saveLines(List<int> lines) =>
      _guard((p) => p.setInt(_linesKey, _encodeLines(lines)));

  Future<void> saveTurbo(bool value) =>
      _guard((p) => p.setBool(_turboKey, value));

  Future<void> saveAuto(bool value, {String? uid}) => _guard((p) async {
        await p.setBool(_autoKey, value);
        if (value && uid != null && uid.isNotEmpty) {
          await p.setString(_autoUidKey, uid);
        } else {
          await p.remove(_autoUidKey);
        }
      });

  Future<void> _guard(Future<void> Function(SharedPreferences) op) async {
    try {
      await op(await _p);
    } catch (_) {
    }
  }

  int _encodeLines(List<int> lines) => slotEncodeLines(lines);
}

class DiamondSavedPrefs {
  final int? bet;
  final List<int>? lines;
  final bool? turbo;
  final bool? auto;

  final String? autoUid;

  const DiamondSavedPrefs({
    this.bet,
    this.lines,
    this.turbo,
    this.auto,
    this.autoUid,
  });
}
