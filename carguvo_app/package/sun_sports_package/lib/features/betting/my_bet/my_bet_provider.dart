import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/services/maintenance/sb_maintenance_provider.dart';
import 'package:sun_sports/core/services/sportbook_api.dart';
import 'package:sun_sports/providers/auth_provider.dart';
import 'package:sun_sports/providers/user_provider/user_provider.dart';

class DevMyBetRepository extends MyBetRepositoryRemote {
  DevMyBetRepository({SbHttpManager? http})
    : super(http: http ?? SbHttpManager.instance);

  @override
  String get token => '32-7f68463c3645da31a477fa68282e91a3';
}

final myBetRepositoryProvider = Provider<MyBetRepository>((ref) {
  ref.watch(userInfoProvider.select((user) => user?.custId));
  final repository = MyBetRepositoryRemote(http: SbHttpManager.instance);
  if (ref.read(isAuthenticatedProvider) && !ref.read(sbMaintenanceProvider)) {
    repository.refreshActiveCount();
  }
  ref.onDispose(() => repository.dispose());
  return repository;
});
