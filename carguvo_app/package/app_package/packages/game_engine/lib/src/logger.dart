typedef GameEngineLogger = void Function(
  String level,
  String message, {
  Object? error,
  StackTrace? stackTrace,
});

void silentLogger(
  String level,
  String message, {
  Object? error,
  StackTrace? stackTrace,
}) {}
