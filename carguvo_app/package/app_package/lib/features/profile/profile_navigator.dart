import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class ProfileNavigator {
  void pushToAvatarSelection(BuildContext context);
  void pushToPhoneVerification(BuildContext context);
  void pushToPersonal(BuildContext context);
  void pushToSecurity(BuildContext context);
  void pushToSettings(BuildContext context);
  void pushToBettingHistory(BuildContext context);
  void close(BuildContext context);
}

final profileNavigatorProvider = Provider<ProfileNavigator>((ref) {
  throw UnimplementedError('profileNavigatorProvider has not been overridden');
});
