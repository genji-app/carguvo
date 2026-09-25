// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_entity.dart';

// dart format off
T _$identity<T>(T value) => value;

mixin _$AuthEntity {
  String get accessToken;
  String get refreshToken;
  String get wsToken;
  String? get signature;
  UserInfo? get userInfo;
  bool get showPopupChangeUsername;
  bool get showPopupChangeBrand;

  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AuthEntityCopyWith<AuthEntity> get copyWith => _$AuthEntityCopyWithImpl<AuthEntity>(this as AuthEntity, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AuthEntity &&
            (identical(other.accessToken, accessToken) || other.accessToken == accessToken) &&
            (identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken) &&
            (identical(other.wsToken, wsToken) || other.wsToken == wsToken) &&
            (identical(other.signature, signature) || other.signature == signature) &&
            (identical(other.userInfo, userInfo) || other.userInfo == userInfo) &&
            (identical(other.showPopupChangeUsername, showPopupChangeUsername) ||
                other.showPopupChangeUsername == showPopupChangeUsername) &&
            (identical(other.showPopupChangeBrand, showPopupChangeBrand) ||
                other.showPopupChangeBrand == showPopupChangeBrand));
  }

  @override
  int get hashCode => Object.hash(runtimeType, accessToken, refreshToken, wsToken, signature, userInfo,
      showPopupChangeUsername, showPopupChangeBrand);

  @override
  String toString() {
    return 'AuthEntity(accessToken: $accessToken, refreshToken: $refreshToken, wsToken: $wsToken, signature: $signature, userInfo: $userInfo, showPopupChangeUsername: $showPopupChangeUsername, showPopupChangeBrand: $showPopupChangeBrand)';
  }
}

abstract mixin class $AuthEntityCopyWith<$Res> {
  factory $AuthEntityCopyWith(AuthEntity value, $Res Function(AuthEntity) _then) = _$AuthEntityCopyWithImpl;
  @useResult
  $Res call(
      {String accessToken,
      String refreshToken,
      String wsToken,
      String? signature,
      UserInfo? userInfo,
      bool showPopupChangeUsername,
      bool showPopupChangeBrand});

  $UserInfoCopyWith<$Res>? get userInfo;
}

class _$AuthEntityCopyWithImpl<$Res> implements $AuthEntityCopyWith<$Res> {
  _$AuthEntityCopyWithImpl(this._self, this._then);

  final AuthEntity _self;
  final $Res Function(AuthEntity) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accessToken = null,
    Object? refreshToken = null,
    Object? wsToken = null,
    Object? signature = freezed,
    Object? userInfo = freezed,
    Object? showPopupChangeUsername = null,
    Object? showPopupChangeBrand = null,
  }) {
    return _then(_self.copyWith(
      accessToken: null == accessToken
          ? _self.accessToken
          : accessToken // ignore: cast_nullable_to_non_nullable
              as String,
      refreshToken: null == refreshToken
          ? _self.refreshToken
          : refreshToken // ignore: cast_nullable_to_non_nullable
              as String,
      wsToken: null == wsToken
          ? _self.wsToken
          : wsToken // ignore: cast_nullable_to_non_nullable
              as String,
      signature: freezed == signature
          ? _self.signature
          : signature // ignore: cast_nullable_to_non_nullable
              as String?,
      userInfo: freezed == userInfo
          ? _self.userInfo
          : userInfo // ignore: cast_nullable_to_non_nullable
              as UserInfo?,
      showPopupChangeUsername: null == showPopupChangeUsername
          ? _self.showPopupChangeUsername
          : showPopupChangeUsername // ignore: cast_nullable_to_non_nullable
              as bool,
      showPopupChangeBrand: null == showPopupChangeBrand
          ? _self.showPopupChangeBrand
          : showPopupChangeBrand // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }

  @override
  @pragma('vm:prefer-inline')
  $UserInfoCopyWith<$Res>? get userInfo {
    if (_self.userInfo == null) {
      return null;
    }

    return $UserInfoCopyWith<$Res>(_self.userInfo!, (value) {
      return _then(_self.copyWith(userInfo: value));
    });
  }
}

extension AuthEntityPatterns on AuthEntity {

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_AuthEntity value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AuthEntity() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_AuthEntity value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AuthEntity():
        return $default(_that);
    }
  }

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_AuthEntity value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AuthEntity() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(String accessToken, String refreshToken, String wsToken, String? signature, UserInfo? userInfo,
            bool showPopupChangeUsername, bool showPopupChangeBrand)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AuthEntity() when $default != null:
        return $default(_that.accessToken, _that.refreshToken, _that.wsToken, _that.signature, _that.userInfo,
            _that.showPopupChangeUsername, _that.showPopupChangeBrand);
      case _:
        return orElse();
    }
  }

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(String accessToken, String refreshToken, String wsToken, String? signature, UserInfo? userInfo,
            bool showPopupChangeUsername, bool showPopupChangeBrand)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AuthEntity():
        return $default(_that.accessToken, _that.refreshToken, _that.wsToken, _that.signature, _that.userInfo,
            _that.showPopupChangeUsername, _that.showPopupChangeBrand);
    }
  }

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(String accessToken, String refreshToken, String wsToken, String? signature, UserInfo? userInfo,
            bool showPopupChangeUsername, bool showPopupChangeBrand)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AuthEntity() when $default != null:
        return $default(_that.accessToken, _that.refreshToken, _that.wsToken, _that.signature, _that.userInfo,
            _that.showPopupChangeUsername, _that.showPopupChangeBrand);
      case _:
        return null;
    }
  }
}

