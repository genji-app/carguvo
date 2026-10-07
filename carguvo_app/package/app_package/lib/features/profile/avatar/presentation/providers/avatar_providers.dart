import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_package/features/profile/avatar/data/repositories/avatar_repository_impl.dart';
import 'package:app_package/features/profile/avatar/presentation/notifiers/avatar_notifier.dart';
import 'package:app_package/features/profile/avatar/domain/repositories/avatar_repository.dart';
import 'package:app_package/features/profile/avatar/domain/state/avatar_state.dart';

final avatarRepositoryProvider = Provider<AvatarRepository>((ref) {
  return AvatarRepositoryImpl();
});

final avatarNotifierProvider =
    StateNotifierProvider.autoDispose<AvatarNotifier, AvatarListState>((ref) {
      final repository = ref.read(avatarRepositoryProvider);
      return AvatarNotifier(repository);
    });
