class MiniGameAuthData {
  final String info;
  final String signature;
  final String wsToken;
  final String username;
  final String password;

  const MiniGameAuthData({
    required this.info,
    required this.signature,
    required this.wsToken,
    this.username = '',
    this.password = '',
  });
}
