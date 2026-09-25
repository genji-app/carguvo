import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_images.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/download_app/data/services/external_launcher.dart';
import 'package:sun_sports/features/download_app/data/models/download_app_config.dart';
import 'package:sun_sports/features/download_app/presentation/providers/download_app_config_provider.dart';
import 'package:sun_sports/features/download_app/presentation/providers/store_client_ip_provider.dart';
import 'package:sun_sports/shared/responsive/responsive_builder.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';
import 'package:sun_sports/shared/widgets/toast/app_toast.dart';

const double _dialogWidth = 402;

const String kDownloadLandingUrl = 'https://sun88.win/download';

class DialogDownloadApp extends StatelessWidget {
  const DialogDownloadApp({super.key, this.isBottomSheet = false});

  final bool isBottomSheet;

  static Future<void> show(BuildContext context) {
    return showGeneralDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      transitionDuration: const Duration(milliseconds: 200),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        if (!ResponsiveBuilder.isMobile(context)) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.96, end: 1).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOut),
              ),
              child: child,
            ),
          );
        }
        return Align(
          alignment: Alignment.bottomCenter,
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                .animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOut),
                ),
            child: child,
          ),
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) =>
          const _DownloadAppContent(isBottomSheet: false),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const _DownloadAppContent(isBottomSheet: false);
  }
}

class _DownloadAppContent extends ConsumerStatefulWidget {
  const _DownloadAppContent({required this.isBottomSheet});

  final bool isBottomSheet;

  @override
  ConsumerState<_DownloadAppContent> createState() =>
      _DownloadAppContentState();
}

