import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'mini_game_auth_data.dart';
import 'mini_game_auth_service.dart';

final miniGameAuthServiceProvider = Provider<MiniGameAuthService>((ref) {
  return MiniGameAuthService();
});

final sbCredentialsVersionProvider = StreamProvider<int>((ref) {
  return const Stream<int>.empty();
});

final miniGameAuthProvider = FutureProvider<MiniGameAuthData>((ref) {
  ref.watch(sbCredentialsVersionProvider);
  return ref.watch(miniGameAuthServiceProvider).read();
});
