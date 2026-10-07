import 'package:notification_domain/notification_domain.dart' as nd;

String notificationCategoryFromMessage(String message) =>
    nd.notificationCategoryLabelOf(message);
