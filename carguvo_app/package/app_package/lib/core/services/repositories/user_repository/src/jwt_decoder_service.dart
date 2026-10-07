import 'package:auth_domain/auth_domain.dart';

abstract class JwtDecoderService {
  Map<String, dynamic>? decodeToken(String token);

  bool isTokenExpired(String token);

  DateTime? getExpirationDate(String token);
}

class JwtDecoderServiceImpl implements JwtDecoderService {
  const JwtDecoderServiceImpl();

  @override
  Map<String, dynamic>? decodeToken(String token) {
    return JwtClaims.decode(token);
  }

  @override
  bool isTokenExpired(String token) {
    if (token.isEmpty) return true;
    return JwtClaims.isExpired(token);
  }

  @override
  DateTime? getExpirationDate(String token) {
    if (token.isEmpty) return null;
    return JwtClaims.expiry(token);
  }
}
