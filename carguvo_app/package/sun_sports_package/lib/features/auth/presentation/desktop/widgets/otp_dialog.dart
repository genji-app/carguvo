import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/sport/data/adapters/sport_socket_adapter_provider.dart';
import 'package:sun_sports/providers/auth_provider.dart'
    as global_auth;
import 'package:sun_sports/features/auth/presentation/providers/auth_providers.dart';
import 'package:sun_sports/features/auth/domain/state/auth_state.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/shared/widgets/toast/app_toast.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class OtpDialog extends ConsumerStatefulWidget {
  final String sessionId;
  final String message;
  final String username;
  final String password;

  const OtpDialog({
    super.key,
    required this.sessionId,
    required this.message,
    required this.username,
    required this.password,
  });

  @override
  ConsumerState<OtpDialog> createState() => _OtpDialogState();
}

class _OtpDialogState extends ConsumerState<OtpDialog> {
  late final TextEditingController _otpController;

  @override
  void initState() {
    super.initState();
    _otpController = TextEditingController();
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      next.maybeWhen(
        authenticated: (auth) {
          ref.read(global_auth.authProvider.notifier).syncFromSbLogin();
          initializeSportSocketAfterLogin(ref);
          Navigator.of(context).pop();
          AppToast.showSuccess(context, message: 'Xác thực OTP thành công!');
        },
        orElse: () {},
      );
    });

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF111010),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF393836), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Xác thực OTP',
                  style: AppTextStyles.headingSmall(color: AppColors.yellow50),
                ),
                IconButton(
                  onPressed: SoundTap.wrap(() => Navigator.of(context).pop()),
                  icon: Icon(
                    Icons.close,
                    color: AppColorStyles.contentSecondary,
                  ),
                ),
              ],
            ),
            const Gap(16),
            Text(
              widget.message,
              style: AppTextStyles.paragraphMedium(
                color: AppColorStyles.contentSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(24),
            Consumer(
              builder: (context, ref, _) {
                final otpError = ref.watch(
                  otpFormNotifierProvider.select((state) => state.otpError),
                );
                return _OtpInputField(
                  controller: _otpController,
                  errorText: otpError,
                  onChanged: (value) {
                    ref.read(otpFormNotifierProvider.notifier).updateOtp(value);
                  },
                );
              },
            ),
            const Gap(24),
            Consumer(
              builder: (context, ref, _) {
                final generalError = ref.watch(
                  otpFormNotifierProvider.select((state) => state.generalError),
                );
                if (generalError == null) return const SizedBox.shrink();
                return Column(
                  children: [
                    Text(
                      generalError,
                      style: AppTextStyles.paragraphSmall(
                        color: AppColors.red500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Gap(16),
                  ],
                );
              },
            ),
            Consumer(
              builder: (context, ref, _) {
                final isSubmitting = ref.watch(
                  otpFormNotifierProvider.select((state) => state.isSubmitting),
                );
                return SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: SoundTap.wrap(isSubmitting
                        ? null
                        : () async {
                            final notifier = ref.read(
                              otpFormNotifierProvider.notifier,
                            );
                            if (notifier.validate()) {
                              notifier.setSubmitting(true);
                              await ref
                                  .read(authNotifierProvider.notifier)
                                  .submitOtp(
                                    sessionId: widget.sessionId,
                                    otp: ref.read(otpFormNotifierProvider).otp,
                                    username: widget.username,
                                    password: widget.password,
                                  );
                            }
                          }),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.yellow300,
                      disabledBackgroundColor: const Color(0xFF252423),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(1000),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    child: isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF111010),
                              ),
                            ),
                          )
                        : Text(
                            'Xác nhận',
                            style: AppTextStyles.buttonMedium(
                              color: const Color(0xFF111010),
                            ),
                          ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _OtpInputField extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  const _OtpInputField({
    required this.controller,
    this.errorText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: AppColorStyles.backgroundSecondary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: errorText != null
                  ? AppColors.red500
                  : AppColorStyles.borderSecondary,
              width: errorText != null ? 2 : 1,
            ),
          ),
          child: Center(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 6,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: AppTextStyles.headingSmall(
                color: AppColorStyles.contentPrimary,
              ).copyWith(letterSpacing: 16),
              decoration: InputDecoration(
                border: InputBorder.none,
                counterText: '',
                hintText: '------',
                hintStyle: AppTextStyles.headingSmall(
                  color: AppColorStyles.contentTertiary,
                ).copyWith(letterSpacing: 16),
              ),
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              errorText!,
              style: AppTextStyles.paragraphSmall(color: AppColors.red500),
            ),
          ),
      ],
    );
  }
}