class _DownloadAppContentState extends ConsumerState<_DownloadAppContent> {
  bool _launching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(downloadAppConfigProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBuilder.isMobile(context);
    final isWebMobile = kIsWeb && isMobile;
    final configState = ref.watch(downloadAppConfigProvider);
    final remote = configState.remote;
    final platformConfig = configState.platformConfig;
    final showLoading = remote == null && configState.isLoading;
    final maxHeight = MediaQuery.of(context).size.height * 0.85;

    final container = ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Container(
        width: MediaQuery.of(context).size.width <= 733 ? null : _dialogWidth,
        decoration: BoxDecoration(
          color: AppColorStyles.backgroundTertiary,
          borderRadius: isMobile
              ? const BorderRadius.vertical(top: Radius.circular(24))
              : BorderRadius.circular(24),
          border: Border.all(color: AppColors.gray700, width: 1),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DownloadHeader(onClose: () => Navigator.of(context).pop()),
              Flexible(
                child: SingleChildScrollView(
                  child: remote == null
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 48,
                            horizontal: 16,
                          ),
                          child: Center(
                            child: showLoading
                                ? const CircularProgressIndicator()
                                : GestureDetector(
                                    onTap: SoundTap.wrap(
                                      () => ref
                                          .read(
                                            downloadAppConfigProvider.notifier,
                                          )
                                          .refresh(),
                                    ),
                                    child: Text(
                                      'Không tải được thông tin. Nhấn để thử lại.',
                                      textAlign: TextAlign.center,
                                      style: AppTextStyles.paragraphSmall(
                                        context: context,
                                        color: AppColors.yellow300,
                                      ),
                                    ),
                                  ),
                          ),
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (platformConfig != null)
                              _AppDescriptionSection(config: platformConfig),
                            const SizedBox(height: 24),
                            _DownloadAppSection(
                              config: remote.display,
                              onAndroidStore: () => _launchUrl(
                                isWebMobile
                                    ? kDownloadLandingUrl
                                    : (platformConfig?.urlAndroidStore ?? ''),
                                sameTab: isMobile,
                              ),
                              onIosStore: () => _launchUrl(
                                isWebMobile
                                    ? kDownloadLandingUrl
                                    : (platformConfig?.urlIosStore ?? ''),
                                sameTab: isMobile,
                              ),
                              onApk: () => _launchUrl(
                                isWebMobile
                                    ? kDownloadLandingUrl
                                    : (platformConfig?.urlFileAndroidApk ?? ''),
                                sameTab: isMobile,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    final Widget body;
    if (isMobile) {
      body = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragEnd: (details) {
          final velocity = details.primaryVelocity ?? 0;
          if (velocity > 300) {
            Navigator.of(context).pop();
          }
        },
        child: Container(alignment: Alignment.bottomCenter, child: container),
      );
    } else {
      body = Container(alignment: Alignment.center, child: container);
    }

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          body,
          if (_launching)
            const Positioned.fill(
              child: AbsorbPointer(
                child: ColoredBox(
                  color: Color(0x66000000),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url, {bool sameTab = false}) async {
    if (url.isEmpty || _launching) return;
    setState(() => _launching = true);
    final service = ref.read(storeClientIpServiceProvider);
    var ok = false;
    try {
      ok = await openExternalAfter(
        url: url,
        sameTab: sameTab,
        task: () => service.storeClientIpUntilFirstOk(),
      );
    } finally {
      if (mounted) setState(() => _launching = false);
    }
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
    } else {
      AppToast.showError(context, message: 'Kết nối không ổn định, vui lòng thử lại');
    }
  }
}

class _DownloadHeader extends StatelessWidget {
  const _DownloadHeader({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.only(top: 12, bottom: 12),
      decoration: BoxDecoration(
        color: AppColorStyles.backgroundSecondary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: Text(
              'Ứng dụng chính thức',
              style: AppTextStyles.headingXXXSmall(
                context: context,
                color: AppColorStyles.contentPrimary,
              ),
            ),
          ),
          Positioned(
            right: 16,
            top: 0,
            bottom: 0,
            child: IconButton(
              icon: const Icon(Icons.close, color: AppColors.gray400, size: 24),
              onPressed: SoundTap.wrap(onClose),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppDescriptionSection extends StatefulWidget {
  const _AppDescriptionSection({required this.config});

  final DownloadAppConfig? config;

  @override
  State<_AppDescriptionSection> createState() => _AppDescriptionSectionState();
}

class _AppDescriptionSectionState extends State<_AppDescriptionSection> {
  static const int _collapsedMaxLines = 2;

  bool _expanded = false;

  void _toggleExpanded() {
    setState(() => _expanded = !_expanded);
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.config;
    final appName = config?.appName ?? '';
    final type = config?.type ?? '';
    final fullDescription = config?.fullDescription ?? '';
    final iconUrl = config?.urlIconApp ?? '';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ImageHelper.load(
                path: iconUrl.isNotEmpty ? iconUrl : AppImages.iconAppFake,
                width: 62,
                height: 62,
                fit: BoxFit.contain,
                borderRadius: 12,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      appName,
                      style: AppTextStyles.headingSmall(
                        context: context,
                        color: AppColorStyles.contentPrimary,
                      ),
                    ),
                    if (type.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        type,
                        style: AppTextStyles.paragraphSmall(
                          context: context,
                          color: AppColorStyles.contentSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExpandableDescription extends StatelessWidget {
  const _ExpandableDescription({
    required this.text,
    required this.maxLines,
    required this.expanded,
    required this.onToggle,
  });

  final String text;
  final int maxLines;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final descriptionStyle = AppTextStyles.paragraphSmall(
      context: context,
      color: AppColorStyles.contentSecondary,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final tp = TextPainter(
          text: TextSpan(text: text, style: descriptionStyle),
          maxLines: maxLines,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth);
        final isOverflowing = tp.didExceedMaxLines;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: descriptionStyle,
              maxLines: expanded ? null : maxLines,
              overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
            ),
            if (isOverflowing) ...[
              const SizedBox(height: 4),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: SoundTap.wrap(onToggle),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    expanded ? 'Thu gọn' : 'Xem thêm',
                    style: AppTextStyles.paragraphSmall(
                      context: context,
                      color: AppColors.yellow300,
                    ).copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _ContentForApp extends StatelessWidget {
  final String description;

  const _ContentForApp({required this.description});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ImageHelper.load(
          path: AppIcons.iconCheckYellow,
          width: 20,
          height: 20,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            description,
            style: AppTextStyles.paragraphSmall(
              context: context,
              color: AppColorStyles.contentPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _DownloadAppSection extends StatelessWidget {
  const _DownloadAppSection({
    required this.config,
    required this.onAndroidStore,
    required this.onIosStore,
    required this.onApk,
  });

  final DownloadAppConfig? config;
  final VoidCallback onAndroidStore;
  final VoidCallback onIosStore;
  final VoidCallback onApk;

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBuilder.isMobile(context);
    final demoScreenshot = config?.demoScreenshot ?? '';

    final Widget actionArea;
      actionArea = const Align(
        alignment: Alignment.center,
        child: _QrDownloadBox(),
      );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ImageHelper.load(
              path: demoScreenshot,
              width: 162,
              fit: BoxFit.contain,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ContentForApp(description: 'Tăng tốc tải ứng dụng'),
                        SizedBox(height: 12),
                        _ContentForApp(description: 'Nạp rút tức thì'),
                        SizedBox(height: 12),
                        _ContentForApp(description: 'Trải nghiệm mượt mà'),
                        SizedBox(height: 12),
                        _ContentForApp(description: 'Tiết kiệm dung lượng'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    actionArea,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QrDownloadBox extends StatelessWidget {
  const _QrDownloadBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColorStyles.backgroundQuaternary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Quét mã tải app',
            textAlign: TextAlign.center,
            style: AppTextStyles.textStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              height: 18 / 12,
              color: AppColorStyles.contentSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SizedBox(
              width: 102,
              height: 102,
              child: QrImageView(
                data: kDownloadLandingUrl,
                version: QrVersions.auto,
                size: 102,
                backgroundColor: Colors.white,
                padding: EdgeInsets.zero,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: Colors.black,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ImageHelper.load(
                path: AppIcons.iconAppleStore,
                width: 22,
                height: 22,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 12),
              ImageHelper.load(
                path: AppIcons.iconGoogleStore,
                width: 22,
                height: 22,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StoreButton extends StatelessWidget {
  const _StoreButton({required this.path, required this.onTap});

  final String path;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: SoundTap.wrap(onTap),
      child: ImageHelper.load(path: path, width: 172, fit: BoxFit.contain),
    );
  }
}