class _AuthEntity implements AuthEntity {
  const _AuthEntity(
      {required this.accessToken,
      required this.refreshToken,
      required this.wsToken,
      this.signature,
      this.userInfo,
      this.showPopupChangeUsername = false,
      this.showPopupChangeBrand = false});

  @override
  final String accessToken;
  @override
  final String refreshToken;
  @override
  final String wsToken;
  @override
  final String? signature;
  @override
  final UserInfo? userInfo;
  @override
  @JsonKey()
  final bool showPopupChangeUsername;
  @override
  @JsonKey()
  final bool showPopupChangeBrand;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AuthEntityCopyWith<_AuthEntity> get copyWith => __$AuthEntityCopyWithImpl<_AuthEntity>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AuthEntity &&
            (identical(other.accessToken, accessToken) || other.accessToken == accessToken) &&
            (identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken) &&
            (identical(other.wsToken, wsToken) || other.wsToken == wsToken) &&
            (identical(other.signature, signature) || other.signature == signature) &&
            (identical(other.userInfo, userInfo) || other.userInfo == userInfo) &&
            (identical(other.showPopupChangeUsername, showPopupChangeUsername) ||
                other.showPopupChangeUsername == showPopupChangeUsername) &&
            (identical(other.showPopupChangeBrand, showPopupChangeBrand) ||
                other.showPopupChangeBrand == showPopupChangeBrand));
  }

  @override
  int get hashCode => Object.hash(runtimeType, accessToken, refreshToken, wsToken, signature, userInfo,
      showPopupChangeUsername, showPopupChangeBrand);

  @override
  String toString() {
    return 'AuthEntity(accessToken: $accessToken, refreshToken: $refreshToken, wsToken: $wsToken, signature: $signature, userInfo: $userInfo, showPopupChangeUsername: $showPopupChangeUsername, showPopupChangeBrand: $showPopupChangeBrand)';
  }
}

abstract mixin class _$AuthEntityCopyWith<$Res> implements $AuthEntityCopyWith<$Res> {
  factory _$AuthEntityCopyWith(_AuthEntity value, $Res Function(_AuthEntity) _then) = __$AuthEntityCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String accessToken,
      String refreshToken,
      String wsToken,
      String? signature,
      UserInfo? userInfo,
      bool showPopupChangeUsername,
      bool showPopupChangeBrand});

  @override
  $UserInfoCopyWith<$Res>? get userInfo;
}

class __$AuthEntityCopyWithImpl<$Res> implements _$AuthEntityCopyWith<$Res> {
  __$AuthEntityCopyWithImpl(this._self, this._then);

