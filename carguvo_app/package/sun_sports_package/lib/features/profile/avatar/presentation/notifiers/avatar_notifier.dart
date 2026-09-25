import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/features/profile/avatar/domain/repositories/avatar_repository.dart';
import 'package:sun_sports/features/profile/avatar/domain/state/avatar_state.dart';

class AvatarNotifier extends StateNotifier<AvatarListState> {
  final AvatarRepository _repository;

  AvatarNotifier(this._repository) : super(const AvatarListState());

  Future<void> loadAvatars() async {
    if (state.isLoading) return;

    state = state.copyWith(
      status: AvatarListStatus.loading,
      clearError: true,
    );

    final result = await _repository.getAvatars();
    if (!mounted) return;

    result.fold(
      (failure) => state = state.copyWith(
        status: AvatarListStatus.failure,
        errorMessage: failure.toString(),
      ),
      (items) => state = state.copyWith(
        status: AvatarListStatus.success,
        items: items,
        clearError: true,
      ),
    );
  }

  Future<(bool success, String message)> updateAvatar(int avatarId) async {
    if (state.isUpdating) return (false, 'Đang xử lý');

    state = state.copyWith(updatingId: avatarId, clearError: true);

    final result = await _repository.updateAvatar(avatarId);

    if (!mounted) return (false, 'Cancelled');

    return result.fold(
      (failure) {
        final message = _extractFailureMessage(failure.toString());
        state = state.copyWith(clearUpdatingId: true);
        return (false, message);
      },
      (message) {
        state = state.copyWith(clearUpdatingId: true);
        return (true, message);
      },
    );
  }

  String _extractFailureMessage(String raw) {
    final match = RegExp(r'message:\s*([^,)]+)').firstMatch(raw);
    return match?.group(1)?.trim() ?? raw;
  }
}
