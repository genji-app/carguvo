import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/providers/auth_provider.dart';

class AuthenticatedWidget extends ConsumerWidget {
  final Widget child;

  final Widget? fallback;

  const AuthenticatedWidget({super.key, required this.child, this.fallback});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    return isAuthenticated ? child : (fallback ?? const SizedBox.shrink());
  }
}
