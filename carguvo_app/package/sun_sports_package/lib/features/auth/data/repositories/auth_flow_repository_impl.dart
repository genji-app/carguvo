import 'package:sun_sports/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:sun_sports/features/auth/data/models/auth_model.dart';
import 'package:sun_sports/features/auth/domain/entities/auth_entity.dart';
import 'package:sun_sports/features/auth/domain/entities/auth_flow_result.dart';
import 'package:sun_sports/features/auth/domain/entities/username_check_result.dart';
import 'package:sun_sports/features/auth/domain/repositories/auth_repository.dart';

class AuthFlowRepositoryImpl implements AuthFlowRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthFlowRepositoryImpl(this.remoteDataSource);

  @override
  Future<AuthFlowResult> login(LoginRequest request) async {
    final requestModel = LoginRequestModel.fromEntity(request);
    final response = await remoteDataSource.login(requestModel);
    return _map(response, noDataMessage: 'Đăng nhập thất bại');
  }

  @override
  Future<AuthFlowResult> register(RegisterRequest request) async {
    final requestModel = RegisterRequestModel.fromEntity(request);
    final response = await remoteDataSource.register(requestModel);
    return _map(response, noDataMessage: 'Đăng ký thất bại');
  }

  @override
  Future<AuthFlowResult> submitOtp(OtpRequest request) async {
    final requestModel = OtpRequestModel.fromEntity(request);
    final response = await remoteDataSource.submitOtp(requestModel);
    return _map(response, noDataMessage: 'Xác thực OTP thất bại');
  }

  @override
  Future<void> logout() {
    return remoteDataSource.logout();
  }

  @override
  Future<UsernameCheckResult> checkUsernameAvailable(String username) {
    return remoteDataSource.checkUsernameAvailable(username);
  }

  AuthFlowResult _map(
    AuthResponseModel response, {
    required String noDataMessage,
  }) {
    if (response.isSuccess) {
      final entity = response.toEntity();
      if (entity != null) {
        return AuthFlowSuccess(entity);
      }
      return AuthFlowFailure(message: noDataMessage, showPopup: false);
    }

    if (response.isOtpRequired) {
      return AuthFlowOtpRequired(
        sessionId: response.data?.sessionId ?? '',
        message: response.data?.message,
        showPopup: response.shouldShowPopup,
      );
    }

    return AuthFlowFailure(
      message: response.errorMessage,
      showPopup: response.shouldShowPopup,
    );
  }
}
