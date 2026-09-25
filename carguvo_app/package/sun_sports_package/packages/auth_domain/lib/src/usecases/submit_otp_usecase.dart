import 'package:auth_domain/src/entities/auth_entity.dart';
import 'package:auth_domain/src/entities/auth_flow_result.dart';
import 'package:auth_domain/src/repositories/auth_flow_repository.dart';

class SubmitOtpUseCase {
  final AuthFlowRepository repository;

  SubmitOtpUseCase(this.repository);

  Future<AuthFlowResult> call(OtpRequest request) {
    return repository.submitOtp(request);
  }
}
