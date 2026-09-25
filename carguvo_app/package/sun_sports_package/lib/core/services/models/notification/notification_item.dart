import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sun_sports/core/services/models/notification/notification_category.dart';

part 'notification_item.freezed.dart';

@freezed
sealed class NotificationItem with _$NotificationItem {
  const NotificationItem._();

  const factory NotificationItem({
    required int id,
    required String message,
    required DateTime createdAt,
    required String category,
  }) = _NotificationItem;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'message': message,
    'createdAt': createdAt.toIso8601String(),
    'category': category,
  };

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    final msg = json['message'] as String;
    return NotificationItem(
      id: (json['id'] as num).toInt(),
      message: msg,
      createdAt: DateTime.parse(json['createdAt'] as String),
      category:
          json['category'] as String? ?? notificationCategoryFromMessage(msg),
    );
  }

  factory NotificationItem.fromApiMap(Map<String, dynamic> json) {
    final msg = (json['1'] as String?) ?? '';
    return NotificationItem(
      id: (json['0'] as num).toInt(),
      message: msg,
      createdAt: DateTime.parse(json['2'] as String),
      category: notificationCategoryFromMessage(msg),
    );
  }
}
