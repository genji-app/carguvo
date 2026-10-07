import 'package:auth_domain/src/entities/auth_entity.dart';
import 'package:auth_domain/src/entities/auth_flow_result.dart';
import 'package:auth_domain/src/repositories/auth_flow_repository.dart';

class LoginUseCase {
  final AuthFlowRepository repository;

  LoginUseCase(this.repository);

  Future<AuthFlowResult> call(LoginRequest request) {
    return repository.login(request);
  }
}
