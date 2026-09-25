import 'package:auth_domain/src/entities/username_check_result.dart';
import 'package:auth_domain/src/repositories/auth_flow_repository.dart';

class CheckUsernameUseCase {
  final AuthFlowRepository repository;

  CheckUsernameUseCase(this.repository);

  Future<UsernameCheckResult> call(String username) {
    return repository.checkUsernameAvailable(username);
  }
}
