import 'package:auth_domain/src/entities/auth_entity.dart';
import 'package:auth_domain/src/entities/auth_flow_result.dart';
import 'package:auth_domain/src/entities/username_check_result.dart';

abstract class AuthFlowRepository {
  Future<AuthFlowResult> login(LoginRequest request);

  Future<AuthFlowResult> register(RegisterRequest request);

  Future<AuthFlowResult> submitOtp(OtpRequest request);

  Future<void> logout();

  Future<UsernameCheckResult> checkUsernameAvailable(String username);
}
