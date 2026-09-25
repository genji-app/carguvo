import 'package:sun_sports/features/auth/domain/entities/auth_entity.dart';
import 'package:sun_sports/features/auth/domain/entities/auth_flow_result.dart';
import 'package:sun_sports/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthFlowRepository repository;

  LoginUseCase(this.repository);

  Future<AuthFlowResult> call(LoginRequest request) {
    return repository.login(request);
  }
}
