import 'package:auth_domain/src/repositories/auth_flow_repository.dart';

class LogoutUseCase {
  final AuthFlowRepository repository;

  LogoutUseCase(this.repository);

  Future<void> call() {
    return repository.logout();
  }
}
