import 'package:flutter/foundation.dart';

abstract final class TabSwipeActivity {
  static final ValueNotifier<bool> listenable = ValueNotifier<bool>(false);

  static final Set<Object> _owners = <Object>{};

  static bool get isActive => listenable.value;

  static void update(Object owner, {required bool active}) {
    final bool changed = active ? _owners.add(owner) : _owners.remove(owner);
    if (changed) listenable.value = _owners.isNotEmpty;
  }

  static bool isOwnedBy(Object owner) => _owners.contains(owner);

  static void release(Object owner) => update(owner, active: false);
}
