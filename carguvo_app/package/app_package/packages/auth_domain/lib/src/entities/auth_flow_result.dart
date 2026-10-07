import 'package:auth_domain/src/entities/auth_entity.dart';

sealed class AuthFlowResult {
  const AuthFlowResult();
}

class AuthFlowSuccess extends AuthFlowResult {
  final AuthEntity auth;

  const AuthFlowSuccess(this.auth);
}

class AuthFlowOtpRequired extends AuthFlowResult {
  final String sessionId;

  final String? message;

  final bool showPopup;

  const AuthFlowOtpRequired({
    required this.sessionId,
    required this.showPopup,
    this.message,
  });
}

class AuthFlowFailure extends AuthFlowResult {
  final String message;

  final bool showPopup;

  const AuthFlowFailure({required this.message, required this.showPopup});
}
