import 'package:app_package/features/auth/domain/entities/username_check_result.dart';
import 'package:app_package/features/auth/domain/repositories/auth_repository.dart';

class CheckUsernameUseCase {
  final AuthFlowRepository repository;

  CheckUsernameUseCase(this.repository);

  Future<UsernameCheckResult> call(String username) {
    return repository.checkUsernameAvailable(username);
  }
}
