import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CodepayQrTimerArgs {
  final String id;

  final int remainingTime;

  const CodepayQrTimerArgs({required this.id, required this.remainingTime});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CodepayQrTimerArgs && other.id == id);

  @override
  int get hashCode => id.hashCode;
}

class CodepayQrTimerState {
  final int remainingSeconds;
  final bool isExpired;

  const CodepayQrTimerState({
    required this.remainingSeconds,
    this.isExpired = false,
  });

  CodepayQrTimerState copyWith({int? remainingSeconds, bool? isExpired}) {
    return CodepayQrTimerState(
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isExpired: isExpired ?? this.isExpired,
    );
  }

  String get formattedTime {
    final minutes = (remainingSeconds % 3600) ~/ 60;
    final secs = remainingSeconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}

class CodepayQrTimerNotifier extends StateNotifier<CodepayQrTimerState> {
  Timer? _timer;

  CodepayQrTimerNotifier(int initialMilliseconds)
    : super(
        CodepayQrTimerState(remainingSeconds: initialMilliseconds ~/ 1000),
      ) {
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (state.remainingSeconds > 0) {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      } else {
        _timer?.cancel();
        state = state.copyWith(isExpired: true);
      }
    });
  }

  void reset(int initialMilliseconds) {
    _timer?.cancel();
    state = CodepayQrTimerState(remainingSeconds: initialMilliseconds ~/ 1000);
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
