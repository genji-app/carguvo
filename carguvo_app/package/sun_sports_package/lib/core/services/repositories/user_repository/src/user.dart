import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sun_sports/core/services/models/user_model.dart';
import 'package:sun_sports/core/services/repositories/user_repository/src/jwt_user_info_model.dart';
import 'package:sun_sports/core/utils/extensions/string_helper.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
sealed class User with _$User {
  const User._();

  const factory User({
    required String uid,
    required String username,
    required String displayName,
    required String custLogin,
    required String custId,

    required double balance,
    required String avatarUrl,
    required String brand,

    @Default('VND') String currency,
    @Default(0) int gender,
    String? email,
    String? phone,

    @Default('Active') String status,
    @Default(false) bool isBanned,
    @Default(false) bool isActivated,
    @Default(false) bool isPhoneVerified,
    @Default(false) bool isVerifiedBankAccount,

    @Default(0) int platformId,
    @Default(0) int customerId,

    @Default(false) bool isBot,
    @Default(false) bool isLockChat,
    @Default(false) bool isMute,
    @Default(false) bool canViewStat,
    @Default(false) bool isMerchant,
    @Default(false) bool playEventLobby,
    @Default([]) List<dynamic> lockGames,

    String? affId,
    String? ipAddress,
    int? timestamp,
    int? regTime,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  factory User.fromJwt(JwtUserInfoModel jwt) {
    return User(
      uid: jwt.userId,
      username: jwt.username,
      displayName: jwt.displayName,
      custLogin: jwt.username,
      custId: jwt.customerId.toString(),
      balance: jwt.amount.toDouble(),
      currency: 'VND',
      avatarUrl: jwt.avatar,
      brand: jwt.brand,
      gender: jwt.gender,
      phone: jwt.phone,
      status: jwt.banned ? 'Banned' : 'Active',
      isBanned: jwt.banned,
      isActivated: jwt.deposit,
      isPhoneVerified: jwt.phoneVerified,
      isVerifiedBankAccount: jwt.verifiedBankAccount,
      platformId: jwt.platformId,
      customerId: jwt.customerId,
      isBot: jwt.bot,
      isLockChat: jwt.lockChat,
      isMute: jwt.mute,
      canViewStat: jwt.canViewStat,
      isMerchant: jwt.isMerchant,
      playEventLobby: jwt.playEventLobby,
      lockGames: jwt.lockGames,
      affId: jwt.affId,
      ipAddress: jwt.ipAddress,
      timestamp: jwt.timestamp,
      regTime: jwt.regTime,
    );
  }

  factory User.fromUserModel(UserModel userModel) {
    return User(
      uid: userModel.uid,
      username: userModel.custLogin,
      displayName: userModel.displayName,
      custLogin: userModel.custLogin,
      custId: userModel.custId,
      balance: userModel.balance,
      currency: userModel.currency,
      avatarUrl: '',
      brand: '',
      email: userModel.email,
      phone: userModel.phone,
      status: userModel.status,
      isBanned: userModel.status == 'Banned',
    );
  }

  factory User.merge({required JwtUserInfoModel jwt, UserModel? userModel}) {
    final base = User.fromJwt(jwt);

    if (userModel == null) {
      return base;
    }

    return base.copyWith(
      email: userModel.email ?? base.email,
      balance: userModel.balance,
    );
  }

  factory User.empty() => const User(
    uid: '',
    username: '',
    displayName: 'Guest',
    custLogin: '',
    custId: '',
    balance: 0.0,
    currency: 'VND',
    avatarUrl: '',
    brand: '',
    status: 'Inactive',
  );
}

extension UserX on User {
  bool get isLoggedIn => uid.isNotEmpty && custId.isNotEmpty;

  bool get isActive => status == 'Active' && !isBanned;

  String get formattedBalance => '${balance.toStringAsFixed(0)}K $currency';

  double get balanceInVND => balance ;

  bool get canChat => !isLockChat && !isMute && !isBanned;

  bool get canBet => isActive && !isBanned;

  String get genderDisplay {
    switch (gender) {
      case 1:
        return 'Male';
      case 2:
        return 'Female';
      default:
        return 'Unknown';
    }
  }

  String get maskedPhone => StringHelper.maskPhone(phone);
}
