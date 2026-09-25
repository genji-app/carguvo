import 'package:sun_sports/features/profile/avatar/domain/entities/avatar_item.dart';

enum AvatarListStatus { initial, loading, success, failure }

class AvatarListState {
  final AvatarListStatus status;
  final List<AvatarItem> items;
  final String? errorMessage;

  final int? updatingId;

  const AvatarListState({
    this.status = AvatarListStatus.initial,
    this.items = const [],
    this.errorMessage,
    this.updatingId,
  });

  AvatarListState copyWith({
    AvatarListStatus? status,
    List<AvatarItem>? items,
    String? errorMessage,
    int? updatingId,
    bool clearError = false,
    bool clearUpdatingId = false,
  }) {
    return AvatarListState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      updatingId: clearUpdatingId ? null : (updatingId ?? this.updatingId),
    );
  }

  bool get isLoading => status == AvatarListStatus.loading;
  bool get isUpdating => updatingId != null;
}