  final _AuthEntity _self;
  final $Res Function(_AuthEntity) _then;

  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? accessToken = null,
    Object? refreshToken = null,
    Object? wsToken = null,
    Object? signature = freezed,
    Object? userInfo = freezed,
    Object? showPopupChangeUsername = null,
    Object? showPopupChangeBrand = null,
  }) {
    return _then(_AuthEntity(
      accessToken: null == accessToken
          ? _self.accessToken
          : accessToken // ignore: cast_nullable_to_non_nullable
              as String,
      refreshToken: null == refreshToken
          ? _self.refreshToken
          : refreshToken // ignore: cast_nullable_to_non_nullable
              as String,
      wsToken: null == wsToken
          ? _self.wsToken
          : wsToken // ignore: cast_nullable_to_non_nullable
              as String,
      signature: freezed == signature
          ? _self.signature
          : signature // ignore: cast_nullable_to_non_nullable
              as String?,
      userInfo: freezed == userInfo
          ? _self.userInfo
          : userInfo // ignore: cast_nullable_to_non_nullable
              as UserInfo?,
      showPopupChangeUsername: null == showPopupChangeUsername
          ? _self.showPopupChangeUsername
          : showPopupChangeUsername // ignore: cast_nullable_to_non_nullable
              as bool,
      showPopupChangeBrand: null == showPopupChangeBrand
          ? _self.showPopupChangeBrand
          : showPopupChangeBrand // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }

  @override
  @pragma('vm:prefer-inline')
  $UserInfoCopyWith<$Res>? get userInfo {
    if (_self.userInfo == null) {
      return null;
    }

    return $UserInfoCopyWith<$Res>(_self.userInfo!, (value) {
      return _then(_self.copyWith(userInfo: value));
    });
  }
}

mixin _$UserInfo {
  String? get visibleUserName;
  String? get displayName;
  int? get gold;
  int? get chip;
  int? get safe;
  String? get visibleUserId;
  String? get phone;
  String? get email;
  int? get vipPoint;
  int? get vip;
  String? get avatar;
  int? get gender;
  String? get birthDay;
  String? get brand;

  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $UserInfoCopyWith<UserInfo> get copyWith => _$UserInfoCopyWithImpl<UserInfo>(this as UserInfo, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is UserInfo &&
            (identical(other.visibleUserName, visibleUserName) || other.visibleUserName == visibleUserName) &&
            (identical(other.displayName, displayName) || other.displayName == displayName) &&
            (identical(other.gold, gold) || other.gold == gold) &&
            (identical(other.chip, chip) || other.chip == chip) &&
            (identical(other.safe, safe) || other.safe == safe) &&
            (identical(other.visibleUserId, visibleUserId) || other.visibleUserId == visibleUserId) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.vipPoint, vipPoint) || other.vipPoint == vipPoint) &&
            (identical(other.vip, vip) || other.vip == vip) &&
            (identical(other.avatar, avatar) || other.avatar == avatar) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.birthDay, birthDay) || other.birthDay == birthDay) &&
            (identical(other.brand, brand) || other.brand == brand));
  }

  @override
  int get hashCode => Object.hash(runtimeType, visibleUserName, displayName, gold, chip, safe, visibleUserId, phone,
      email, vipPoint, vip, avatar, gender, birthDay, brand);

  @override
  String toString() {
    return 'UserInfo(visibleUserName: $visibleUserName, displayName: $displayName, gold: $gold, chip: $chip, safe: $safe, visibleUserId: $visibleUserId, phone: $phone, email: $email, vipPoint: $vipPoint, vip: $vip, avatar: $avatar, gender: $gender, birthDay: $birthDay, brand: $brand)';
  }
}

abstract mixin class $UserInfoCopyWith<$Res> {
  factory $UserInfoCopyWith(UserInfo value, $Res Function(UserInfo) _then) = _$UserInfoCopyWithImpl;
  @useResult
  $Res call(
      {String? visibleUserName,
      String? displayName,
      int? gold,
      int? chip,
      int? safe,
      String? visibleUserId,
      String? phone,
      String? email,
      int? vipPoint,
      int? vip,
      String? avatar,
      int? gender,
      String? birthDay,
      String? brand});
}

class _$UserInfoCopyWithImpl<$Res> implements $UserInfoCopyWith<$Res> {
  _$UserInfoCopyWithImpl(this._self, this._then);

