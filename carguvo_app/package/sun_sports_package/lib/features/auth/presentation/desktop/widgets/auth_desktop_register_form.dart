import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/error/app_error_messages.dart';
import 'package:sun_sports/core/utils/app_logger.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/auth_validator.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_images.dart';
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

class AuthDesktopRegisterForm extends ConsumerStatefulWidget {
  const AuthDesktopRegisterForm({required this.onSwitchToLogin, super.key});

  final VoidCallback onSwitchToLogin;

  @override
  ConsumerState<AuthDesktopRegisterForm> createState() =>
      _AuthDesktopRegisterFormState();
}

class _AuthDesktopRegisterFormState
    extends ConsumerState<AuthDesktopRegisterForm> {
  late final TextEditingController _usernameController;
  late final TextEditingController _displayNameController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _displayNameController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _displayNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      next.maybeWhen(
        authenticated: (auth) {
          TextInput.finishAutofillContext();
          AppToast.showSuccess(
            context,
            message: 'Đăng ký thành công!',
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
              AppLoggers.auth.w('[register] post-register navigation threw: $e');
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
            message: localizedOrGenericError('Đăng ký', message),
          );
        },
        orElse: () {},
      );
    });

    void submitForm() async {
      final state = ref.read(registerFormNotifierProvider);
      final isValid =
          !state.isSubmitting &&
          AuthValidator.validateRegisterUsername(state.username) == null &&
          AuthValidator.validatePassword(state.password) == null &&
          AuthValidator.validateConfirmPassword(
                state.confirmPassword,
                state.password,
              ) ==
              null &&
          AuthValidator.validateDisplayName(
                state.displayName,
                state.username,
              ) ==
              null &&
          state.usernameAvailability != UsernameAvailability.taken;
      if (!isValid) return;

      final registerFormNotifier = ref.read(
        registerFormNotifierProvider.notifier,
      );
      final authNotifier = ref.read(authNotifierProvider.notifier);

      registerFormNotifier.setSubmitting(true);
      if (!await _ensureUsernameFree(context, ref)) {
        registerFormNotifier.setSubmitting(false);
        return;
      }
      await authNotifier.register(
        username: state.username,
        password: state.password,
        displayName: state.displayName,
      );
      registerFormNotifier.setSubmitting(false);
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
                            center: Alignment(
                              0.0,
                              ResponsiveBuilder.isMobile(context) ? -5.9 : -6.4,
                            ),
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
                              'Đăng ký tài khoản',
                              style: AppTextStyles.headingSmall(
                                color: AppColors.yellow50,
                              ),
                            ),
                            const Gap(48),
                            AutofillGroup(
                              child: Column(
                                children: [
                                  Consumer(
                                    builder: (context, ref, _) {
                                      final username = ref.watch(
                                        registerFormNotifierProvider.select(
                                          (s) => s.username,
                                        ),
                                      );
                                      final isTaken = ref.watch(
                                        registerFormNotifierProvider.select(
                                          (s) =>
                                              s.usernameAvailability ==
                                              UsernameAvailability.taken,
                                        ),
                                      );
                                      return AuthTextField(
                                        label: 'Tài khoản',
                                        controller: _usernameController,
                                        maxLength: 15,
                                        autofillHints: const [
                                          AutofillHints.newUsername,
                                        ],
                                        errorText:
                                            AuthValidator.validateRegisterUsernameRealtime(
                                              username,
                                            ) ??
                                            (isTaken
                                                ? kUsernameTakenMessage
                                                : null),
                                        onChanged: (value) {
                                          ref
                                              .read(
                                                registerFormNotifierProvider
                                                    .notifier,
                                              )
                                              .updateUsername(value);
                                        },
                                        onFocusLost: () {
                                          ref
                                              .read(
                                                registerFormNotifierProvider
                                                    .notifier,
                                              )
                                              .checkUsernameAvailability();
                                        },
                                      );
                                    },
                                  ),
                                  const Gap(16),
                                  Consumer(
                                    builder: (context, ref, _) {
                                      final password = ref.watch(
                                        registerFormNotifierProvider.select(
                                          (s) => s.password,
                                        ),
                                      );
                                      return AuthTextField(
                                        label: 'Mật khẩu',
                                        controller: _passwordController,
                                        isPassword: true,
                                        maxLength: 30,
                                        autofillHints: const [
                                          AutofillHints.newPassword,
                                        ],
                                        errorText:
                                            AuthValidator.validatePasswordRealtime(
                                              password,
                                            ),
                                        onChanged: (value) {
                                          ref
                                              .read(
                                                registerFormNotifierProvider
                                                    .notifier,
                                              )
                                              .updatePassword(value);
                                        },
                                      );
                                    },
                                  ),
                                  const Gap(16),
                                  Consumer(
                                    builder: (context, ref, _) {
                                      final confirmPassword = ref.watch(
                                        registerFormNotifierProvider.select(
                                          (s) => s.confirmPassword,
                                        ),
                                      );
                                      final password = ref.watch(
                                        registerFormNotifierProvider.select(
                                          (s) => s.password,
                                        ),
                                      );
                                      return AuthTextField(
                                        label: 'Xác nhận mật khẩu',
                                        controller: _confirmPasswordController,
                                        isPassword: true,
                                        maxLength: 30,
                                        autofillHints: const [
                                          AutofillHints.newPassword,
                                        ],
                                        errorText:
                                            AuthValidator.validateConfirmPasswordRealtime(
                                              confirmPassword,
                                              password,
                                            ),
                                        onChanged: (value) {
                                          ref
                                              .read(
                                                registerFormNotifierProvider
                                                    .notifier,
                                              )
                                              .updateConfirmPassword(value);
                                        },
                                      );
                                    },
                                  ),
                                  const Gap(16),
                                  Consumer(
                                    builder: (context, ref, _) {
                                      final displayName = ref.watch(
                                        registerFormNotifierProvider.select(
                                          (s) => s.displayName,
                                        ),
                                      );
                                      final username = ref.watch(
                                        registerFormNotifierProvider.select(
                                          (s) => s.username,
                                        ),
                                      );
                                      return AuthTextField(
                                        label: 'Tên hiển thị',
                                        controller: _displayNameController,
                                        maxLength: 15,
                                        errorText:
                                            AuthValidator.validateDisplayNameRealtime(
                                              displayName,
                                              username,
                                            ),
                                        onChanged: (value) {
                                          ref
                                              .read(
                                                registerFormNotifierProvider
                                                    .notifier,
                                              )
                                              .updateDisplayName(value);
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const Gap(16),
                            _SubmitButton(
                              onSwitchToLogin: widget.onSwitchToLogin,
                            ),
                            const Gap(12),
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
                              'Đã có tài khoản?',
                              style: AppTextStyles.paragraphSmall(
                                color: AppColorStyles.contentSecondary,
                              ),
                            ),
                            const Gap(16),
                            SizedBox(
                              height: 36,
                              child: ElevatedButton(
                                onPressed: SoundTap.wrap(
                                  widget.onSwitchToLogin,
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.gray700,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(1000),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                child: Text(
                                  'Đăng nhập ngay',
                                  style: AppTextStyles.buttonSmall(
                                    color: AppColors.yellow200,
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

Future<bool> _ensureUsernameFree(BuildContext context, WidgetRef ref) async {
  final availability = await ref
      .read(registerFormNotifierProvider.notifier)
      .checkUsernameAvailability();
  if (availability != UsernameAvailability.taken) return true;
  if (context.mounted) {
    AppToast.showError(context, message: kUsernameTakenMessage);
  }
  return false;
}

class _SubmitButton extends ConsumerWidget {
  const _SubmitButton({required this.onSwitchToLogin});

  final VoidCallback onSwitchToLogin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSubmitting = ref.watch(
      registerFormNotifierProvider.select((s) => s.isSubmitting),
    );
    final username = ref.watch(
      registerFormNotifierProvider.select((s) => s.username),
    );
    final password = ref.watch(
      registerFormNotifierProvider.select((s) => s.password),
    );
    final confirmPassword = ref.watch(
      registerFormNotifierProvider.select((s) => s.confirmPassword),
    );
    final displayName = ref.watch(
      registerFormNotifierProvider.select((s) => s.displayName),
    );
    final isUsernameTaken = ref.watch(
      registerFormNotifierProvider.select(
        (s) => s.usernameAvailability == UsernameAvailability.taken,
      ),
    );

    final isUsernameValid =
        AuthValidator.validateRegisterUsername(username) == null;
    final isPasswordValid = AuthValidator.validatePassword(password) == null;
    final isConfirmPasswordValid =
        AuthValidator.validateConfirmPassword(confirmPassword, password) ==
        null;
    final isDisplayNameValid =
        AuthValidator.validateDisplayName(displayName, username) == null;
    final canSubmit =
        !isSubmitting &&
        isUsernameValid &&
        isPasswordValid &&
        isConfirmPasswordValid &&
        isDisplayNameValid &&
        !isUsernameTaken;

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: Opacity(
        opacity: canSubmit ? 1 : 0.5,
        child: ShineButton(
          text: isSubmitting ? '' : 'Tiếp tục',
          height: 48,
          width: double.infinity,
          style: ShineButtonStyle.primaryYellow,
          onPressed: canSubmit
              ? () async {
                  final usernameError = AuthValidator.validateRegisterUsername(
                    username,
                  );
                  if (usernameError != null) {
                    AppToast.showError(context, message: usernameError);
                    return;
                  }

                  final passwordError = AuthValidator.validatePassword(
                    password,
                  );
                  if (passwordError != null) {
                    AppToast.showError(context, message: passwordError);
                    return;
                  }

                  final confirmPasswordError =
                      AuthValidator.validateConfirmPassword(
                        confirmPassword,
                        password,
                      );
                  if (confirmPasswordError != null) {
                    AppToast.showError(context, message: confirmPasswordError);
                    return;
                  }

                  final displayNameError = AuthValidator.validateDisplayName(
                    displayName,
                    username,
                  );
                  if (displayNameError != null) {
                    AppToast.showError(context, message: displayNameError);
                    return;
                  }

                  final registerFormNotifier = ref.read(
                    registerFormNotifierProvider.notifier,
                  );
                  final authNotifier = ref.read(authNotifierProvider.notifier);

                  registerFormNotifier.setSubmitting(true);
                  if (!await _ensureUsernameFree(context, ref)) {
                    registerFormNotifier.setSubmitting(false);
                    return;
                  }
                  await authNotifier.register(
                    username: username,
                    password: password,
                    displayName: displayName,
                  );
                  registerFormNotifier.setSubmitting(false);
                }
              : null,
          trailingIcon: isSubmitting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
