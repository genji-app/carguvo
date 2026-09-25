import 'package:flutter/material.dart' hide CloseButton;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/core/error/app_error_messages.dart';
import 'package:sun_sports/core/providers/pending_toast_provider.dart';
import 'package:sun_sports/providers/auth_provider.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/auth/presentation/providers/auth_providers.dart';
import 'package:sun_sports/features/security/security.dart';
import 'package:sun_sports/shared/widgets/buttons/buttons.dart';
import 'package:sun_sports/shared/widgets/sb_bottom_navigation_bar.dart';
import 'package:sun_sports/shared/widgets/toast/app_toast.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  static MaterialPageRoute<void> route() =>
      MaterialPageRoute(builder: (context) => const ChangePasswordScreen());

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  late final TextEditingController _currentPassController;
  late final TextEditingController _newPassController;
  late final TextEditingController _confirmPassController;

  @override
  void initState() {
    super.initState();
    _currentPassController = TextEditingController();
    _newPassController = TextEditingController();
    _confirmPassController = TextEditingController();
  }

  @override
  void dispose() {
    _currentPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(changePasswordProvider.notifier);

    ref.listen<ChangePasswordState>(changePasswordProvider, (previous, next) {
      if (previous?.status == next.status) return;

      switch (next.status) {
        case ChangePasswordStatus.success:
          notifier.resetState();
          _currentPassController.clear();
          _newPassController.clear();
          _confirmPassController.clear();

          ref.read(pendingToastProvider.notifier).state = const PendingToast(
            message: 'Đổi mật khẩu thành công. Vui lòng đăng nhập lại.',
            title: 'Thông báo',
            isError: false,
          );

          ref
              .read(securityNavigatorProvider)
              .onPasswordChangedSuccess(context, ref);

          ref.read(authProvider.notifier).logout();
          ref.read(authNotifierProvider.notifier).logout();
          break;
        case ChangePasswordStatus.failure:
          if (next.errorMessage != null) {
            AppToast.showError(
              context,
              message: localizedOrGenericError(
                'Đổi mật khẩu',
                next.errorMessage,
              ),
            );
          }
          break;
        case ChangePasswordStatus.initial:
        case ChangePasswordStatus.loading:
        case ChangePasswordStatus.invalid:
          break;
      }
    });

    return Scaffold(
      backgroundColor: AppColorStyles.backgroundSecondary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          I18n.txtChangePassword,
          style: AppTextStyles.headingXSmall(
            color: AppColorStyles.contentPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColorStyles.contentPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 24,
          children: [
            _CurrentPasswordField(
              controller: _currentPassController,
              onChanged: notifier.setCurrentPassword,
            ),

            _NewPasswordField(
              controller: _newPassController,
              onChanged: notifier.setNewPassword,
            ),

            _ConfirmPasswordField(
              controller: _confirmPassController,
              onChanged: notifier.setConfirmPassword,
            ),
            const Gap(36),
          ],
        ),
      ),
      bottomNavigationBar: const SBBottomNavigationBar.withDivider(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: ChangePasswordSubmitButton(),
        ),
      ),
    );
  }
}

class _CurrentPasswordField extends ConsumerWidget {
  const _CurrentPasswordField({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final errorText = ref.watch(
      changePasswordProvider.select((s) => s.currentPasswordError),
    );
    return PasswordInputField(
      label: const Text(I18n.txtCurrentPassword),
      errorText: errorText,
      controller: controller,
      onChanged: onChanged,
    );
  }
}

class _NewPasswordField extends ConsumerWidget {
  const _NewPasswordField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final errorText = ref.watch(
      changePasswordProvider.select((s) => s.newPasswordError),
    );
    return PasswordInputField(
      label: const Text(I18n.txtNewPassword),
      errorText: errorText,
      controller: controller,
      onChanged: onChanged,
    );
  }
}

class _ConfirmPasswordField extends ConsumerWidget {
  const _ConfirmPasswordField({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final errorText = ref.watch(
      changePasswordProvider.select((s) => s.confirmPasswordError),
    );
    return PasswordInputField(
      label: const Text(I18n.txtReEnterNewPassword),
      errorText: errorText,
      controller: controller,
      onChanged: onChanged,
    );
  }
}

class ChangePasswordSubmitButton extends ConsumerWidget {
  const ChangePasswordSubmitButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canSubmit = ref.watch(
      changePasswordProvider.select((s) => s.canSubmit),
    );
    final isLoading = ref.watch(
      changePasswordProvider.select((s) => s.isLoading),
    );
    final notifier = ref.read(changePasswordProvider.notifier);
    final labelTxt = isLoading ? '' : I18n.txtChangePassword;

    return Opacity(
      opacity: canSubmit ? 1 : 0.5,
      child: ShineButton(
        text: labelTxt,
        width: double.infinity,
        style: ShineButtonStyle.primaryYellow,
        size: ShineButtonSize.large,
        onPressed: canSubmit ? notifier.submit : null,
        trailingIcon: isLoading
            ? const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColorStyles.contentPrimary,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
