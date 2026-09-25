import 'package:sun_sports/core/services/auth/token_manager.dart';
import 'package:sun_sports/core/services/sportbook_api.dart';

sealed class AuthFailure implements Exception {
  const AuthFailure(this.error);

  final Object error;

  @override
  String toString() => 'AuthFailure(error: $error)';
}

class RequestOtpFailure extends AuthFailure {
  const RequestOtpFailure(super.error);
}

extension AuthFailureX on AuthFailure {
  String? get errorMessage {
    final err = error;

    if (err is SunApiException) {
      return err.userFriendlyMessage;
    }

    if (err is Exception) {
      return err.toString().replaceFirst('Exception: ', '');
    }

    return null;
  }
}

abstract class AuthRepository {
  Future<bool> connect();
  Future<void> reconnect();
  Future<void> logout();
  bool get isInitialized;
  UserModel? getCurrentUser();
  String? get currentToken;

  Future<String?> requestOtp(String phoneNumber);
}

class AuthRepositoryImpl implements AuthRepository {
  final SbHttpManager _http;

  AuthRepositoryImpl({SbHttpManager? http})
    : _http = http ?? SbHttpManager.instance;

  @override
  Future<bool> connect() async {
    return await SbLogin.connect();
  }

  @override
  Future<void> reconnect() async {
    await SbLogin.reconnect();
  }

  @override
  Future<void> logout() async {
    await SbLogin.logout();

    await TokenManager.clearTokens();
    await UserManager.clearCredentials();
  }

  @override
  bool get isInitialized => SbLogin.isInitialized;

  @override
  UserModel? getCurrentUser() {
    if (!isInitialized) return null;

    final userData = _http.user;
    if (userData['cust_id'] == null ||
        (userData['cust_id'] as String).isEmpty) {
      return null;
    }

    return UserModel(
      uid: userData['uid'] as String? ?? '',
      displayName: userData['displayName'] as String? ?? '',
      custLogin: userData['cust_login'] as String? ?? '',
      custId: userData['cust_id'] as String? ?? '',
      balance: (userData['balance'] as num?)?.toDouble() ?? 0.0,
      currency: userData['currency'] as String? ?? 'VND',
      status: userData['status'] as String? ?? 'Active',
    );
  }

  @override
  String? get currentToken =>
      _http.userTokenSb.isNotEmpty ? _http.userTokenSb : null;

  @override
  Future<String?> requestOtp(String phoneNumber) async {
    try {
      final response = await _http.getOTPCode(phoneNumber);

      final data = response.dataOrThrow as Map<String, dynamic>;

      return data['message'] as String?;
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(RequestOtpFailure(error), stackTrace);
    }
  }
}
