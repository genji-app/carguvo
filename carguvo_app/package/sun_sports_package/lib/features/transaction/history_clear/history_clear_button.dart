import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/services/repositories/transaction_repository/transaction_repository.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/features/transaction/extensions.dart';
import 'package:sun_sports/features/transaction/history/transaction_history_provider.dart';
import 'package:sun_sports/features/transaction/transaction_provider.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';
import 'package:sun_sports/shared/widgets/toast/app_toast.dart';

import 'history_clear_confirm_dialog.dart';

class HistoryClearButton extends ConsumerWidget {
  const HistoryClearButton({super.key});

  Future<void> _handleClearAll(BuildContext context, WidgetRef ref) async {
    final state = ref.read(
      transactionHistoryProvider(TransactionFilter.activityLog),
    );
    final hasData = state.data != null && state.data!.isNotEmpty;
    if (!hasData) return;

    final confirmed = await HistoryClearConfirmDialog.show(context);

    if (confirmed == true) {
      try {
        await ref.read(transactionRepositoryProvider).clearActivityLogs();
        if (context.mounted) {
          AppToast.showSuccess(
            context,
            message: 'Dọn dẹp lịch sử hoạt động thành công',
          );
        }
      } catch (e) {
        if (context.mounted) {
          final message = e is TransactionFailure
              ? e.userMessage
              : 'Xoá thất bại. Vui lòng thử lại';
          AppToast.showError(context, message: message);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasData = ref.watch(
      transactionHistoryProvider(
        TransactionFilter.activityLog,
      ).select((s) => s.data != null && s.data!.isNotEmpty),
    );

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    );

    return SizedBox.square(
      dimension: 40,
      child: IconButton(
        onPressed: hasData
            ? SoundTap.wrap(() => _handleClearAll(context, ref))
            : null,
        color: hasData
            ? AppColorStyles.contentSecondary
            : AppColorStyles.contentQuaternary,
        icon: ImageHelper.load(
          path: AppIcons.icDelete,
          color: hasData
              ? AppColorStyles.contentSecondary
              : AppColorStyles.contentQuaternary,
        ),
        style: IconButton.styleFrom(
          backgroundColor: AppColorStyles.backgroundQuaternary,
          disabledBackgroundColor: AppColorStyles.backgroundQuaternary
              .withValues(alpha: 0.5),
          disabledForegroundColor: AppColorStyles.contentQuaternary,
          shape: shape,
          iconSize: 24,
        ),
      ),
    );
  }
}