  final UserInfo _self;
  final $Res Function(UserInfo) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? visibleUserName = freezed,
    Object? displayName = freezed,
    Object? gold = freezed,
    Object? chip = freezed,
    Object? safe = freezed,
    Object? visibleUserId = freezed,
    Object? phone = freezed,
    Object? email = freezed,
    Object? vipPoint = freezed,
    Object? vip = freezed,
    Object? avatar = freezed,
    Object? gender = freezed,
    Object? birthDay = freezed,
    Object? brand = freezed,
  }) {
    return _then(_self.copyWith(
      visibleUserName: freezed == visibleUserName
          ? _self.visibleUserName
          : visibleUserName // ignore: cast_nullable_to_non_nullable
              as String?,
      displayName: freezed == displayName
          ? _self.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String?,
      gold: freezed == gold
          ? _self.gold
          : gold // ignore: cast_nullable_to_non_nullable
              as int?,
      chip: freezed == chip
          ? _self.chip
          : chip // ignore: cast_nullable_to_non_nullable
              as int?,
      safe: freezed == safe
          ? _self.safe
          : safe // ignore: cast_nullable_to_non_nullable
              as int?,
      visibleUserId: freezed == visibleUserId
          ? _self.visibleUserId
          : visibleUserId // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _self.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      vipPoint: freezed == vipPoint
          ? _self.vipPoint
          : vipPoint // ignore: cast_nullable_to_non_nullable
              as int?,
      vip: freezed == vip
          ? _self.vip
          : vip // ignore: cast_nullable_to_non_nullable
              as int?,
      avatar: freezed == avatar
          ? _self.avatar
          : avatar // ignore: cast_nullable_to_non_nullable
              as String?,
      gender: freezed == gender
          ? _self.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as int?,
      birthDay: freezed == birthDay
          ? _self.birthDay
          : birthDay // ignore: cast_nullable_to_non_nullable
              as String?,
      brand: freezed == brand
          ? _self.brand
          : brand // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

extension UserInfoPatterns on UserInfo {

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_UserInfo value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _UserInfo() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_UserInfo value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UserInfo():
        return $default(_that);
    }
  }

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_UserInfo value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UserInfo() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String? visibleUserName,
            String? displayName,
            int? gold,
            int? chip,
            int? safe,
            String? visibleUserId,
            String? phone,
            String? email,
            int? vipPoint,
            int? vip,
            String? avatar,
            int? gender,
            String? birthDay,
            String? brand)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _UserInfo() when $default != null:
        return $default(
            _that.visibleUserName,
            _that.displayName,
            _that.gold,
            _that.chip,
            _that.safe,
            _that.visibleUserId,
            _that.phone,
            _that.email,
            _that.vipPoint,
            _that.vip,
            _that.avatar,
            _that.gender,
            _that.birthDay,
            _that.brand);
      case _:
        return orElse();
    }
  }

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String? visibleUserName,
            String? displayName,
            int? gold,
            int? chip,
            int? safe,
            String? visibleUserId,
            String? phone,
            String? email,
            int? vipPoint,
            int? vip,
            String? avatar,
            int? gender,
            String? birthDay,
            String? brand)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UserInfo():
        return $default(
            _that.visibleUserName,
            _that.displayName,
            _that.gold,
            _that.chip,
            _that.safe,
            _that.visibleUserId,
            _that.phone,
            _that.email,
            _that.vipPoint,
            _that.vip,
            _that.avatar,
            _that.gender,
            _that.birthDay,
            _that.brand);
    }
  }

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String? visibleUserName,
            String? displayName,
            int? gold,
            int? chip,
            int? safe,
            String? visibleUserId,
            String? phone,
            String? email,
            int? vipPoint,
            int? vip,
            String? avatar,
            int? gender,
            String? birthDay,
            String? brand)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UserInfo() when $default != null:
        return $default(
            _that.visibleUserName,
            _that.displayName,
            _that.gold,
            _that.chip,
            _that.safe,
            _that.visibleUserId,
            _that.phone,
            _that.email,
            _that.vipPoint,
            _that.vip,
            _that.avatar,
            _that.gender,
            _that.birthDay,
            _that.brand);
      case _:
        return null;
    }
  }
}

class _UserInfo implements UserInfo {
  const _UserInfo(
      {this.visibleUserName,
      this.displayName,
      this.gold,
      this.chip,
      this.safe,
      this.visibleUserId,
      this.phone,
      this.email,
      this.vipPoint,
      this.vip,
      this.avatar,
      this.gender,
      this.birthDay,
      this.brand});

  @override
  final String? visibleUserName;
  @override
  final String? displayName;
  @override
  final int? gold;
  @override
  final int? chip;
  @override
  final int? safe;
  @override
  final String? visibleUserId;
  @override
  final String? phone;
  @override
  final String? email;
  @override
  final int? vipPoint;
  @override
  final int? vip;
  @override
  final String? avatar;
  @override
  final int? gender;
  @override
  final String? birthDay;
  @override
  final String? brand;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$UserInfoCopyWith<_UserInfo> get copyWith => __$UserInfoCopyWithImpl<_UserInfo>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _UserInfo &&
            (identical(other.visibleUserName, visibleUserName) || other.visibleUserName == visibleUserName) &&
            (identical(other.displayName, displayName) || other.displayName == displayName) &&
            (identical(other.gold, gold) || other.gold == gold) &&
            (identical(other.chip, chip) || other.chip == chip) &&
            (identical(other.safe, safe) || other.safe == safe) &&
            (identical(other.visibleUserId, visibleUserId) || other.visibleUserId == visibleUserId) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.vipPoint, vipPoint) || other.vipPoint == vipPoint) &&
            (identical(other.vip, vip) || other.vip == vip) &&
            (identical(other.avatar, avatar) || other.avatar == avatar) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.birthDay, birthDay) || other.birthDay == birthDay) &&
            (identical(other.brand, brand) || other.brand == brand));
  }

  @override
  int get hashCode => Object.hash(runtimeType, visibleUserName, displayName, gold, chip, safe, visibleUserId, phone,
      email, vipPoint, vip, avatar, gender, birthDay, brand);

  @override
  String toString() {
    return 'UserInfo(visibleUserName: $visibleUserName, displayName: $displayName, gold: $gold, chip: $chip, safe: $safe, visibleUserId: $visibleUserId, phone: $phone, email: $email, vipPoint: $vipPoint, vip: $vip, avatar: $avatar, gender: $gender, birthDay: $birthDay, brand: $brand)';
  }
}

