import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/core/env/app_env.dart';
import 'package:sun_sports/core/providers/pending_toast_provider.dart';
import 'package:sun_sports/core/services/config/sb_config.dart';
import 'package:sun_sports/features/notification/presentation/notification_panel.dart';
import 'package:sun_sports/providers/auth_provider.dart';
import 'package:sun_sports/providers/user_provider/user_provider.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/widgets/buttons/shine_button.dart';
import 'package:sun_sports/shared/widgets/maintenance/sb_maintenance_view.dart';
import 'package:sun_sports/shared/responsive/responsive_builder.dart';
import 'package:sun_sports/shared/widgets/toast/app_toast.dart';
import 'package:url_launcher/url_launcher.dart';

import 'profile_navigator.dart';
import 'widgets/widgets.dart';

class ProfileViewDeferred extends StatefulWidget {
  const ProfileViewDeferred({super.key});

  @override
  State<ProfileViewDeferred> createState() => _ProfileViewDeferredState();
}

class _ProfileViewDeferredState extends State<ProfileViewDeferred>
    with SingleTickerProviderStateMixin {
  static const Duration _slideDuration = Duration(milliseconds: 300);

  late final AnimationController _slideMirror;
  bool _revealed = false;

  @override
  void initState() {
    super.initState();
    _slideMirror = AnimationController(vsync: this, duration: _slideDuration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted && !_revealed) {
          setState(() => _revealed = true);
        }
      })
      ..forward();
  }

  @override
  void dispose() {
    _slideMirror.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 150),
      switchInCurve: Curves.easeOut,
      child: _revealed ? const ProfileView() : const _ProfileSkeleton(),
    );
  }
}

class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton();

  static Widget _box(
    double height, {
    double? width,
    double radius = 12,
    EdgeInsetsGeometry? margin,
  }) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: AppColorStyles.backgroundTertiary,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: AppColorStyles.backgroundTertiary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _box(16, width: 150),
                    const SizedBox(height: 8),
                    _box(12, width: 90),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          _box(76, radius: 16),
          const SizedBox(height: 28),
          for (var i = 0; i < 6; i++)
            _box(44, margin: const EdgeInsets.only(bottom: 10)),
        ],
      ),
    );
  }
}

class ProfileView extends ConsumerWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userInfoProvider);
    final navigator = ref.read(profileNavigatorProvider);

    const horizontalPadding = EdgeInsets.symmetric(horizontal: 12);
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        ProfileUserCard(
          customerId: user?.custId ?? '-',
          displayName: user?.displayName ?? I18n.txtUser,
          avatarUrl: user?.avatarUrl,
          onAvatarPressed: () => navigator.pushToAvatarSelection(context),
          onNotificationPressed: ResponsiveBuilder.isDesktop(context)
              ? null
              : () {
                  final rootContext =
                      Navigator.of(context, rootNavigator: true).context;
                  navigator.close(context);
                  NotificationPanel.show(rootContext);
                },
        ),

        Expanded(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: horizontalPadding,
                  child: Column(
                    children: [
                      if (user?.isPhoneVerified == false)
                        Container(
                          margin: const EdgeInsets.only(top: 12),
                          child: ProfilePhoneVerificationWarning(
                            onActivatePressed: () =>
                                navigator.pushToPhoneVerification(context),
                          ),
                        ),

                      const SizedBox(height: 20),
                      const ProfileWalletSection(),

                      const SizedBox(height: 32),
                      ProfileAccountSection(
                        onSupportPressed: () {
                          launchUrl(
                            Uri.parse(SbConfig.livechatUrl),
                            mode: LaunchMode.externalApplication,
                          );
                        },
                        onMailboxPressed: () => AppToast.showError(
                          context,
                          message: I18n.txtFeatureUnderDevelopment,
                        ),
                        onPromoPressed: () => AppToast.showError(
                          context,
                          message: I18n.txtFeatureUnderDevelopment,
                        ),
                        onPersonalPressed: () =>
                            navigator.pushToPersonal(context),
                        onSecurityPressed: () =>
                            navigator.pushToSecurity(context),
                        onSettingsPressed: () =>
                            navigator.pushToSettings(context),
                        onBetHistoryPressed: () {
                          if (blockedBySbMaintenance(context, ref)) return;
                          navigator.pushToBettingHistory(context);
                        },
                      ),
                      const SizedBox(height: 16),
                      const _VersionPatchInfo(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: ShineButton(
                  text: I18n.txtLogout,
                  height: 36,
                  style: ShineButtonStyle.primaryGray,
                  onPressed: () async {
                    final confirmed = await DialogConfirmLogout.show(context);
                    if (confirmed != true || !context.mounted) return;
                    ref.read(pendingToastProvider.notifier).state =
                        const PendingToast(
                          message: I18n.txtLogoutSuccess,
                          title: 'Thông báo',
                          isError: false,
                          duration: Duration(seconds: 1),
                        );
                    final auth = ref.read(authProvider.notifier);
                    try {
                      navigator.close(context);
                    } catch (_) {
                    }
                    await auth.logout();
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _VersionPatchInfo extends StatefulWidget {
  const _VersionPatchInfo();

  @override
  State<_VersionPatchInfo> createState() => _VersionPatchInfoState();
}

class _VersionPatchInfoState extends State<_VersionPatchInfo> {
  static const String _fallbackVersion = String.fromEnvironment('APP_VERSION', defaultValue: '1.0.1+7');

  late final Future<String> _versionTextFuture;

  @override
  void initState() {
    super.initState();
    _versionTextFuture = _loadVersionText();
  }

  Future<String> _loadVersionText() async {
    return _fallbackVersion;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _versionTextFuture,
      builder: (context, snap) {
        final version = snap.data ?? _fallbackVersion;
        return Center(
          child: Text(
            'Versions: v$version - ${AppEnv.label}',
            style: AppTextStyles.paragraphSmall(color: Colors.blueGrey),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }
}
