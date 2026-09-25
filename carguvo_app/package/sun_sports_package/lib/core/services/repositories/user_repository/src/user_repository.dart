import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sun_sports/core/services/models/notification/notification_item.dart';
import 'package:sun_sports/core/services/sportbook_api.dart';

import 'jwt_decoder_service.dart';
import 'jwt_user_info_model.dart';

typedef BalanceFetcher = Future<double?> Function();

class UserRepository {
  UserRepository({
    required SbHttpManager http,
    JwtDecoderService? jwtDecoder,
    String Function()? tokenProvider,
    BalanceFetcher? balanceFetcher,
  }) : _http = http,
       _jwtDecoder = jwtDecoder ?? JwtDecoderServiceImpl(),
       _tokenProvider = tokenProvider ?? (() => SbConfig.instance.wsToken),
       _balanceFetcher = balanceFetcher;

  final SbHttpManager _http;
  final JwtDecoderService _jwtDecoder;

  final BalanceFetcher? _balanceFetcher;

  final String Function() _tokenProvider;

  final _userController = StreamController<User?>.broadcast();
  User? _currentUser;

  Future<double>? _balanceFuture;

  bool? _phoneVerifiedOverride;

  String? _phoneOverride;

  String? _avatarUrlOverride;

  Stream<User?> get userStream => _userController.stream;

  User? get currentUser => _currentUser;

  Future<User?> getUserInfo() async {
    try {
      return await _getUserFromJwt() ?? await _getUserFromHttp();
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(GetUserInfoFailure(error), stackTrace);
    }
  }

  Future<double> getBalance() async {
    try {
      final future = _balanceFuture ??= _fetchBalance().whenComplete(
        () => _balanceFuture = null,
      );
      return await future;
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(GetBalanceFailure(error), stackTrace);
    }
  }

  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      await _http.changePassword(
        oldPassword: currentPassword,
        newPassword: newPassword,
      );
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(ChangePasswordFailure(error), stackTrace);
    }
  }

  Future<void> verifyPhone({
    required String phoneNumber,
    required String otp,
  }) async {
    try {
      await _http.activePhone(otp);
      _markPhoneVerifiedLocally(phoneNumber: phoneNumber);
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(VerifyPhoneFailure(error), stackTrace);
    }
  }

  void updateLocalAvatarUrl(String avatarUrl) {
    _avatarUrlOverride = avatarUrl;
    if (_currentUser != null) _setUser(_currentUser);
  }

  void _markPhoneVerifiedLocally({String? phoneNumber}) {
    _phoneVerifiedOverride = true;
    if (phoneNumber != null) _phoneOverride = _normalizePhone(phoneNumber);
    if (_currentUser != null) _setUser(_currentUser);
  }

  void clearOverrides() {
    _avatarUrlOverride = null;
    _phoneVerifiedOverride = null;
    _phoneOverride = null;
  }

  String _normalizePhone(String phone) {
    final cleaned = phone.trim().replaceAll(RegExp(r'[\s\-]'), '');
    if (cleaned.startsWith('+')) return cleaned.substring(1);
    if (cleaned.startsWith('0')) return '84${cleaned.substring(1)}';
    return cleaned;
  }

  Future<List<NotificationItem>> fetchNotifications() async {
    try {
      final raw = await _http.getNotifications();
      return raw.map(NotificationItem.fromApiMap).toList();
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(GetNotificationsFailure(error), stackTrace);
    }
  }

  void _setUser(User? raw) {
    if (raw == null) {
      _currentUser = null;
      _userController.add(null);
      return;
    }
    _currentUser = raw.copyWith(
      isPhoneVerified: _phoneVerifiedOverride ?? raw.isPhoneVerified,
      phone: _phoneOverride ?? raw.phone,
      avatarUrl: _avatarUrlOverride ?? raw.avatarUrl,
    );
    if (kDebugMode) {
      debugPrint(
        'UserRepository._setUser: overrides('
        'phoneVerified: $_phoneVerifiedOverride, '
        'avatar: ${_avatarUrlOverride != null}) -> $_currentUser',
      );
    }
    _userController.add(_currentUser);
  }

  Future<User?> _getUserFromJwt() async {
    final jwtUserModel = _decodeJwtToken();
    if (jwtUserModel == null) return null;

    UserModel? userModel;
    try {
      await _http.getUserInfo();
      userModel = UserModel.fromHttpMap(_http.user);
    } catch (_) {
    }

    final user = User.merge(jwt: jwtUserModel, userModel: userModel);
    _setUser(user);
    return _currentUser;
  }

  Future<User?> _getUserFromHttp() async {
    await _http.getUserInfo();
    final userModel = UserModel.fromHttpMap(_http.user);

    final user = User.fromUserModel(userModel);
    _setUser(user);
    return _currentUser;
  }

  Future<double> _fetchBalance() async {
    final fetched = await _balanceFetcher?.call();
    final double balance;
    if (fetched != null) {
      balance = fetched;
      _http.setUserBalance(balance);
    } else {
      await _http.getUserBalance();
      balance = _http.userBalance;
    }

    final current = _currentUser;
    if (current != null) {
      _setUser(current.copyWith(balance: balance));
    }

    return balance;
  }

  JwtUserInfoModel? _decodeJwtToken() {
    try {
      final wsToken = _tokenProvider();
      if (wsToken.isEmpty) return null;

      final payload = _jwtDecoder.decodeToken(wsToken);
      if (payload == null) return null;

      return JwtUserInfoModel.fromJson(payload);
    } catch (_) {
      return null;
    }
  }

  void dispose() {
    _userController.close();
  }
}
