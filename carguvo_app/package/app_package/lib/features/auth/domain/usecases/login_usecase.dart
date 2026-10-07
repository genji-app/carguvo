import 'package:app_package/features/auth/domain/entities/auth_entity.dart';
import 'package:app_package/features/auth/domain/entities/auth_flow_result.dart';
import 'package:app_package/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthFlowRepository repository;

  LoginUseCase(this.repository);

  Future<AuthFlowResult> call(LoginRequest request) {
    return repository.login(request);
  }
}
