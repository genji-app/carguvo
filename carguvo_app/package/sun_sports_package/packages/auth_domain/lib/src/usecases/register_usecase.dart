import 'package:auth_domain/src/entities/auth_entity.dart';
import 'package:auth_domain/src/entities/auth_flow_result.dart';
import 'package:auth_domain/src/repositories/auth_flow_repository.dart';

class RegisterUseCase {
  final AuthFlowRepository repository;

  RegisterUseCase(this.repository);

  Future<AuthFlowResult> call(RegisterRequest request) {
    return repository.register(request);
  }
}
