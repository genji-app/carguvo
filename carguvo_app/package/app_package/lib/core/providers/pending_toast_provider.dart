import 'package:flutter_riverpod/flutter_riverpod.dart';

class PendingToast {
  final String message;
  final String? title;
  final bool isError;

  final Duration? duration;

  const PendingToast({
    required this.message,
    this.title,
    this.isError = true,
    this.duration,
  });
}

final pendingToastProvider = StateProvider<PendingToast?>((ref) => null);
