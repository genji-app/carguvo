import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'change_password/change_password_screen.dart';

abstract class SecurityNavigator {
  void pushToChangePassword(BuildContext context);
  void onPasswordChangedSuccess(BuildContext context, WidgetRef ref);
}

class SecurityNavigatorStandard implements SecurityNavigator {
  const SecurityNavigatorStandard();

  @override
  void pushToChangePassword(BuildContext context) {
    Navigator.of(context).push(ChangePasswordScreen.route());
  }

  @override
  void onPasswordChangedSuccess(BuildContext context, WidgetRef ref) {
  }
}

final securityNavigatorProvider = Provider<SecurityNavigator>((ref) {
  return const SecurityNavigatorStandard();
});
