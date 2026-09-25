import 'package:carguvo/app.dart';
import 'package:carguvo/core/default_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/sun_sports_init.dart';
import 'package:sun_sports/sun_sports_root.dart';
import 'package:terminate_restart/terminate_restart.dart';
import 'package:unlock_shorebird_kit/core/net_diag.dart';

import 'package:carguvo/core/restart_scope.dart';
import 'package:carguvo/data/local/hive_service.dart';
import 'package:unlock_shorebird_kit/flow/unlock_flow_coordinator.dart';
import 'package:unlock_shorebird_kit/screens/splash_mode_screen.dart';

/// ## Thứ tự khởi động
///
/// 1. `HiveService.init()` — storage của app vỏ carguvo.
/// 2. `TerminateRestart.instance.initialize()` — đăng ký channel restart.
///    BẮT BUỘC gọi trước khi dùng, và phải có trong BINARY (Shorebird patch
///    không thêm được plugin native).
/// 3. `RestartScope` bọc ngoài cùng để overlay fade-to-black sống sót qua
///    mọi lần swap cây của [RootGate].
/// 4. `RootGate` chạy unlock flow rồi tự chọn cây (vỏ / betting).
///
/// `SunSports.init()` KHÔNG gọi ở đây — xem [RootGate] (init lười, chỉ khi
/// thật sự vào betting).
///
/// ⚠️ iOS: để app tự mở lại sau khi `terminate_restart` gọi `exit()`,
/// `ios/Runner/Info.plist` phải có `CFBundleURLTypes` với scheme
/// `$(PRODUCT_BUNDLE_IDENTIFIER)`. Thiếu key này thì app chỉ tắt, user phải
/// tự tap icon (patch vẫn apply ở lần mở kế tiếp).
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  netDiag('main', 'HiveService.init bắt đầu');
  await HiveService.init();
  netDiag('main', 'HiveService.init xong');

  TerminateRestart.instance.initialize();
    final overrides = await SunSports.init();
  runApp(
    ProviderScope(
      overrides: overrides,
      child: const RestartScope(
        child: RootGate(),
      ),
    ),
    // khi build release thì dùng code dưới này
    // RestartScope(
    //   child: MaterialApp(
    //     title: 'Carguvo',
    //     debugShowCheckedModeBanner: false,
    //     home: SplashModeScreen(
    //       bettingScreenBuilder: () => const CarguvoApp(),
    //       fakeScreenBuilder: () => const CarguvoApp(),
    //       executeRestartWithFade: RestartScope.executeRestartWithFade,
    //       splashScreenBuilder: () => const DefaultSplashScreen(),
    //     ),
    //   ),
    // ),
  );
}


/// Root gate đảm bảo chỉ có DUY NHẤT một [MaterialApp] tồn tại tại mỗi thời
/// điểm — đây là điểm mấu chốt sửa lỗi "màn hình đen sau khi login".
///
/// Trước đây cây widget là:
///
/// ```
/// MaterialApp (host)            ← Navigator cho splash/caro + dialog
///   └─ SplashModeScreen
///        └─ App (betting)
///             └─ MaterialApp.router  ← LỒNG bên trong host → màn hình đen
/// ```
///
/// `MaterialApp.router` lồng trong một `MaterialApp` khác khiến router con
/// không hiển thị sau khi điều hướng (flutter/flutter#142585) → sau khi login
/// chỉ còn nền đen, toast vẫn nổi vì vẽ trên root overlay của host.
///
/// [RootGate] tách hai trạng thái:
/// - Splash / caro: vẫn cần `MaterialApp` của host (SplashModeScreen show
///   dialog retry/shorebird restart bằng `Navigator`; caro dùng Navigator để
///   điều hướng).
/// - Betting: SWAP root sang thẳng [App] — lúc này [App] tự dựng
///   `MaterialApp.router` là `MaterialApp` DUY NHẤT, không còn lồng nhau.
class RootGate extends StatefulWidget {
  const RootGate({super.key});

  @override
  State<RootGate> createState() => _RootGateState();
}

class _RootGateState extends State<RootGate> {
  bool _betting = false;

  void _onModeChanged(AppMode mode) {
    if (!mounted) return;
    final betting = mode == AppMode.betting;
    if (betting == _betting) return;
    setState(() => _betting = betting);
  }

  @override
  Widget build(BuildContext context) {
    // Betting: [App] là MaterialApp DUY NHẤT ở root (KHÔNG lồng host).
    if (_betting) {
      return const SunSportsApp();
    }

    // Splash / caro: host MaterialApp cung cấp Navigator cho SplashModeScreen
    // (dialog) và cho caro.
    return MaterialApp(
      title: 'Carguvo',
      debugShowCheckedModeBanner: false,
      home: SplashModeScreen(
        bettingScreenBuilder: () => const SunSportsApp(),
        fakeScreenBuilder: () => const CarguvoApp(),
        executeRestartWithFade: RestartScope.executeRestartWithFade,
        splashScreenBuilder: () => const DefaultSplashScreen(),
        onModeChanged: _onModeChanged,
      ),
    );
  }
}
