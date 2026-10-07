import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class PreferencesNavigator {
  void pushToBetPreferences(BuildContext context);
}

final preferencesNavigatorProvider = Provider<PreferencesNavigator>((ref) {
  throw UnimplementedError(
    'preferencesNavigatorProvider has not been overridden',
  );
});
