class SessionSupersededException implements Exception {
  const SessionSupersededException(this.step, {this.started, this.current});

  final String step;

  final int? started;
  final int? current;

  @override
  String toString() {
    final gen = started == null ? '' : ' (session $started → $current)';
    return 'SessionSupersededException: $step finished for a stale session$gen';
  }
}
