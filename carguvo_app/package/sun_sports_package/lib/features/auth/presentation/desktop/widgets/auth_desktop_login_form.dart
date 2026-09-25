import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sun_sports/core/error/app_error_messages.dart';
import 'package:sun_sports/core/utils/app_logger.dart';
import 'package:sun_sports/core/services/config/sb_config.dart';
import 'package:sun_sports/core/utils/styles/app_images.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/auth_validator.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/sport/data/adapters/sport_socket_adapter_provider.dart';
import 'package:sun_sports/providers/auth_provider.dart'
    as global_auth;
import 'package:sun_sports/features/auth/presentation/providers/auth_providers.dart';
import 'package:sun_sports/features/auth/domain/state/auth_state.dart';
import 'package:sun_sports/features/auth/presentation/desktop/widgets/otp_dialog.dart';
import 'package:sun_sports/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/shared/responsive/responsive_builder.dart';
import 'package:sun_sports/shared/widgets/buttons/shine_button.dart';
import 'package:sun_sports/shared/widgets/toast/app_toast.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class AuthDesktopLoginForm extends ConsumerStatefulWidget {
  final VoidCallback onSwitchToRegister;

  const AuthDesktopLoginForm({required this.onSwitchToRegister, super.key});

  @override
  ConsumerState<AuthDesktopLoginForm> createState() =>
      _AuthDesktopLoginFormState();
}

class _AuthDesktopLoginFormState extends ConsumerState<AuthDesktopLoginForm> {
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(loginFormNotifierProvider.notifier).reset();
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginFormState = ref.watch(loginFormNotifierProvider);
    final loginFormNotifier = ref.read(loginFormNotifierProvider.notifier);
    final authNotifier = ref.read(authNotifierProvider.notifier);
    final isUsernameValid =
        AuthValidator.validateLoginUsername(loginFormState.username) == null;
    final isPasswordValid =
        AuthValidator.validateLoginPassword(loginFormState.password) == null;
    final canSubmit =
        !loginFormState.isSubmitting && isUsernameValid && isPasswordValid;

    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      next.maybeWhen(
        authenticated: (auth) {
          TextInput.finishAutofillContext();
          AppToast.showSuccess(
            context,
            message: 'Đăng nhập thành công!',
            duration: const Duration(seconds: 1),
          );
          final goRouter = GoRouter.maybeOf(context);
          if (goRouter != null) {
            try {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/');
              }
            } catch (e) {
              AppLoggers.auth.w('[login] post-login navigation threw: $e');
            }
          }
          ref.read(global_auth.authProvider.notifier).syncFromSbLogin();
          initializeSportSocketAfterLogin(ref);
        },
        otpRequired: (sessionId, message, username, password) {
          showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (context) => OtpDialog(
              sessionId: sessionId,
              message: message,
              username: username,
              password: password,
            ),
          );
        },
        error: (message, showPopup) {
          AppToast.showError(
            context,
            message: localizedOrGenericError('Đăng nhập', message),
          );
        },
        orElse: () {},
      );
    });

    void submitForm() async {
      if (canSubmit && loginFormNotifier.validate()) {
        FocusScope.of(context).unfocus();
        loginFormNotifier.setSubmitting(true);
        await authNotifier.login(
          loginFormState.username,
          loginFormState.password,
        );
        loginFormNotifier.setSubmitting(false);
      }
    }

    return CallbackShortcuts(
      bindings: {const SingleActivator(LogicalKeyboardKey.enter): submitForm},
      child: Focus(
        autofocus: true,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const Spacer(),
                      ImageHelper.load(
                        path: AppImages.logoUrl,
                        width: 150,
                        height: 150,
                        fit: BoxFit.contain,
                      ),
                      const Gap(28),
                      Container(
                        width: 448,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 32,
                        ),
                        decoration: BoxDecoration(
                          color: AppColorStyles.backgroundSecondary,
                          gradient: RadialGradient(
                            center: Alignment(0.0, -6.4),
                            radius: 2.9,
                            tileMode: TileMode.clamp,
                            colors: [
                              const Color.fromARGB(170, 249, 219, 175),
                              AppColorStyles.backgroundSecondary,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              offset: Offset(0, -0.65),
                              blurRadius: 0.3,
                              spreadRadius: 0.4,
                              blurStyle: BlurStyle.inner,
                              color: Colors.white.withOpacity(0.15),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Đăng nhập',
                              style: AppTextStyles.headingSmall(
                                color: AppColors.yellow50,
                              ),
                            ),
                            const Gap(48),
                            AutofillGroup(
                              child: Column(
                                children: [
                                  AuthTextField(
                                    label: 'Tài khoản',
                                    controller: _usernameController,
                                    errorText: loginFormState.usernameError,
                                    autofillHints: const [
                                      AutofillHints.username,
                                    ],
                                    onChanged: (value) {
                                      loginFormNotifier.updateUsername(value);
                                    },
                                    onEditingComplete: submitForm,
                                  ),
                                  const Gap(16),
                                  AuthTextField(
                                    label: 'Mật khẩu',
                                    controller: _passwordController,
                                    isPassword: true,
                                    errorText: loginFormState.passwordError,
                                    autofillHints: const [
                                      AutofillHints.password,
                                    ],
                                    onChanged: (value) {
                                      loginFormNotifier.updatePassword(value);
                                    },
                                    onEditingComplete: submitForm,
                                  ),
                                  const Gap(8),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: InkWell(
                                      onTap: loginFormState.isSubmitting
                                          ? null
                                          : SoundTap.wrap(() {
                                              launchUrl(
                                                Uri.parse(SbConfig.livechatUrl),
                                                mode: LaunchMode
                                                    .externalApplication,
                                              );
                                            }),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          'Quên mật khẩu?',
                                          style:
                                              AppTextStyles.paragraphSmall(
                                                color: AppColorStyles
                                                    .contentSecondary,
                                              ).copyWith(
                                                decoration:
                                                    TextDecoration.underline,
                                                decorationColor: AppColorStyles
                                                    .contentSecondary,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Gap(48),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: Opacity(
                                opacity: canSubmit ? 1 : 0.5,
                                child: ShineButton(
                                  text: loginFormState.isSubmitting
                                      ? ''
                                      : 'Tiếp tục',
                                  height: 48,
                                  width: double.infinity,
                                  style: ShineButtonStyle.primaryYellow,
                                  onPressed: canSubmit ? submitForm : null,
                                  trailingIcon: loginFormState.isSubmitting
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Container(
                        margin: const EdgeInsets.only(bottom: 8, top: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Không có tài khoản?',
                              style: AppTextStyles.paragraphSmall(
                                color: AppColorStyles.contentSecondary,
                              ),
                            ),
                            const Gap(16),
                            Opacity(
                              opacity: loginFormState.isSubmitting ? 0.5 : 1,
                              child: SizedBox(
                                height: 36,
                                child: ElevatedButton(
                                  onPressed: loginFormState.isSubmitting
                                      ? null
                                      : SoundTap.wrap(
                                          widget.onSwitchToRegister,
                                        ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.gray700,
                                    disabledBackgroundColor: AppColors.gray700,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(1000),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                  child: Text(
                                    'Đăng ký ngay',
                                    style: AppTextStyles.buttonSmall(
                                      color: AppColors.yellow200,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
