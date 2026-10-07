import 'package:app_package/features/auth/domain/repositories/auth_repository.dart';

class LogoutUseCase {
  final AuthFlowRepository repository;

  LogoutUseCase(this.repository);

  Future<void> call() {
    return repository.logout();
  }
}
