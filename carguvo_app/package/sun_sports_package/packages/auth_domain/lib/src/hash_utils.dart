import 'package:crypto/crypto.dart';
import 'dart:convert';

class HashUtils {
  HashUtils._();

  static String md5Hash(String input) {
    return md5.convert(utf8.encode(input)).toString();
  }

  static String createRegisterHash({
    required String username,
    required String password,
    required String displayName,
    required int platformId,
    required String osVersion,
    required String deviceId,
    required String hsk,
  }) {
    final input =
        username +
        password +
        displayName +
        platformId.toString() +
        osVersion +
        deviceId +
        hsk;
    return md5Hash(input);
  }

  static String createLoginHash({
    required String username,
    required String password,
    required int platformId,
    required String deviceId,
    required String hsk,
  }) {
    final input = username + password + platformId.toString() + deviceId + hsk;
    return md5Hash(input);
  }

  static String createLoginWebHash({
    required String username,
    required String password,
    required int platformId,
    required String deviceId,
    required String timestamp,
    required String hsk,
  }) {
    final input =
        username +
        password +
        platformId.toString() +
        deviceId +
        timestamp +
        hsk;
    return md5Hash(input);
  }

  static String createOtpHash({
    required String sessionId,
    required String otp,
    required String hsk,
  }) {
    final input = sessionId + otp + hsk;
    return md5Hash(input);
  }

  static String createCheckUsernameHash({
    required String username,
    required String brand,
    required String secretKey,
  }) {
    final input = username + brand + secretKey;
    return md5Hash(input);
  }

  static String createGiftCodeHash({
    required String code,
    required String hsk,
  }) {
    final input = code + hsk;
    return md5Hash(input);
  }

  static String createAuthHashSS({
    required String username,
    required String password,
    required String displayName,
    required int platformId,
    required String advId,
    required String deviceId,
    required String osVersion,
    required String bundleId,
    required String brand,
    required String secretKey,
  }) {
    final input =
        username +
        password +
        displayName +
        platformId.toString() +
        advId +
        deviceId +
        osVersion +
        bundleId +
        brand +
        secretKey;
    return md5Hash(input);
  }
}
