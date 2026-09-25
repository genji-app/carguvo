import 'package:sun_sports/core/services/network/sun_api_exception.dart';

abstract class MyBetFailure implements Exception {
  const MyBetFailure(this.error);

  final Object error;

  @override
  String toString() => 'MyBetFailure(error: $error)';
}

class GetActiveTicketsFailure extends MyBetFailure {
  const GetActiveTicketsFailure(super.error);

  @override
  String toString() => 'GetActiveTicketsFailure(error: $error)';
}

class GetSettledTicketsFailure extends MyBetFailure {
  const GetSettledTicketsFailure(super.error);

  @override
  String toString() => 'GetSettledTicketsFailure(error: $error)';
}

class GetTicketDetailFailure extends MyBetFailure {
  const GetTicketDetailFailure(super.error);

  @override
  String toString() => 'GetTicketDetailFailure(error: $error)';
}

class GetMatchSummaryFailure extends MyBetFailure {
  const GetMatchSummaryFailure(super.error);

  @override
  String toString() => 'GetMatchSummaryFailure(error: $error)';
}

class MatchNotStartedFailure extends MyBetFailure {
  const MatchNotStartedFailure() : super('match not started');

  @override
  String toString() => 'MatchNotStartedFailure()';
}

class GetCashoutFailure extends MyBetFailure {
  const GetCashoutFailure(super.error);

  @override
  String toString() => 'GetCashoutFailure(error: $error)';
}

class PerformCashoutFailure extends MyBetFailure {
  const PerformCashoutFailure(super.error);

  @override
  String toString() => 'PerformCashoutFailure(error: $error)';
}

extension MyBetFailureX on MyBetFailure {
  String? get errorMessage {
    final err = error;

    final message = err.toString().toLowerCase();

    if (err is SunApiException) {
      return err.userFriendlyMessage;
    }

    if (message.contains('formatexception') || message.contains('typeerror')) {
      return 'Dữ liệu trả về từ máy chủ không hợp lệ.';
    }

    if (message.contains('not found') || message.contains('404')) {
      return 'Không tìm thấy thông tin yêu cầu.';
    }

    if (message.contains('cash out failed')) {
      if (message.contains('not available')) {
        return 'Cashout is not available';
      }
      if (message.contains('amount changed') ||
          message.contains('odds changed')) {
        return 'Cashout amount has changed';
      }
    }

    if (err is Exception) {
      if (err.toString().startsWith('Exception: ')) {
        return err.toString().replaceFirst('Exception: ', '');
      }
      return err.toString();
    }

    return 'Đã xảy ra lỗi không xác định.';
  }

  bool get isCashoutNotAvailable {
    final msg = error.toString().toLowerCase();
    return msg.contains('cash out failed') && msg.contains('not available');
  }

  bool get isCashoutAmountChanged {
    final msg = error.toString().toLowerCase();
    return msg.contains('cash out failed') &&
        (msg.contains('amount changed') || msg.contains('odds changed'));
  }
}
