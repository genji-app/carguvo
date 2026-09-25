import 'package:flutter/material.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/core/services/models/notification/notification_item.dart';
import 'package:sun_sports/features/notification/domain/notification_relative_time.dart';
import 'package:sun_sports/features/notification/widgets/notification_category_leading.dart';

class NotificationListTile extends StatelessWidget {
  const NotificationListTile({required this.item, super.key});

  final NotificationItem item;

  @override
  Widget build(BuildContext context) {
    final timeCreateAt = formatNotificationRelativeTime(item.createdAt);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NotificationCategoryLeading(category: item.category),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.category,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.labelXSmall(
                              context: context,
                              color: AppColorStyles.contentPrimary,
                            ).copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.message,
                            style: AppTextStyles.paragraphXSmall(
                              context: context,
                              color: AppColorStyles.contentTertiary,
                            ).copyWith(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      timeCreateAt,
                      style: AppTextStyles.paragraphXSmall(
                        context: context,
                        color: AppColorStyles.contentTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
