import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/core/utils/styles/spacing_styles.dart';
import 'package:sun_sports/features/game/game.dart';
import 'package:sun_sports/shared/widgets/buttons/buttons.dart';

class GamePlayerFailureView extends StatelessWidget {
  const GamePlayerFailureView({
    required this.failureState,
    required this.onClose,
    required this.onRetry,
    super.key,
  });

  final GamePlayerFailureState failureState;
  final VoidCallback onClose;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final isRetryable = failureState.isRetryable;
    final failureMessage = failureState.failureMessage;
    final failureType = failureState.failureType;

    return switch (failureType) {
      GamePlayerMaintenanceError() => _FailureContent(
        message: const Text('Game đang bảo trì.'),
        secondaryMessage: const Text('Xin quay lại sau!'),
        onPrimaryAction: onClose,
        primaryActionText: I18n.txtBackToHome,
        errorCode: failureType.errorCode,
      ),
      GamePlayerNetworkError() => _FailureContent(
        icon: const _ErrorIcon(),
        message: const Text('Không có kết nối mạng'),
        secondaryMessage: Text(
          failureMessage ??
              (isRetryable
                  ? 'Kiểm tra kết nối và thử lại'
                  : 'Không thể kết nối sau nhiều lần thử. Kiểm tra lại mạng và vào lại.'),
        ),
        onPrimaryAction: isRetryable ? onRetry : onClose,
        primaryActionText: isRetryable ? I18n.txtRetry : I18n.txtGoBack,
        onSecondaryAction: isRetryable ? onClose : null,
        secondaryActionText: isRetryable ? I18n.txtGoBack : null,
        errorCode: failureType.errorCode,
      ),
      GamePlayerServerError() => _FailureContent(
        icon: const _ErrorIcon(),
        message: const Text('Lỗi máy chủ'),
        secondaryMessage: Text(
          failureMessage ??
              (isRetryable
                  ? 'Máy chủ gặp sự cố, vui lòng thử lại'
                  : 'Máy chủ không phản hồi sau nhiều lần thử. Vui lòng thử lại sau.'),
        ),
        onPrimaryAction: isRetryable ? onRetry : onClose,
        primaryActionText: isRetryable ? I18n.txtRetry : I18n.txtGoBack,
        onSecondaryAction: isRetryable ? onClose : null,
        secondaryActionText: isRetryable ? I18n.txtGoBack : null,
        errorCode: failureType.errorCode,
      ),
      GamePlayerOrientationSetupFailedError() => _FailureContent(
        icon: const _ErrorIcon(),
        message: const Text('Lỗi xoay màn hình'),
        secondaryMessage: const Text(
          'Không thể áp dụng hướng màn hình. Vui lòng quay lại và thử lại.',
        ),
        onPrimaryAction: onClose,
        primaryActionText: I18n.txtGoBack,
        errorCode: failureType.errorCode,
      ),
      GamePlayerSessionExpiredError() => _FailureContent(
        icon: const _ErrorIcon(),
        message: const Text('Phiên đăng nhập hết hạn'),
        secondaryMessage: const Text('Vui lòng đăng nhập lại để tiếp tục'),
        onPrimaryAction: onClose,
        primaryActionText: I18n.txtGoBack,
        errorCode: failureType.errorCode,
      ),
      GamePlayerComingSoonError() => _FailureContent(
        icon: const _ErrorIcon(),
        message: const Text('Game sắp ra mắt'),
        secondaryMessage: const Text('Nội dung này chưa được phát hành'),
        onPrimaryAction: onClose,
        primaryActionText: I18n.txtGoBack,
        errorCode: failureType.errorCode,
      ),
      GamePlayerUnavailableError() => _FailureContent(
        icon: const _ErrorIcon(),
        message: const Text('Game không khả dụng'),
        secondaryMessage: const Text(
          'Game này hiện đang tạm dừng hoặc đang phát triển',
        ),
        onPrimaryAction: onClose,
        primaryActionText: I18n.txtGoBack,
        errorCode: failureType.errorCode,
      ),
      GamePlayerLoadTimeoutError() => _FailureContent(
        icon: const _ErrorIcon(),
        message: const Text('Tải game quá lâu'),
        secondaryMessage: const Text(
          'Vui lòng kiểm tra kết nối mạng hoặc thử lại',
        ),
        onPrimaryAction: isRetryable ? onRetry : onClose,
        primaryActionText: isRetryable ? I18n.txtRetry : I18n.txtGoBack,
        onSecondaryAction: isRetryable ? onClose : null,
        secondaryActionText: isRetryable ? I18n.txtGoBack : null,
        errorCode: failureType.errorCode,
      ),
      GamePlayerMissingGameUrlError() => _FailureContent(
        icon: const _ErrorIcon(),
        message: const Text('Không tìm thấy game'),
        secondaryMessage: const Text('Không lấy được địa chỉ trò chơi'),
        onPrimaryAction: onClose,
        primaryActionText: I18n.txtGoBack,
        errorCode: failureType.errorCode,
      ),
      GamePlayerLaunchFailedError(message: final msg) => _FailureContent(
        icon: const _ErrorIcon(),
        message: const Text('Lỗi khởi chạy trò chơi'),
        secondaryMessage: Text(
          msg ??
              failureMessage ??
              'Không thể mở trò chơi. Vui lòng thử lại sau.',
        ),
        onPrimaryAction: isRetryable ? onRetry : onClose,
        primaryActionText: isRetryable ? I18n.txtRetry : I18n.txtGoBack,
        onSecondaryAction: isRetryable ? onClose : null,
        secondaryActionText: isRetryable ? I18n.txtGoBack : null,
        errorCode: failureType.errorCode,
      ),
      GamePlayerHttpError(statusCode: final code) => _FailureContent(
        icon: const _ErrorIcon(),
        message: Text(_httpErrorTitle(code)),
        secondaryMessage: Text(_httpErrorDescription(code)),
        onPrimaryAction: isRetryable ? onRetry : onClose,
        primaryActionText: isRetryable ? I18n.txtRetry : I18n.txtGoBack,
        onSecondaryAction: isRetryable ? onClose : null,
        secondaryActionText: isRetryable ? I18n.txtGoBack : null,
        errorCode: failureType.errorCode,
      ),
      GamePlayerUnsupportedBrowserError() => _FailureContent(
        icon: const _ErrorIcon(),
        message: const Text('Trình duyệt chưa được hỗ trợ'),
        secondaryMessage: const Text(
          'Game chưa hoạt động trên trình duyệt này.\nVui lòng mở lại bằng Google Chrome để chơi.',
        ),
        onPrimaryAction: onClose,
        primaryActionText: I18n.txtGoBack,
      ),
      GamePlayerUnknownError(message: final msg) => _FailureContent(
        icon: const _ErrorIcon(),
        message: Text(msg ?? failureMessage ?? I18n.msgSomethingWentWrong),
        onPrimaryAction: isRetryable ? onRetry : onClose,
        primaryActionText: isRetryable ? I18n.txtRetry : I18n.txtGoBack,
        onSecondaryAction: isRetryable ? onClose : null,
        secondaryActionText: isRetryable ? I18n.txtGoBack : null,
        errorCode: failureType.errorCode,
      ),
    };
  }

  static String _httpErrorTitle(int code) {
    return switch (code) {
      403 => 'Truy cập bị từ chối',
      404 => 'Trò chơi không tìm thấy',
      500 || 502 || 503 => 'Lỗi máy chủ game',
      _ => 'Không thể tải trò chơi',
    };
  }

  static String _httpErrorDescription(int code) {
    return switch (code) {
      403 => 'Bạn không có quyền truy cập game này',
      404 => 'Địa chỉ game không tồn tại hoặc đã bị xóa',
      500 || 502 || 503 => 'Máy chủ game đang gặp sự cố, vui lòng thử lại sau',
      _ => 'Đã xảy ra lỗi khi tải game (HTTP $code)',
    };
  }
}

