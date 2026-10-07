import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_package/providers/auth_provider.dart';
import 'package:app_package/shared/widgets/dialogs/dialog_login_required.dart';

bool requireLogin(BuildContext context, WidgetRef ref) {
  if (ref.read(isAuthenticatedProvider)) return true;
  DialogLoginRequired.show(context);
  return false;
}
