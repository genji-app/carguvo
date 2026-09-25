import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/services/maintenance/sb_maintenance_provider.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/notification/presentation/notification_provider.dart';
import 'package:sun_sports/features/notification/presentation/widgets/notification_shimmer_loading.dart';
import 'package:sun_sports/features/notification/widgets/notification_empty_state.dart';
import 'package:sun_sports/features/notification/widgets/notification_scroll_list.dart';
import 'package:sun_sports/shared/widgets/maintenance/sb_maintenance_view.dart';

class NotificationAsyncBody extends ConsumerWidget {
  const NotificationAsyncBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(sbMaintenanceProvider)) {
      return const SbMaintenanceInline();
    }

    final err = ref.watch(notificationErrorSelector);
    if (err != null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          err.toString(),
          style: AppTextStyles.paragraphSmall(color: AppColors.red400),
        ),
      );
    }
    if (ref.watch(notificationLoadingSelector)) {
      return const NotificationShimmerLoading();
    }
    final items = ref.watch(notificationItemsSelector) ?? const [];
    if (items.isEmpty) {
      return const NotificationEmptyState();
    }
    return NotificationScrollList(items: items);
  }
}
