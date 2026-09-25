import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unlock_shorebird_kit/shorebird/update/shorebird_restart_snackbar.dart';

/// Test Bug 2: snackbar colors đúng spec.
/// - Background: white
/// - Content text: black
/// - Action label: blue
void main() {
  group('executeShowShorebirdRestartSnackbar', () {
    testWidgets(
      'SnackBar có background trắng, content đen, action màu xanh',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (BuildContext context) {
                return Scaffold(
                  body: Center(
                    child: ElevatedButton(
                      onPressed: () => executeShowShorebirdRestartSnackbar(
                        context,
                        executeRestartWithFade: (_) async => true,
                      ),
                      child: const Text('trigger'),
                    ),
                  ),
                );
              },
            ),
          ),
        );

        await tester.tap(find.text('trigger'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        // Background trắng.
        final SnackBar snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
        expect(snackBar.backgroundColor, Colors.white);

        // Content text có màu đen.
        final Text contentText = tester.widget<Text>(
          find.text('Bản mới đã được cập nhật. Hãy khởi động lại app.'),
        );
        expect(contentText.style?.color, Colors.black);

        // Action (SnackBarAction) có textColor xanh.
        expect(snackBar.action, isNotNull);
        expect(snackBar.action!.textColor, Colors.blue);
      },
    );

    testWidgets(
      'Tap action label triggers executeRestartWithFade',
      (WidgetTester tester) async {
        bool restartCalled = false;
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (BuildContext context) {
                return Scaffold(
                  body: Center(
                    child: ElevatedButton(
                      onPressed: () => executeShowShorebirdRestartSnackbar(
                        context,
                        executeRestartWithFade: (_) async {
                          restartCalled = true;
                          return true;
                        },
                      ),
                      child: const Text('trigger'),
                    ),
                  ),
                );
              },
            ),
          ),
        );

        await tester.tap(find.text('trigger'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        await tester.tap(find.text('Khởi động lại'));
        await tester.pump();

        expect(restartCalled, true);
      },
    );

    testWidgets(
      'Custom message + actionLabel được render đúng',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (BuildContext context) {
                return Scaffold(
                  body: Center(
                    child: ElevatedButton(
                      onPressed: () => executeShowShorebirdRestartSnackbar(
                        context,
                        executeRestartWithFade: (_) async => true,
                        message: 'Custom message',
                        restartActionLabel: 'Restart now',
                      ),
                      child: const Text('trigger'),
                    ),
                  ),
                );
              },
            ),
          ),
        );

        await tester.tap(find.text('trigger'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.text('Custom message'), findsOneWidget);
        expect(find.text('Restart now'), findsOneWidget);
      },
    );

    // Regression cho Bug 12: sau khi home route bị pushReplacement (simulate
    // SplashScreen → HomeScreen), caller context thành stale nhưng snackbar
    // vẫn phải tap được → executeRestartWithFade vẫn chạy.
    testWidgets(
      'Tap action vẫn hoạt động sau khi pushReplacement unmount caller',
      (WidgetTester tester) async {
        bool restartCalled = false;
        final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();

        await tester.pumpWidget(
          MaterialApp(
            navigatorKey: navKey,
            home: Builder(
              builder: (BuildContext homeContext) {
                return Scaffold(
                  body: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // Show snackbar với context của HomeRoute.
                        executeShowShorebirdRestartSnackbar(
                          homeContext,
                          executeRestartWithFade: (_) async {
                            restartCalled = true;
                            return true;
                          },
                        );
                        // Sau đó navigator replace home → unmount homeContext.
                        navKey.currentState!.pushReplacement(
                          MaterialPageRoute<void>(
                            builder: (_) => const Scaffold(
                              body: Center(child: Text('NewRoute')),
                            ),
                          ),
                        );
                      },
                      child: const Text('trigger'),
                    ),
                  ),
                );
              },
            ),
          ),
        );

        await tester.tap(find.text('trigger'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        // Verify đã push sang route mới.
        expect(find.text('NewRoute'), findsOneWidget);
        // Snackbar vẫn còn (ScaffoldMessenger persist qua route change).
        expect(find.text('Khởi động lại'), findsOneWidget);

        // Tap action label — phải gọi được executeRestartWithFade mặc dù
        // home route đã bị replace.
        await tester.tap(find.text('Khởi động lại'));
        await tester.pump();

        expect(
          restartCalled,
          true,
          reason: 'Snackbar action phải chạy callback dù context caller đã stale',
        );
      },
    );
  });
}
