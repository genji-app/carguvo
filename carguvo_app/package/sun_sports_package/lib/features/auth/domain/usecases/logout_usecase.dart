import 'package:sun_sports/features/auth/domain/repositories/auth_repository.dart';

class LogoutUseCase {
  final AuthFlowRepository repository;

  LogoutUseCase(this.repository);

  Future<void> call() {
    return repository.logout();
  }
}
