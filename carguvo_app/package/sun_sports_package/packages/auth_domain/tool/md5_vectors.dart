import 'dart:convert';

import 'package:auth_domain/auth_domain.dart';
import 'package:crypto/crypto.dart';

/// Tool 1 lần: in các vector MD5 để nhúng literal vào
/// test/hash_utils_test.dart (giá trị tính độc lập bằng dart + package crypto).
void main() {
  String h(String s) => md5.convert(utf8.encode(s)).toString();
  print('md5(abc) = ${h('abc')}');
  print('authSS   = ${HashUtils.createAuthHashSS(
    username: 'user01',
    password: 'pw01',
    displayName: 'Display Name',
    platformId: 2,
    advId: '',
    deviceId: '',
    osVersion: 'iOS 17.0',
    bundleId: 'com.sun.sports',
    brand: 'sun',
    secretKey: 'secret123',
  )}');
  print('gift     = ${HashUtils.createGiftCodeHash(code: 'CODE123', hsk: 'HSK1')}');
  print('otp      = ${HashUtils.createOtpHash(sessionId: 'sess1', otp: '123456', hsk: 'HSK1')}');
  print('checkU   = ${HashUtils.createCheckUsernameHash(username: 'user01', brand: 'sun', secretKey: 'HSK1')}');
  print('loginNat = ${HashUtils.createLoginHash(username: 'user01', password: 'pw01', platformId: 2, deviceId: 'dev1', hsk: 'HSK1')}');
  print('loginWeb = ${HashUtils.createLoginWebHash(username: 'user01', password: 'pw01', platformId: 2, deviceId: 'dev1', timestamp: '1700000000', hsk: 'HSK1')}');
  print('register = ${HashUtils.createRegisterHash(username: 'user01', password: 'pw01', displayName: 'Player One', platformId: 2, osVersion: 'os', deviceId: 'dev1', hsk: 'HSK1')}');
}