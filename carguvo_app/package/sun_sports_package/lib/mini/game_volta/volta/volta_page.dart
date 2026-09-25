import 'dart:async';

import 'package:flutter/material.dart';

import 'package:sun_sports/core/services/bundle_config_service.dart';
import 'package:sun_sports/core/utils/bundle_defines.dart';
import 'package:sun_sports/core/utils/bundle_manager.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/sport/presentation/widgets/sport_live_chat.dart';
import 'package:sun_sports/shared/widgets/loading/s88_loading.dart';

import '../common/data/volta_http_flutter.dart';
import '../common/data/volta_settings.dart';
import '../common/data/volta_user_api.dart';
import '../common/volta_colors.dart';
import '../common/volta_music.dart';
import '../common/volta_platform_flutter.dart';
import 'volta_screen.dart';

class VoltaPage extends StatefulWidget {
  const VoltaPage({super.key});

  static Future<void> open(BuildContext context) {
    return Navigator.of(context, rootNavigator: true).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const VoltaPage(),
        settings: const RouteSettings(name: routeName),
      ),
    );
  }

  static const String routeName = '/mini/volta';

  @override
  State<VoltaPage> createState() => _VoltaPageState();
}

enum _GateStatus { loading, ready, failed }

class _VoltaPageState extends State<VoltaPage> {
  _GateStatus _status = _GateStatus.loading;

  String? _reason;

  int _attempt = 0;

  @override
  void initState() {
    super.initState();
    FlutterVoltaPlatform.install();
    FlutterVoltaHttpTransport.install();
    unawaited(_load());
  }

  @override
  void dispose() {
    unawaited(VoltaMusic.instance.release());
    super.dispose();
  }

  Future<void> _load({bool force = false}) async {
    final int attempt = ++_attempt;
    if (mounted && _status != _GateStatus.loading) {
      setState(() => _status = _GateStatus.loading);
    }

    if (force) {
      VoltaSettingService.instance.reset();
      VoltaUserService.instance.reset();
    }
    final Future<VoltaSettings?> settingFuture = VoltaSettingService.instance
        .load(force: force)
        .timeout(_bootstrapTimeout, onTimeout: () => null);

    Object? error;
    try {
      await _loadBundle(force: force).timeout(_bootstrapTimeout);
    } catch (e) {
      error = e;
    }

    final VoltaSettings? settings = await settingFuture;

    if (settings?.isUsable ?? false) {
      await VoltaUserService.instance
          .load(force: force)
          .timeout(_userProbeTimeout, onTimeout: () => null);
    }

    if (!mounted || attempt != _attempt) return;

    final bool bundleOk = BundleManager.instance.isBundleComplete(
      BundleDefines.volta,
    );
    final bool settingOk = settings?.isUsable ?? false;
    final bool ok = bundleOk && settingOk;

    final String? reason;
    if (ok) {
      reason = null;
    } else if (!settingOk) {
      debugPrint(
        'VoltaPage: không lấy được cấu hình Volta — '
        'url=${VoltaSettingService.settingUrl}',
      );
      reason = 'Chưa lấy được cấu hình máy chủ Volta.';
    } else {
      reason = _describeFailure(error);
    }

    setState(() {
      _status = ok ? _GateStatus.ready : _GateStatus.failed;
      _reason = reason;
    });
  }

  static const Duration _bootstrapTimeout = Duration(seconds: 30);

  static const Duration _userProbeTimeout = Duration(seconds: 8);

  Future<void> _loadBundle({required bool force}) async {
    if (!force) {
      await BundleManager.instance.loadBundle(BundleDefines.volta);
      return;
    }
    BundleConfigService.instance.reset();
    await BundleManager.instance.loadGlobalConfig();
    await BundleManager.instance.reloadBundleDeep(BundleDefines.volta);
  }

