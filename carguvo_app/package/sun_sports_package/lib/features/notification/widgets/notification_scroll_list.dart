import 'package:flutter/material.dart';
import 'package:sun_sports/core/services/models/notification/notification_item.dart';
import 'package:sun_sports/features/notification/widgets/notification_list_tile.dart';

class NotificationScrollList extends StatelessWidget {
  const NotificationScrollList({required this.items, super.key});

  final List<NotificationItem> items;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 4),
      cacheExtent: 280,
      addRepaintBoundaries: false,
      addAutomaticKeepAlives: false,
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 1),
      itemBuilder: (context, i) {
        final item = items[i];
        return RepaintBoundary(
          key: ValueKey<int>(item.id),
          child: NotificationListTile(item: item),
        );
      },
    );
  }
}
