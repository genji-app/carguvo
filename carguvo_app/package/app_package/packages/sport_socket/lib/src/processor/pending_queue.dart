typedef ThresholdExceededCallback = void Function(
    int currentSize, int threshold);

class PendingMessage {
  final String type;

  final Map<String, dynamic> data;

  final int parentId;

  final DateTime timestamp;

  int retryCount;

  PendingMessage({
    required this.type,
    required this.data,
    required this.parentId,
    DateTime? timestamp,
    this.retryCount = 0,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() {
    return 'PendingMessage(type: $type, parentId: $parentId, '
        'retries: $retryCount, age: ${DateTime.now().difference(timestamp).inSeconds}s)';
  }
}

class PendingQueue {
  final Map<int, List<PendingMessage>> _pendingByParent = {};

  final int _maxSize;

  final Duration _expirationTime;

  int _totalCount = 0;

  int _droppedCount = 0;

  int _expiredCount = 0;

  ThresholdExceededCallback? onThresholdExceeded;

  int? _lastTriggeredThreshold;

  PendingQueue({
    int maxSize = 5000,
    Duration expirationTime = const Duration(seconds: 10),
  })  : _maxSize = maxSize,
        _expirationTime = expirationTime;

  int get length => _totalCount;

  bool get isEmpty => _totalCount == 0;

  bool get isFull => _totalCount >= _maxSize;

  int get droppedCount => _droppedCount;

  int get expiredCount => _expiredCount;

  int get parentCount => _pendingByParent.length;

  bool addPending(int parentId, PendingMessage message) {
    if (_totalCount >= _maxSize) {
      _dropOldest();
    }

    _pendingByParent.putIfAbsent(parentId, () => []).add(message);
    _totalCount++;
    return true;
  }

  bool addPendingParsed({
    required String type,
    required Map<String, dynamic> data,
    required int parentId,
  }) {
    return addPending(
      parentId,
      PendingMessage(type: type, data: data, parentId: parentId),
    );
  }

  bool hasPendingFor(int parentId) {
    final list = _pendingByParent[parentId];
    return list != null && list.isNotEmpty;
  }

  int pendingCountFor(int parentId) {
    return _pendingByParent[parentId]?.length ?? 0;
  }

  List<PendingMessage> flushForParent(int parentId) {
    final pending = _pendingByParent.remove(parentId);
    if (pending != null) {
      _totalCount -= pending.length;
    }
    return pending ?? const [];
  }

  List<PendingMessage> peekForParent(int parentId) {
    return _pendingByParent[parentId] ?? const [];
  }

  int cleanupExpired() {
    final now = DateTime.now();
    var removedCount = 0;

    _pendingByParent.removeWhere((parentId, messages) {
      messages.removeWhere((msg) {
        final expired = now.difference(msg.timestamp) > _expirationTime;
        if (expired) {
          removedCount++;
        }
        return expired;
      });
      return messages.isEmpty;
    });

    _totalCount -= removedCount;
    _expiredCount += removedCount;
    return removedCount;
  }

  void _dropOldest() {
    if (_pendingByParent.isEmpty) return;

    DateTime? oldestTime;
    int? oldestParent;
    int oldestIndex = 0;

    for (final entry in _pendingByParent.entries) {
      for (var i = 0; i < entry.value.length; i++) {
        final msg = entry.value[i];
        if (oldestTime == null || msg.timestamp.isBefore(oldestTime)) {
          oldestTime = msg.timestamp;
          oldestParent = entry.key;
          oldestIndex = i;
        }
      }
    }

    if (oldestParent != null) {
      final list = _pendingByParent[oldestParent]!;
      list.removeAt(oldestIndex);
      _totalCount--;
      _droppedCount++;

      if (list.isEmpty) {
        _pendingByParent.remove(oldestParent);
      }
    }
  }

  void clear() {
    _pendingByParent.clear();
    _totalCount = 0;
  }

  void resetStats() {
    _droppedCount = 0;
    _expiredCount = 0;
  }

  Iterable<int> get pendingParentIds => _pendingByParent.keys;

  Set<int> get waitingParentIds => _pendingByParent.keys.toSet();

  bool exceedsThreshold(int threshold) {
    return _totalCount >= threshold;
  }

  void checkAndNotifyThreshold(int threshold) {
    if (_totalCount >= threshold && _lastTriggeredThreshold != threshold) {
      _lastTriggeredThreshold = threshold;
      onThresholdExceeded?.call(_totalCount, threshold);
    } else if (_totalCount < threshold) {
      _lastTriggeredThreshold = null;
    }
  }

  List<PendingMessage> flushAll() {
    final allMessages = <PendingMessage>[];

    for (final messages in _pendingByParent.values) {
      allMessages.addAll(messages);
    }

    _pendingByParent.clear();
    _totalCount = 0;
    _lastTriggeredThreshold = null;

    return allMessages;
  }

  List<PendingMessage> flushByParents(Set<int> existingParentIds) {
    final flushed = <PendingMessage>[];
    final parentsToFlush = _pendingByParent.keys
        .where((id) => existingParentIds.contains(id))
        .toList();

    for (final parentId in parentsToFlush) {
      final messages = _pendingByParent.remove(parentId);
      if (messages != null) {
        flushed.addAll(messages);
        _totalCount -= messages.length;
      }
    }

    if (flushed.isNotEmpty) {
      _lastTriggeredThreshold = null;
    }

    return flushed;
  }

  int removeByParent(int parentId) {
    final messages = _pendingByParent.remove(parentId);
    if (messages != null) {
      _totalCount -= messages.length;
      _expiredCount += messages.length;
      _lastTriggeredThreshold = null;
      return messages.length;
    }
    return 0;
  }

  ({int removedCount, List<int> orphanParentIds}) removeOrphans(
      Set<int> existingParentIds) {
    final orphanParentIds = _pendingByParent.keys
        .where((id) => !existingParentIds.contains(id))
        .toList();

    var removedCount = 0;
    for (final parentId in orphanParentIds) {
      removedCount += removeByParent(parentId);
    }

    return (removedCount: removedCount, orphanParentIds: orphanParentIds);
  }

  @override
  String toString() {
    return 'PendingQueue(count: $_totalCount, parents: ${_pendingByParent.length}, '
        'dropped: $_droppedCount, expired: $_expiredCount)';
  }
}