abstract mixin class _$UserInfoCopyWith<$Res> implements $UserInfoCopyWith<$Res> {
  factory _$UserInfoCopyWith(_UserInfo value, $Res Function(_UserInfo) _then) = __$UserInfoCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String? visibleUserName,
      String? displayName,
      int? gold,
      int? chip,
      int? safe,
      String? visibleUserId,
      String? phone,
      String? email,
      int? vipPoint,
      int? vip,
      String? avatar,
      int? gender,
      String? birthDay,
      String? brand});
}

class __$UserInfoCopyWithImpl<$Res> implements _$UserInfoCopyWith<$Res> {
  __$UserInfoCopyWithImpl(this._self, this._then);

  final _UserInfo _self;
  final $Res Function(_UserInfo) _then;

  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? visibleUserName = freezed,
    Object? displayName = freezed,
    Object? gold = freezed,
    Object? chip = freezed,
    Object? safe = freezed,
    Object? visibleUserId = freezed,
    Object? phone = freezed,
    Object? email = freezed,
    Object? vipPoint = freezed,
    Object? vip = freezed,
    Object? avatar = freezed,
    Object? gender = freezed,
    Object? birthDay = freezed,
    Object? brand = freezed,
  }) {
    return _then(_UserInfo(
      visibleUserName: freezed == visibleUserName
          ? _self.visibleUserName
          : visibleUserName // ignore: cast_nullable_to_non_nullable
              as String?,
      displayName: freezed == displayName
          ? _self.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String?,
      gold: freezed == gold
          ? _self.gold
          : gold // ignore: cast_nullable_to_non_nullable
              as int?,
      chip: freezed == chip
          ? _self.chip
          : chip // ignore: cast_nullable_to_non_nullable
              as int?,
      safe: freezed == safe
          ? _self.safe
          : safe // ignore: cast_nullable_to_non_nullable
              as int?,
      visibleUserId: freezed == visibleUserId
          ? _self.visibleUserId
          : visibleUserId // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _self.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      vipPoint: freezed == vipPoint
          ? _self.vipPoint
          : vipPoint // ignore: cast_nullable_to_non_nullable
              as int?,
      vip: freezed == vip
          ? _self.vip
          : vip // ignore: cast_nullable_to_non_nullable
              as int?,
      avatar: freezed == avatar
          ? _self.avatar
          : avatar // ignore: cast_nullable_to_non_nullable
              as String?,
      gender: freezed == gender
          ? _self.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as int?,
      birthDay: freezed == birthDay
          ? _self.birthDay
          : birthDay // ignore: cast_nullable_to_non_nullable
              as String?,
      brand: freezed == brand
          ? _self.brand
          : brand // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

mixin _$LoginRequest {
  String get username;
  String get password;

  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $LoginRequestCopyWith<LoginRequest> get copyWith =>
      _$LoginRequestCopyWithImpl<LoginRequest>(this as LoginRequest, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is LoginRequest &&
            (identical(other.username, username) || other.username == username) &&
            (identical(other.password, password) || other.password == password));
  }

  @override
  int get hashCode => Object.hash(runtimeType, username, password);

  @override
  String toString() {
    return 'LoginRequest(username: $username, password: $password)';
  }
}

abstract mixin class $LoginRequestCopyWith<$Res> {
  factory $LoginRequestCopyWith(LoginRequest value, $Res Function(LoginRequest) _then) = _$LoginRequestCopyWithImpl;
  @useResult
  $Res call({String username, String password});
}

class _$LoginRequestCopyWithImpl<$Res> implements $LoginRequestCopyWith<$Res> {
  _$LoginRequestCopyWithImpl(this._self, this._then);

  final LoginRequest _self;
  final $Res Function(LoginRequest) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? username = null,
    Object? password = null,
  }) {
    return _then(_self.copyWith(
      username: null == username
          ? _self.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _self.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

extension LoginRequestPatterns on LoginRequest {

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_LoginRequest value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _LoginRequest() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_LoginRequest value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LoginRequest():
        return $default(_that);
    }
  }

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_LoginRequest value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LoginRequest() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(String username, String password)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _LoginRequest() when $default != null:
        return $default(_that.username, _that.password);
      case _:
        return orElse();
    }
  }

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(String username, String password) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LoginRequest():
        return $default(_that.username, _that.password);
    }
  }

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(String username, String password)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LoginRequest() when $default != null:
        return $default(_that.username, _that.password);
      case _:
        return null;
    }
  }
}

class _LoginRequest implements LoginRequest {
  const _LoginRequest({required this.username, required this.password});

