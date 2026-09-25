sealed class GameLaunchResult {
  const GameLaunchResult();
}

class GameLaunchSuccess extends GameLaunchResult {
  const GameLaunchSuccess();
}

class GameLaunchFailure extends GameLaunchResult {
  final String message;

  final String? code;

  const GameLaunchFailure(this.message, {this.code});

  @override
  String toString() => 'GameLaunchFailure($code): $message';
}
