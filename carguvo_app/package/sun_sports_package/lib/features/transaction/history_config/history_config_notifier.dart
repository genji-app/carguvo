import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/services/repositories/repositories.dart';

class HistoryConfigNotifier extends StateNotifier<AsyncValue<int>> {
  HistoryConfigNotifier({required TransactionRepository repository})
    : _repository = repository,
      super(const AsyncValue.loading()) {
    fetchConfig();
  }

  final TransactionRepository _repository;
  int _mutationToken = 0;

  Future<void> fetchConfig() async {
    try {
      final countdown = await _repository.getHistoryConfig();
      state = AsyncValue.data(countdown);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> setTimeCountDown(int minutes) async {
    final previousValue = state.valueOrNull ?? 0;
    if (previousValue == minutes) return true;

    final token = ++_mutationToken;

    try {
      final success = await _repository.updateHistoryConfig(minutes);
      if (token == _mutationToken && success) {
        state = AsyncValue.data(minutes);
      }
      return success;
    } catch (e) {
      if (token == _mutationToken) {
        rethrow;
      }
      return false;
    }
  }
}