  @override
  final String username;
  @override
  final String password;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$LoginRequestCopyWith<_LoginRequest> get copyWith => __$LoginRequestCopyWithImpl<_LoginRequest>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _LoginRequest &&
            (identical(other.username, username) || other.username == username) &&
            (identical(other.password, password) || other.password == password));
  }

  @override
  int get hashCode => Object.hash(runtimeType, username, password);

  @override
  String toString() {
    return 'LoginRequest(username: $username, password: $password)';
  }
}

abstract mixin class _$LoginRequestCopyWith<$Res> implements $LoginRequestCopyWith<$Res> {
  factory _$LoginRequestCopyWith(_LoginRequest value, $Res Function(_LoginRequest) _then) = __$LoginRequestCopyWithImpl;
  @override
  @useResult
  $Res call({String username, String password});
}

class __$LoginRequestCopyWithImpl<$Res> implements _$LoginRequestCopyWith<$Res> {
  __$LoginRequestCopyWithImpl(this._self, this._then);

  final _LoginRequest _self;
  final $Res Function(_LoginRequest) _then;

  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? username = null,
    Object? password = null,
  }) {
    return _then(_LoginRequest(
      username: null == username
          ? _self.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _self.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

mixin _$RegisterRequest {
  String get username;
  String get password;
  String get displayName;
  String? get affId;
  String? get utmSource;
  String? get utmMedium;
  String? get utmCampaign;
  String? get utmContent;
  String? get utmTerm;

  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $RegisterRequestCopyWith<RegisterRequest> get copyWith =>
      _$RegisterRequestCopyWithImpl<RegisterRequest>(this as RegisterRequest, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is RegisterRequest &&
            (identical(other.username, username) || other.username == username) &&
            (identical(other.password, password) || other.password == password) &&
            (identical(other.displayName, displayName) || other.displayName == displayName) &&
            (identical(other.affId, affId) || other.affId == affId) &&
            (identical(other.utmSource, utmSource) || other.utmSource == utmSource) &&
            (identical(other.utmMedium, utmMedium) || other.utmMedium == utmMedium) &&
            (identical(other.utmCampaign, utmCampaign) || other.utmCampaign == utmCampaign) &&
            (identical(other.utmContent, utmContent) || other.utmContent == utmContent) &&
            (identical(other.utmTerm, utmTerm) || other.utmTerm == utmTerm));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, username, password, displayName, affId, utmSource, utmMedium, utmCampaign, utmContent, utmTerm);

  @override
  String toString() {
    return 'RegisterRequest(username: $username, password: $password, displayName: $displayName, affId: $affId, utmSource: $utmSource, utmMedium: $utmMedium, utmCampaign: $utmCampaign, utmContent: $utmContent, utmTerm: $utmTerm)';
  }
}

abstract mixin class $RegisterRequestCopyWith<$Res> {
  factory $RegisterRequestCopyWith(RegisterRequest value, $Res Function(RegisterRequest) _then) =
      _$RegisterRequestCopyWithImpl;
  @useResult
  $Res call(
      {String username,
      String password,
      String displayName,
      String? affId,
      String? utmSource,
      String? utmMedium,
      String? utmCampaign,
      String? utmContent,
      String? utmTerm});
}

class _$RegisterRequestCopyWithImpl<$Res> implements $RegisterRequestCopyWith<$Res> {
  _$RegisterRequestCopyWithImpl(this._self, this._then);

  final RegisterRequest _self;
  final $Res Function(RegisterRequest) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? username = null,
    Object? password = null,
    Object? displayName = null,
    Object? affId = freezed,
    Object? utmSource = freezed,
    Object? utmMedium = freezed,
    Object? utmCampaign = freezed,
    Object? utmContent = freezed,
    Object? utmTerm = freezed,
  }) {
    return _then(_self.copyWith(
      username: null == username
          ? _self.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _self.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: null == displayName
          ? _self.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      affId: freezed == affId
          ? _self.affId
          : affId // ignore: cast_nullable_to_non_nullable
              as String?,
      utmSource: freezed == utmSource
          ? _self.utmSource
          : utmSource // ignore: cast_nullable_to_non_nullable
              as String?,
      utmMedium: freezed == utmMedium
          ? _self.utmMedium
          : utmMedium // ignore: cast_nullable_to_non_nullable
              as String?,
      utmCampaign: freezed == utmCampaign
          ? _self.utmCampaign
          : utmCampaign // ignore: cast_nullable_to_non_nullable
              as String?,
      utmContent: freezed == utmContent
          ? _self.utmContent
          : utmContent // ignore: cast_nullable_to_non_nullable
              as String?,
      utmTerm: freezed == utmTerm
          ? _self.utmTerm
          : utmTerm // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

extension RegisterRequestPatterns on RegisterRequest {

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_RegisterRequest value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _RegisterRequest() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_RegisterRequest value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RegisterRequest():
        return $default(_that);
    }
  }

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_RegisterRequest value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RegisterRequest() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(String username, String password, String displayName, String? affId, String? utmSource,
            String? utmMedium, String? utmCampaign, String? utmContent, String? utmTerm)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _RegisterRequest() when $default != null:
        return $default(_that.username, _that.password, _that.displayName, _that.affId, _that.utmSource,
            _that.utmMedium, _that.utmCampaign, _that.utmContent, _that.utmTerm);
      case _:
        return orElse();
    }
  }

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(String username, String password, String displayName, String? affId, String? utmSource,
            String? utmMedium, String? utmCampaign, String? utmContent, String? utmTerm)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RegisterRequest():
        return $default(_that.username, _that.password, _that.displayName, _that.affId, _that.utmSource,
            _that.utmMedium, _that.utmCampaign, _that.utmContent, _that.utmTerm);
    }
  }

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(String username, String password, String displayName, String? affId, String? utmSource,
            String? utmMedium, String? utmCampaign, String? utmContent, String? utmTerm)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RegisterRequest() when $default != null:
        return $default(_that.username, _that.password, _that.displayName, _that.affId, _that.utmSource,
            _that.utmMedium, _that.utmCampaign, _that.utmContent, _that.utmTerm);
      case _:
        return null;
    }
  }
}

