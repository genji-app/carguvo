import 'package:sun_sports/features/auth/domain/entities/auth_entity.dart';
import 'package:sun_sports/features/auth/domain/entities/auth_flow_result.dart';
import 'package:sun_sports/features/auth/domain/repositories/auth_repository.dart';

class SubmitOtpUseCase {
  final AuthFlowRepository repository;

  SubmitOtpUseCase(this.repository);

  Future<AuthFlowResult> call(OtpRequest request) {
    return repository.submitOtp(request);
  }
}
