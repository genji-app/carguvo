import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:sun_sports/features/auth/data/repositories/auth_flow_repository_impl.dart';
import 'package:sun_sports/features/auth/domain/repositories/auth_repository.dart';
import 'package:sun_sports/features/auth/domain/state/auth_state.dart';
import 'package:sun_sports/features/auth/domain/usecases/check_username_usecase.dart';
import 'package:sun_sports/features/auth/domain/usecases/login_usecase.dart';
import 'package:sun_sports/features/auth/domain/usecases/logout_usecase.dart';
import 'package:sun_sports/features/auth/domain/usecases/register_usecase.dart';
import 'package:sun_sports/features/auth/domain/usecases/submit_otp_usecase.dart';
import 'package:sun_sports/features/auth/presentation/notifiers/auth_notifiers.dart';
import 'package:sun_sports/core/services/storage/search_onboarding_storage.dart';
import 'package:sun_sports/features/onboarding/onboarding.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl();
});

final authFlowRepositoryProvider = Provider<AuthFlowRepository>((ref) {
  final dataSource = ref.watch(authRemoteDataSourceProvider);
  return AuthFlowRepositoryImpl(dataSource);
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authFlowRepositoryProvider));
});

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  return RegisterUseCase(ref.watch(authFlowRepositoryProvider));
});

final submitOtpUseCaseProvider = Provider<SubmitOtpUseCase>((ref) {
  return SubmitOtpUseCase(ref.watch(authFlowRepositoryProvider));
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.watch(authFlowRepositoryProvider));
});

final checkUsernameUseCaseProvider = Provider<CheckUsernameUseCase>((ref) {
  return CheckUsernameUseCase(ref.watch(authFlowRepositoryProvider));
});

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((
  ref,
) {
  return AuthNotifier(
    ref.watch(loginUseCaseProvider),
    ref.watch(registerUseCaseProvider),
    ref.watch(submitOtpUseCaseProvider),
    ref.watch(logoutUseCaseProvider),
    onRegisterSuccess: () {
      ref.read(spotlightShowAfterRegisterProvider.notifier).state = true;
      SearchOnboardingStorage.instance.setPending(true);
    },
  );
});

final loginFormNotifierProvider =
    StateNotifierProvider<LoginFormNotifier, LoginFormState>((ref) {
      return LoginFormNotifier();
    });

final registerFormNotifierProvider =
    StateNotifierProvider<RegisterFormNotifier, RegisterFormState>((ref) {
      return RegisterFormNotifier(ref.watch(checkUsernameUseCaseProvider));
    });

final otpFormNotifierProvider =
    StateNotifierProvider<OtpFormNotifier, OtpFormState>((ref) {
      return OtpFormNotifier();
    });