class _RegisterRequest implements RegisterRequest {
  const _RegisterRequest(
      {required this.username,
      required this.password,
      required this.displayName,
      this.affId,
      this.utmSource,
      this.utmMedium,
      this.utmCampaign,
      this.utmContent,
      this.utmTerm});

  @override
  final String username;
  @override
  final String password;
  @override
  final String displayName;
  @override
  final String? affId;
  @override
  final String? utmSource;
  @override
  final String? utmMedium;
  @override
  final String? utmCampaign;
  @override
  final String? utmContent;
  @override
  final String? utmTerm;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$RegisterRequestCopyWith<_RegisterRequest> get copyWith =>
      __$RegisterRequestCopyWithImpl<_RegisterRequest>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _RegisterRequest &&
            (identical(other.username, username) || other.username == username) &&
            (identical(other.password, password) || other.password == password) &&
            (identical(other.displayName, displayName) || other.displayName == displayName) &&
            (identical(other.affId, affId) || other.affId == affId) &&
            (identical(other.utmSource, utmSource) || other.utmSource == utmSource) &&
            (identical(other.utmMedium, utmMedium) || other.utmMedium == utmMedium) &&
            (identical(other.utmCampaign, utmCampaign) || other.utmCampaign == utmCampaign) &&
            (identical(other.utmContent, utmContent) || other.utmContent == utmContent) &&
            (identical(other.utmTerm, utmTerm) || other.utmTerm == utmTerm));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, username, password, displayName, affId, utmSource, utmMedium, utmCampaign, utmContent, utmTerm);

  @override
  String toString() {
    return 'RegisterRequest(username: $username, password: $password, displayName: $displayName, affId: $affId, utmSource: $utmSource, utmMedium: $utmMedium, utmCampaign: $utmCampaign, utmContent: $utmContent, utmTerm: $utmTerm)';
  }
}

abstract mixin class _$RegisterRequestCopyWith<$Res> implements $RegisterRequestCopyWith<$Res> {
  factory _$RegisterRequestCopyWith(_RegisterRequest value, $Res Function(_RegisterRequest) _then) =
      __$RegisterRequestCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String username,
      String password,
      String displayName,
      String? affId,
      String? utmSource,
      String? utmMedium,
      String? utmCampaign,
      String? utmContent,
      String? utmTerm});
}

class __$RegisterRequestCopyWithImpl<$Res> implements _$RegisterRequestCopyWith<$Res> {
  __$RegisterRequestCopyWithImpl(this._self, this._then);

