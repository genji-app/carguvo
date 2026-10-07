library;

import 'package:flutter/foundation.dart';

import 'stake_keypad_math.dart';

typedef StakeKeypadChanged = void Function(int value, StakeKey key);

class StakeKeypadController extends ChangeNotifier {
  StakeKeypadController._();

  static final StakeKeypadController instance = StakeKeypadController._();

  static const String popupId = 'bdp';
  static const String slipComboId = 'slip:combo';
  static String slipId(String selectionKey) => 'slip:$selectionKey';

  String? _activeId;
  StakeDraft _draft = const StakeDraft(0);
  StakeKeypadChanged? _onChanged;

  String? get activeId => _activeId;
  bool isActive(String id) => _activeId == id;

  int get value => _draft.value;
  bool get selectAll => _draft.selectAll;

  void open(String id, {required int value, required StakeKeypadChanged onChanged}) {
    _onChanged = onChanged;
    if (_activeId == id) {
      if (!_draft.selectAll) return;
      _draft = StakeDraft(_draft.value);
      notifyListeners();
      return;
    }
    _activeId = id;
    _draft = StakeDraft(value, selectAll: value > 0);
    notifyListeners();
  }

  void rebind(String id, StakeKeypadChanged onChanged) {
    if (_activeId == id) _onChanged = onChanged;
  }

  void adopt(String id, int value) {
    if (_activeId != id || value == _draft.value) return;
    _draft = StakeDraft(value, selectAll: _draft.selectAll);
  }

  void press(StakeKey key, {required int maxStake, required int balance}) {
    if (_activeId == null) return;
    if (key is StakeDoneKey) {
      close();
      return;
    }
    final next = StakeKeypadMath.apply(
      _draft,
      key,
      maxStake: maxStake,
      balance: balance,
    );
    final changed = next.value != _draft.value;
    final selectionChanged = next.selectAll != _draft.selectAll;
    _draft = next;
    if (changed) _onChanged?.call(next.value, key);
    if (selectionChanged) notifyListeners();
  }

  void close() {
    if (_activeId == null) return;
    _activeId = null;
    _onChanged = null;
    _draft = const StakeDraft(0);
    notifyListeners();
  }

  void closeId(String id) {
    if (_activeId == id) close();
  }
}
