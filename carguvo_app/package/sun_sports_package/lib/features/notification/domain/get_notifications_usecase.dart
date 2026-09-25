import 'package:sun_sports/core/services/repositories/user_repository/src/user_repository.dart';
import 'package:sun_sports/core/services/models/notification/notification_item.dart';

class GetNotificationsUseCase {
  const GetNotificationsUseCase(this._repository);

  final UserRepository _repository;

  Future<List<NotificationItem>> call() => _repository.fetchNotifications();
}
