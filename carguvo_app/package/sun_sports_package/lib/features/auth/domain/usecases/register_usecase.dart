import 'package:sun_sports/features/auth/domain/entities/auth_entity.dart';
import 'package:sun_sports/features/auth/domain/entities/auth_flow_result.dart';
import 'package:sun_sports/features/auth/domain/repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthFlowRepository repository;

  RegisterUseCase(this.repository);

  Future<AuthFlowResult> call(RegisterRequest request) {
    return repository.register(request);
  }
}
