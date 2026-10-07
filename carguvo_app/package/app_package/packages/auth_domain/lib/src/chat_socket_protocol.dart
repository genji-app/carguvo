library;

const List<String> kTokenErrorPatterns = [
  'token expired',
  'token invalid',
  'invalid token',
  'token hết hạn',
  'unauthorized',
  'authentication failed',
  'session expired',
  'jwt expired',
];

bool isTokenErrorMessage(String message) {
  final lowerMsg = message.toLowerCase();
  return kTokenErrorPatterns.any(lowerMsg.contains);
}