  final _RegisterRequest _self;
  final $Res Function(_RegisterRequest) _then;

  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? username = null,
    Object? password = null,
    Object? displayName = null,
    Object? affId = freezed,
    Object? utmSource = freezed,
    Object? utmMedium = freezed,
    Object? utmCampaign = freezed,
    Object? utmContent = freezed,
    Object? utmTerm = freezed,
  }) {
    return _then(_RegisterRequest(
      username: null == username
          ? _self.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _self.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: null == displayName
          ? _self.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      affId: freezed == affId
          ? _self.affId
          : affId // ignore: cast_nullable_to_non_nullable
              as String?,
      utmSource: freezed == utmSource
          ? _self.utmSource
          : utmSource // ignore: cast_nullable_to_non_nullable
              as String?,
      utmMedium: freezed == utmMedium
          ? _self.utmMedium
          : utmMedium // ignore: cast_nullable_to_non_nullable
              as String?,
      utmCampaign: freezed == utmCampaign
          ? _self.utmCampaign
          : utmCampaign // ignore: cast_nullable_to_non_nullable
              as String?,
      utmContent: freezed == utmContent
          ? _self.utmContent
          : utmContent // ignore: cast_nullable_to_non_nullable
              as String?,
      utmTerm: freezed == utmTerm
          ? _self.utmTerm
          : utmTerm // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

mixin _$OtpRequest {
  String get sessionId;
  String get otp;
  String get username;
  String get password;

  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $OtpRequestCopyWith<OtpRequest> get copyWith => _$OtpRequestCopyWithImpl<OtpRequest>(this as OtpRequest, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is OtpRequest &&
            (identical(other.sessionId, sessionId) || other.sessionId == sessionId) &&
            (identical(other.otp, otp) || other.otp == otp) &&
            (identical(other.username, username) || other.username == username) &&
            (identical(other.password, password) || other.password == password));
  }

  @override
  int get hashCode => Object.hash(runtimeType, sessionId, otp, username, password);

  @override
  String toString() {
    return 'OtpRequest(sessionId: $sessionId, otp: $otp, username: $username, password: $password)';
  }
}

abstract mixin class $OtpRequestCopyWith<$Res> {
  factory $OtpRequestCopyWith(OtpRequest value, $Res Function(OtpRequest) _then) = _$OtpRequestCopyWithImpl;
  @useResult
  $Res call({String sessionId, String otp, String username, String password});
}

class _$OtpRequestCopyWithImpl<$Res> implements $OtpRequestCopyWith<$Res> {
  _$OtpRequestCopyWithImpl(this._self, this._then);

  final OtpRequest _self;
  final $Res Function(OtpRequest) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = null,
    Object? otp = null,
    Object? username = null,
    Object? password = null,
  }) {
    return _then(_self.copyWith(
      sessionId: null == sessionId
          ? _self.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String,
      otp: null == otp
          ? _self.otp
          : otp // ignore: cast_nullable_to_non_nullable
              as String,
      username: null == username
          ? _self.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _self.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

extension OtpRequestPatterns on OtpRequest {

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_OtpRequest value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _OtpRequest() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_OtpRequest value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OtpRequest():
        return $default(_that);
    }
  }

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_OtpRequest value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OtpRequest() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(String sessionId, String otp, String username, String password)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _OtpRequest() when $default != null:
        return $default(_that.sessionId, _that.otp, _that.username, _that.password);
      case _:
        return orElse();
    }
  }

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(String sessionId, String otp, String username, String password) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OtpRequest():
        return $default(_that.sessionId, _that.otp, _that.username, _that.password);
    }
  }

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(String sessionId, String otp, String username, String password)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OtpRequest() when $default != null:
        return $default(_that.sessionId, _that.otp, _that.username, _that.password);
      case _:
        return null;
    }
  }
}

class _OtpRequest implements OtpRequest {
  const _OtpRequest({required this.sessionId, required this.otp, required this.username, required this.password});

  @override
  final String sessionId;
  @override
  final String otp;
  @override
  final String username;
  @override
  final String password;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$OtpRequestCopyWith<_OtpRequest> get copyWith => __$OtpRequestCopyWithImpl<_OtpRequest>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _OtpRequest &&
            (identical(other.sessionId, sessionId) || other.sessionId == sessionId) &&
            (identical(other.otp, otp) || other.otp == otp) &&
            (identical(other.username, username) || other.username == username) &&
            (identical(other.password, password) || other.password == password));
  }

  @override
  int get hashCode => Object.hash(runtimeType, sessionId, otp, username, password);

  @override
  String toString() {
    return 'OtpRequest(sessionId: $sessionId, otp: $otp, username: $username, password: $password)';
  }
}

abstract mixin class _$OtpRequestCopyWith<$Res> implements $OtpRequestCopyWith<$Res> {
  factory _$OtpRequestCopyWith(_OtpRequest value, $Res Function(_OtpRequest) _then) = __$OtpRequestCopyWithImpl;
  @override
  @useResult
  $Res call({String sessionId, String otp, String username, String password});
}

class __$OtpRequestCopyWithImpl<$Res> implements _$OtpRequestCopyWith<$Res> {
  __$OtpRequestCopyWithImpl(this._self, this._then);

  final _OtpRequest _self;
  final $Res Function(_OtpRequest) _then;

  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? sessionId = null,
    Object? otp = null,
    Object? username = null,
    Object? password = null,
  }) {
    return _then(_OtpRequest(
      sessionId: null == sessionId
          ? _self.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String,
      otp: null == otp
          ? _self.otp
          : otp // ignore: cast_nullable_to_non_nullable
              as String,
      username: null == username
          ? _self.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _self.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
