import 'dart:convert';

import 'package:betting_domain/betting_domain.dart' show betSlipPersistTtl;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sun_sports/features/parlay/domain/models/single_bet_data.dart';

class ParlayStorage {
  static const String _singleBetsKey = 'parlaySingleBets';
  static const String _lastSavedKey = 'parlayLastSaved';
  static const String _comboBetsKey = 'parlayComboBets';
  static const String _comboLastSavedKey = 'parlayComboLastSaved';

  static ParlayStorage? _instance;
  static ParlayStorage get instance => _instance ??= ParlayStorage._();
  ParlayStorage._();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<void> saveSingleBets(List<SingleBetData> bets) async {
    try {
      final prefs = await _preferences;

      if (bets.isEmpty) {
        await prefs.remove(_singleBetsKey);
        await prefs.remove(_lastSavedKey);
        debugPrint('[ParlayStorage] Cleared single bets from storage');
        return;
      }

      final jsonList = bets.map((bet) => bet.toJson()).toList();
      final jsonString = jsonEncode(jsonList);

      await prefs.setString(_singleBetsKey, jsonString);
      await prefs.setInt(_lastSavedKey, DateTime.now().millisecondsSinceEpoch);

      debugPrint('[ParlayStorage] Saved ${bets.length} single bets to storage');
    } catch (e, stackTrace) {
      debugPrint('[ParlayStorage] Error saving single bets: $e');
      debugPrint('[ParlayStorage] StackTrace: $stackTrace');
    }
  }

  Future<List<SingleBetData>> loadSingleBets() async {
    try {
      final prefs = await _preferences;
      final jsonString = prefs.getString(_singleBetsKey);

      if (jsonString == null || jsonString.isEmpty) {
        debugPrint('[ParlayStorage] No single bets found in storage');
        return [];
      }

      final lastSaved = prefs.getInt(_lastSavedKey) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      final maxAge = betSlipPersistTtl.inMilliseconds;

      if (now - lastSaved > maxAge) {
        debugPrint('[ParlayStorage] Single bets data is too old, clearing');
        await clear();
        return [];
      }

      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      final bets = jsonList
          .map((json) => SingleBetData.fromJson(json as Map<String, dynamic>))
          .toList();

      debugPrint(
        '[ParlayStorage] Loaded ${bets.length} single bets from storage',
      );
      return bets;
    } catch (e, stackTrace) {
      debugPrint('[ParlayStorage] Error loading single bets: $e');
      debugPrint('[ParlayStorage] StackTrace: $stackTrace');
      await clear();
      return [];
    }
  }

  Future<DateTime?> getLastSavedTime() async {
    final prefs = await _preferences;
    final timestamp = prefs.getInt(_lastSavedKey);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  Future<void> saveComboBets(List<SingleBetData> bets) async {
    try {
      final prefs = await _preferences;

      if (bets.isEmpty) {
        await prefs.remove(_comboBetsKey);
        await prefs.remove(_comboLastSavedKey);
        debugPrint('[ParlayStorage] Cleared combo bets from storage');
        return;
      }

      final jsonList = bets.map((bet) => bet.toJson()).toList();
      final jsonString = jsonEncode(jsonList);

      await prefs.setString(_comboBetsKey, jsonString);
      await prefs.setInt(
        _comboLastSavedKey,
        DateTime.now().millisecondsSinceEpoch,
      );

      debugPrint('[ParlayStorage] Saved ${bets.length} combo bets to storage');
    } catch (e, stackTrace) {
      debugPrint('[ParlayStorage] Error saving combo bets: $e');
      debugPrint('[ParlayStorage] StackTrace: $stackTrace');
    }
  }

  Future<List<SingleBetData>> loadComboBets() async {
    try {
      final prefs = await _preferences;
      final jsonString = prefs.getString(_comboBetsKey);

      if (jsonString == null || jsonString.isEmpty) {
        debugPrint('[ParlayStorage] No combo bets found in storage');
        return [];
      }

      final lastSaved = prefs.getInt(_comboLastSavedKey) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      final maxAge = betSlipPersistTtl.inMilliseconds;

      if (now - lastSaved > maxAge) {
        debugPrint('[ParlayStorage] Combo bets data is too old, clearing');
        await clearComboBets();
        return [];
      }

      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      final bets = jsonList
          .map((json) => SingleBetData.fromJson(json as Map<String, dynamic>))
          .toList();

      debugPrint(
        '[ParlayStorage] Loaded ${bets.length} combo bets from storage',
      );
      return bets;
    } catch (e, stackTrace) {
      debugPrint('[ParlayStorage] Error loading combo bets: $e');
      debugPrint('[ParlayStorage] StackTrace: $stackTrace');
      await clearComboBets();
      return [];
    }
  }

  Future<void> clearComboBets() async {
    final prefs = await _preferences;
    await prefs.remove(_comboBetsKey);
    await prefs.remove(_comboLastSavedKey);
  }

  Future<void> clear() async {
    final prefs = await _preferences;
    await prefs.remove(_singleBetsKey);
    await prefs.remove(_lastSavedKey);
    await prefs.remove(_comboBetsKey);
    await prefs.remove(_comboLastSavedKey);
  }

  @override
  String toString() {
    final count = _prefs?.getString(_singleBetsKey) != null
        ? 'has data'
        : 'empty';
    return 'ParlayStorage($count)';
  }
}
