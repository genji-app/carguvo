import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/services/repositories/transaction_repository/transaction_repository.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/transaction/extensions.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';
import 'package:sun_sports/shared/widgets/menu/styled_menu.dart';
import 'package:sun_sports/shared/widgets/toast/app_toast.dart';

import 'history_config_provider.dart';

class HistoryConfigMenu extends ConsumerStatefulWidget {
  const HistoryConfigMenu({super.key});

  @override
  ConsumerState<HistoryConfigMenu> createState() => _HistoryConfigMenuState();
}

class _HistoryConfigMenuState extends ConsumerState<HistoryConfigMenu> {
  int? _pendingMinutes;

  static String _formatOptionLabel(int minutes) => '$minutes phút';
  static String _formatTriggerLabel(int minutes) => '${minutes}P';

  @override
  Widget build(BuildContext context) {
    final configState = ref.watch(historyConfigProvider);
    final selectedMinutes = configState.valueOrNull ?? 0;
    final isUpdating = _pendingMinutes != null;
    final displayMinutes = _pendingMinutes ?? selectedMinutes;

    return StyledMenu<int>(
      items: TransactionRepository.allowedCountdownOptions,
      selectedValue: selectedMinutes,
      minWidth: 88.0,
      menuWidth: 180.0,
      offset: const Offset(-98, 4),
      header: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          children: [
            ImageHelper.load(
              path: AppIcons.icHourglass,
              width: 20,
              height: 20,
              color: AppColorStyles.contentSecondary,
            ),
            const Gap(8),
            Text(
              'Xóa sau:',
              style: AppTextStyles.labelSmall(
                color: AppColorStyles.contentSecondary,
              ),
            ),
          ],
        ),
      ),
      configBuilder: (minutes) =>
          StyledMenuConfig(label: _formatOptionLabel(minutes)),
      onChanged: isUpdating
          ? (_) {}
          : (minutes) async {
              if (minutes == selectedMinutes) return;
              setState(() => _pendingMinutes = minutes);

              try {
                final success = await ref
                    .read(historyConfigProvider.notifier)
                    .setTimeCountDown(minutes);

                if (success && context.mounted) {
                  final label = minutes == 0
                      ? 'Xóa ngay lập tức'
                      : '$minutes phút';
                  AppToast.showSuccess(
                    context,
                    message: 'Đã cập nhật tự động xoá lịch sử: $label',
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  final message = e is TransactionFailure
                      ? e.userMessage
                      : 'Cập nhật thất bại. Vui lòng thử lại';
                  AppToast.showError(context, message: message);
                }
              } finally {
                if (mounted) {
                  setState(() => _pendingMinutes = null);
                }
              }
            },
      triggerBuilder: (context, controller, isOpen, config) {
        return Opacity(
          opacity: isUpdating ? 0.6 : 1.0,
          child: SizedBox(
            width: 88,
            height: 40,
            child: Material(
              color: AppColorStyles.backgroundQuaternary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: isUpdating
                    ? null
                    : SoundTap.wrap(() {
                        if (controller.isOpen) {
                          controller.close();
                        } else {
                          controller.open();
                        }
                      }),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          _formatTriggerLabel(displayMinutes),
                          style: AppTextStyles.labelSmall(
                            color: AppColorStyles.contentPrimary,
                          ),
                        ),
                      ),
                      const Gap(4),
                      AnimatedRotation(
                        turns: isOpen ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        child: ImageHelper.load(
                          path: AppIcons.chevronDown,
                          width: 20,
                          height: 20,
                          color: AppColorStyles.contentSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
