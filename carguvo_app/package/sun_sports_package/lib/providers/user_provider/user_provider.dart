import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/services/config/sb_config.dart';
import 'package:sun_sports/core/services/network/sb_http_manager.dart';
import 'package:sun_sports/core/services/provider_game/game_api_client_provider.dart';
import 'package:sun_sports/providers/auth_provider.dart';
import 'package:sun_sports/providers/user_provider/user_notifier.dart';
import 'package:sun_sports/core/services/repositories/user_repository/user_repository.dart';

export 'user_notifier.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final repository = UserRepository(
    http: SbHttpManager.instance,
    balanceFetcher: () async {
      if (SbConfig.gameApiUrl.isEmpty) return null;
      final data = await ref.read(gameApiClientProvider).fetchBalance();
      return data.balance.toDouble();
    },
  );
  ref.onDispose(() => repository.dispose());
  return repository;
});

final userProvider = StateNotifierProvider.autoDispose<UserNotifier, UserState>(
  (ref) {
    ref.keepAlive();

    final repository = ref.read(userRepositoryProvider);
    final notifier = UserNotifier(repository: repository);

    final authState = ref.read(authProvider);
    if (authState.isAuthenticated && authState.user != null) {
      notifier.fetchUserInfo();
    }

    ref.listen(authProvider, (previous, next) {
      if (next.status == AuthStatus.unauthenticated) {
        notifier.clear();
        return;
      }
      if (!next.isAuthenticated || next.user == null) return;

      final justAuthenticated = previous?.isAuthenticated != true;
      final tokenChanged = previous?.token != next.token;
      if (justAuthenticated || tokenChanged) {
        notifier.fetchUserInfo();
      }
    });

    notifier.addListener((userState) {
      if (userState.isLoggedIn &&
          ref.read(authProvider.select((s) => s.profilePending))) {
        ref.read(authProvider.notifier).markProfileReady();
      }
    });

    return notifier;
  },
);

final balanceInVNDProvider = Provider.autoDispose<double>(
  (ref) => ref.watch(userProvider).user?.balanceInVND ?? 0.0,
);

final userDisplayNameProvider = Provider.autoDispose<String>((ref) {
  return ref.watch(userProvider).user?.displayName ?? 'Guest';
});

final userAvatarUrlProvider = Provider.autoDispose<String>((ref) {
  return ref.watch(userProvider).user?.avatarUrl ?? '';
});

final userInfoProvider = Provider.autoDispose<User?>((ref) {
  return ref.watch(userProvider).user;
});