  String _describeFailure(Object? error) {
    final BundleManager manager = BundleManager.instance;
    final Set<String> failedItems = manager.failedItemsOf(BundleDefines.volta);

    if (error is TimeoutException) {
      debugPrint(
        'VoltaPage: quá ${_bootstrapTimeout.inSeconds}s vẫn chưa vào được màn '
        '— bundle="${BundleDefines.volta}"',
      );
      return 'Mạng quá chậm — quá ${_bootstrapTimeout.inSeconds} giây chưa '
          'tải xong.';
    }

    if (failedItems.isNotEmpty) {
      debugPrint(
        'VoltaPage: bundle "${BundleDefines.volta}" thiếu '
        '${failedItems.length} tệp: ${failedItems.join(', ')}',
      );
      final List<String> sample = failedItems.take(3).toList();
      final String more = failedItems.length > sample.length ? '…' : '';
      return 'Thiếu ${failedItems.length} tệp trong gói: '
          '${sample.join(', ')}$more';
    }

    if (BundleConfigService.instance.getBundleHash(BundleDefines.volta).isEmpty) {
      debugPrint(
        'VoltaPage: bundle_config trên CDN không có "${BundleDefines.volta}" '
        '→ URL rơi về bản không hash và 404. Cần chạy '
        'tools/upload_resources.py (và cập nhật app_versions trong '
        'version_resource_config.json) rồi thử lại. err=$error',
      );
      return 'Máy chủ chưa có gói "${BundleDefines.volta}".';
    }

    if (!manager.isBundleLoaded(BundleDefines.volta)) {
      debugPrint(
        'VoltaPage: không tải được gói "${BundleDefines.volta}" — '
        'url=${manager.getBundleConfigUrl(BundleDefines.volta)} err=$error',
      );
      return 'Chưa tải được gói "${BundleDefines.volta}" — kiểm tra gói đã '
          'được đẩy lên CDN chưa.';
    }

    debugPrint(
      'VoltaPage: bundle "${BundleDefines.volta}" chưa hoàn tất — $error',
    );
    return 'Gói dữ liệu chưa hoàn tất.';
  }

  void _onPointerDown(PointerDownEvent event) {
    final FocusNode? focused = FocusManager.instance.primaryFocus;
    if (focused == null || !focused.hasFocus) return;

    final BuildContext? owner = focused.context;
    if (owner == null) {
      focused.unfocus();
      return;
    }

    final RenderObject? bounds = _chatBoundsOf(owner) ?? owner.findRenderObject();
    if (bounds is RenderBox && bounds.hasSize && bounds.attached) {
      final Offset local = bounds.globalToLocal(event.position);
      final bool inside =
          local.dx >= 0 &&
          local.dy >= 0 &&
          local.dx <= bounds.size.width &&
          local.dy <= bounds.size.height;
      if (inside) return;
    }

    focused.unfocus();
  }

  static RenderObject? _chatBoundsOf(BuildContext inner) {
    RenderObject? found;
    inner.visitAncestorElements((Element element) {
      if (element.widget is SportLiveChat) {
        found = element.findRenderObject();
        return false;
      }
      return true;
    });
    return found;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: Listener(
        onPointerDown: _onPointerDown,
        child: switch (_status) {
          _GateStatus.loading => const _VoltaLoadingView(),
          _GateStatus.ready => const VoltaScreen(),
          _GateStatus.failed => _VoltaFailedView(
            reason: _reason,
            onRetry: () => unawaited(_load(force: true)),
            onClose: () => Navigator.of(context).maybePop(),
          ),
        },
      ),
    );
  }
}

class _VoltaLoadingView extends StatelessWidget {
  const _VoltaLoadingView();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Colors.black,
      child: S88Loading(
        backgroundColor: Colors.transparent,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }
}

class _VoltaFailedView extends StatelessWidget {
  const _VoltaFailedView({
    required this.onRetry,
    required this.onClose,
    this.reason,
  });

  final String? reason;
  final VoidCallback onRetry;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.wifi_off_rounded,
              size: 40,
              color: VoltaColors.contentSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              'Không tải được dữ liệu game',
              textAlign: TextAlign.center,
              style: AppTextStyles.labelSmall(
                color: VoltaColors.contentPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Kiểm tra kết nối mạng rồi thử lại.',
              textAlign: TextAlign.center,
              style: AppTextStyles.labelXSmall(
                color: VoltaColors.contentSecondary,
              ),
            ),
            if (reason != null) ...<Widget>[
              const SizedBox(height: 8),
              Text(
                reason!,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.paragraphXXSmall(
                  color: VoltaColors.contentTertiary,
                ),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextButton(onPressed: onClose, child: const Text('Đóng')),
                const SizedBox(width: 12),
                FilledButton(onPressed: onRetry, child: const Text('Thử lại')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
