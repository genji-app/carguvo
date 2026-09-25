import 'package:sun_sports/core/services/sportbook_api.dart';

sealed class UserFailure implements Exception {
  const UserFailure(this.error);

  final Object error;

  @override
  String toString() => 'UserFailure(error: $error)';
}

class GetUserInfoFailure extends UserFailure {
  const GetUserInfoFailure(super.error);
}

class GetBalanceFailure extends UserFailure {
  const GetBalanceFailure(super.error);
}

class VerifyPhoneFailure extends UserFailure {
  const VerifyPhoneFailure(super.error);
}

class ChangePasswordFailure extends UserFailure {
  const ChangePasswordFailure(super.error);
}

class GetNotificationsFailure extends UserFailure {
  const GetNotificationsFailure(super.error);
}

extension UserFailureX on UserFailure {
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