class GamePlayerReloadFailureView extends StatelessWidget {
  const GamePlayerReloadFailureView({
    required this.onRetry,
    this.onForceExit,
    super.key,
  });

  final VoidCallback onRetry;
  final VoidCallback? onForceExit;

  @override
  Widget build(BuildContext context) {
    return _FailureContent(
      icon: const _ErrorIcon(),
      message: const Text('Không tải được dữ liệu'),
      secondaryMessage: const Text(
        'Kiểm tra kết nối và thử lại để quay về trang chủ',
      ),
      onPrimaryAction: onRetry,
      primaryActionText: I18n.txtRetry,
      onSecondaryAction: onForceExit,
      secondaryActionText: I18n.txtBackToHome,
    );
  }
}

class _FailureContent extends StatelessWidget {
  const _FailureContent({
    required this.message,
    this.secondaryMessage,
    this.icon,
    this.onPrimaryAction,
    this.primaryActionText,
    this.onSecondaryAction,
    this.secondaryActionText,
    this.errorCode,
  });

  final Widget message;
  final Widget? secondaryMessage;
  final Widget? icon;
  final VoidCallback? onPrimaryAction;
  final String? primaryActionText;
  final VoidCallback? onSecondaryAction;
  final String? secondaryActionText;
  final String? errorCode;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacingStyles.space400),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[icon!, const Gap(AppSpacingStyles.space400)],
          DefaultTextStyle(
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.headingXSmall(
              color: AppColorStyles.contentPrimary,
            ),
            child: message,
          ),
          if (secondaryMessage != null) ...[
            const Gap(AppSpacingStyles.space200),
            DefaultTextStyle(
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.paragraphSmall(
                color: AppColorStyles.contentSecondary,
              ),
              child: secondaryMessage!,
            ),
          ],
          if (onPrimaryAction != null) ...[
            const Gap(AppSpacingStyles.space800),
            ShineButton(
              style: ShineButtonStyle.primaryYellow,
              onPressed: onPrimaryAction,
              text: primaryActionText ?? I18n.txtRetry,
            ),
          ],
          if (onSecondaryAction != null) ...[
            const Gap(AppSpacingStyles.space400),
            ShineButton(
              style: ShineButtonStyle.primaryGray,
              onPressed: onSecondaryAction,
              text: secondaryActionText ?? I18n.txtGoBack,
            ),
          ],
        ],
      ),
    );
  }
}

class _ErrorIcon extends StatelessWidget {
  const _ErrorIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.error_outline_rounded,
        color: Colors.redAccent,
        size: 32,
      ),
    );
  }
}
