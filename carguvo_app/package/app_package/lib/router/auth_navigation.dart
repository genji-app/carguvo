import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

bool authOpenIntentional = false;

int _authScreenMounted = 0;

DateTime? _lastAuthOpenRequestAt;

const Duration _authOpenGrace = Duration(seconds: 8);

bool get isAuthScreenOpen => _authScreenMounted > 0;

bool get authRecentlyRequested {
  final at = _lastAuthOpenRequestAt;
  return at != null && DateTime.now().difference(at) < _authOpenGrace;
}

bool get authFlowActive => isAuthScreenOpen || authRecentlyRequested;

void markAuthScreenMounted() => _authScreenMounted++;

void markAuthScreenUnmounted() {
  if (_authScreenMounted > 0) _authScreenMounted--;
  _lastAuthOpenRequestAt = null;
}

Route<dynamic>? authScreenRoute;

void openAuth(BuildContext context, {required bool showLogin}) {
  authOpenIntentional = true;
  _lastAuthOpenRequestAt = DateTime.now();
  GoRouter.of(context).push('/auth/$showLogin');
}
