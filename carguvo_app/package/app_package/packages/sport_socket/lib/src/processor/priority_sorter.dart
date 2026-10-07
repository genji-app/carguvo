import 'message_key.dart';
import '../utils/constants.dart';

class PrioritySorter {
  List<ExtractedKey> sort(List<ExtractedKey> keys) {
    if (keys.length <= 1) return keys;

    final sorted = List<ExtractedKey>.from(keys);
    sorted.sort(_compareByPriority);
    return sorted;
  }

  void sortInPlace(List<ExtractedKey> keys) {
    if (keys.length <= 1) return;
    keys.sort(_compareByPriority);
  }

  int _compareByPriority(ExtractedKey a, ExtractedKey b) {
    final priorityA = MessagePriority.getPriority(a.type);
    final priorityB = MessagePriority.getPriority(b.type);
    return priorityA.compareTo(priorityB);
  }

  int getPriority(String type) => MessagePriority.getPriority(type);

  bool shouldProcessFirst(String typeA, String typeB) {
    return getPriority(typeA) < getPriority(typeB);
  }

  Map<int, List<ExtractedKey>> groupByPriority(List<ExtractedKey> keys) {
    final groups = <int, List<ExtractedKey>>{};

    for (final key in keys) {
      final priority = getPriority(key.type);
      groups.putIfAbsent(priority, () => []).add(key);
    }

    return groups;
  }

  List<int> getSortedPriorityLevels(List<ExtractedKey> keys) {
    final levels = <int>{};
    for (final key in keys) {
      levels.add(getPriority(key.type));
    }
    final sorted = levels.toList()..sort();
    return sorted;
  }
}
