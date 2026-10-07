class GameCredentials {
  final String userToken;
  final String refreshToken;
  final String userName;
  final String userPassword;

  const GameCredentials({
    required this.userToken,
    required this.refreshToken,
    required this.userName,
    required this.userPassword,
  });

  const GameCredentials.guest()
      : userToken = '',
        refreshToken = '',
        userName = '',
        userPassword = '';

  Map<String, String> toArguments() => {
        'user_token': userToken,
        'refresh_token': refreshToken,
        'user_name': userName,
        'user_password': userPassword,
      };
}
