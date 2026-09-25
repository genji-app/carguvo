import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/providers/user_provider/user_provider.dart';
import 'package:sun_sports/features/notification/domain/get_notifications_usecase.dart';
import 'package:sun_sports/core/services/models/notification/notification_item.dart';

final getNotificationsUseCaseProvider = Provider<GetNotificationsUseCase>((
  ref,
) {
  return GetNotificationsUseCase(ref.read(userRepositoryProvider));
});

final notificationsProvider =
    FutureProvider.autoDispose<List<NotificationItem>>((ref) async {
      final useCase = ref.read(getNotificationsUseCaseProvider);
      return useCase();
    });

final notificationErrorSelector = notificationsProvider.select(
  (async) => async.hasError ? async.error : null,
);

final notificationLoadingSelector = notificationsProvider.select(
  (async) => async.isLoading,
);

final notificationItemsSelector = notificationsProvider.select(
  (async) => async.asData?.value,
);
