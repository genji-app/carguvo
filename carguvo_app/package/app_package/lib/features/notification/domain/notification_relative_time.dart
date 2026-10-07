import 'package:notification_domain/notification_domain.dart' as nd;

String formatNotificationRelativeTime(DateTime createdAt, {DateTime? now}) =>
    nd.notificationRelativeTime(createdAt, now: now);
