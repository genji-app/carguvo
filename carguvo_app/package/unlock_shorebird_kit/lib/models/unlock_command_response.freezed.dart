// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'unlock_command_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UnlockCommandResponse _$UnlockCommandResponseFromJson(
  Map<String, dynamic> json,
) {
  return _UnlockCommandResponse.fromJson(json);
}

/// @nodoc
mixin _$UnlockCommandResponse {
  UnlockCommandData get data => throw _privateConstructorUsedError;
  int get status => throw _privateConstructorUsedError;

  /// Serializes this UnlockCommandResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UnlockCommandResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UnlockCommandResponseCopyWith<UnlockCommandResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UnlockCommandResponseCopyWith<$Res> {
  factory $UnlockCommandResponseCopyWith(
    UnlockCommandResponse value,
    $Res Function(UnlockCommandResponse) then,
  ) = _$UnlockCommandResponseCopyWithImpl<$Res, UnlockCommandResponse>;
  @useResult
  $Res call({UnlockCommandData data, int status});

  $UnlockCommandDataCopyWith<$Res> get data;
}

/// @nodoc
class _$UnlockCommandResponseCopyWithImpl<
  $Res,
  $Val extends UnlockCommandResponse
>
    implements $UnlockCommandResponseCopyWith<$Res> {
  _$UnlockCommandResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UnlockCommandResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? data = null, Object? status = null}) {
    return _then(
      _value.copyWith(
            data: null == data
                ? _value.data
                : data // ignore: cast_nullable_to_non_nullable
                      as UnlockCommandData,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }

  /// Create a copy of UnlockCommandResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UnlockCommandDataCopyWith<$Res> get data {
    return $UnlockCommandDataCopyWith<$Res>(_value.data, (value) {
      return _then(_value.copyWith(data: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$UnlockCommandResponseImplCopyWith<$Res>
    implements $UnlockCommandResponseCopyWith<$Res> {
  factory _$$UnlockCommandResponseImplCopyWith(
    _$UnlockCommandResponseImpl value,
    $Res Function(_$UnlockCommandResponseImpl) then,
  ) = __$$UnlockCommandResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({UnlockCommandData data, int status});

  @override
  $UnlockCommandDataCopyWith<$Res> get data;
}

/// @nodoc
class __$$UnlockCommandResponseImplCopyWithImpl<$Res>
    extends
        _$UnlockCommandResponseCopyWithImpl<$Res, _$UnlockCommandResponseImpl>
    implements _$$UnlockCommandResponseImplCopyWith<$Res> {
  __$$UnlockCommandResponseImplCopyWithImpl(
    _$UnlockCommandResponseImpl _value,
    $Res Function(_$UnlockCommandResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UnlockCommandResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? data = null, Object? status = null}) {
    return _then(
      _$UnlockCommandResponseImpl(
        data: null == data
            ? _value.data
            : data // ignore: cast_nullable_to_non_nullable
                  as UnlockCommandData,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UnlockCommandResponseImpl implements _UnlockCommandResponse {
  const _$UnlockCommandResponseImpl({required this.data, required this.status});

  factory _$UnlockCommandResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$UnlockCommandResponseImplFromJson(json);

  @override
  final UnlockCommandData data;
  @override
  final int status;

  @override
  String toString() {
    return 'UnlockCommandResponse(data: $data, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UnlockCommandResponseImpl &&
            (identical(other.data, data) || other.data == data) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, data, status);

  /// Create a copy of UnlockCommandResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UnlockCommandResponseImplCopyWith<_$UnlockCommandResponseImpl>
  get copyWith =>
      __$$UnlockCommandResponseImplCopyWithImpl<_$UnlockCommandResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$UnlockCommandResponseImplToJson(this);
  }
}

abstract class _UnlockCommandResponse implements UnlockCommandResponse {
  const factory _UnlockCommandResponse({
    required final UnlockCommandData data,
    required final int status,
  }) = _$UnlockCommandResponseImpl;

  factory _UnlockCommandResponse.fromJson(Map<String, dynamic> json) =
      _$UnlockCommandResponseImpl.fromJson;

  @override
  UnlockCommandData get data;
  @override
  int get status;

  /// Create a copy of UnlockCommandResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UnlockCommandResponseImplCopyWith<_$UnlockCommandResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}

UnlockCommandData _$UnlockCommandDataFromJson(Map<String, dynamic> json) {
  return _UnlockCommandData.fromJson(json);
}

/// @nodoc
mixin _$UnlockCommandData {
  String get ip => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;

  /// Serializes this UnlockCommandData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UnlockCommandData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UnlockCommandDataCopyWith<UnlockCommandData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UnlockCommandDataCopyWith<$Res> {
  factory $UnlockCommandDataCopyWith(
    UnlockCommandData value,
    $Res Function(UnlockCommandData) then,
  ) = _$UnlockCommandDataCopyWithImpl<$Res, UnlockCommandData>;
  @useResult
  $Res call({String ip, String message});
}

/// @nodoc
class _$UnlockCommandDataCopyWithImpl<$Res, $Val extends UnlockCommandData>
    implements $UnlockCommandDataCopyWith<$Res> {
  _$UnlockCommandDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UnlockCommandData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? ip = null, Object? message = null}) {
    return _then(
      _value.copyWith(
            ip: null == ip
                ? _value.ip
                : ip // ignore: cast_nullable_to_non_nullable
                      as String,
            message: null == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UnlockCommandDataImplCopyWith<$Res>
    implements $UnlockCommandDataCopyWith<$Res> {
  factory _$$UnlockCommandDataImplCopyWith(
    _$UnlockCommandDataImpl value,
    $Res Function(_$UnlockCommandDataImpl) then,
  ) = __$$UnlockCommandDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String ip, String message});
}

/// @nodoc
class __$$UnlockCommandDataImplCopyWithImpl<$Res>
    extends _$UnlockCommandDataCopyWithImpl<$Res, _$UnlockCommandDataImpl>
    implements _$$UnlockCommandDataImplCopyWith<$Res> {
  __$$UnlockCommandDataImplCopyWithImpl(
    _$UnlockCommandDataImpl _value,
    $Res Function(_$UnlockCommandDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UnlockCommandData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? ip = null, Object? message = null}) {
    return _then(
      _$UnlockCommandDataImpl(
        ip: null == ip
            ? _value.ip
            : ip // ignore: cast_nullable_to_non_nullable
                  as String,
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UnlockCommandDataImpl implements _UnlockCommandData {
  const _$UnlockCommandDataImpl({required this.ip, required this.message});

  factory _$UnlockCommandDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$UnlockCommandDataImplFromJson(json);

  @override
  final String ip;
  @override
  final String message;

  @override
  String toString() {
    return 'UnlockCommandData(ip: $ip, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UnlockCommandDataImpl &&
            (identical(other.ip, ip) || other.ip == ip) &&
            (identical(other.message, message) || other.message == message));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, ip, message);

  /// Create a copy of UnlockCommandData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UnlockCommandDataImplCopyWith<_$UnlockCommandDataImpl> get copyWith =>
      __$$UnlockCommandDataImplCopyWithImpl<_$UnlockCommandDataImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$UnlockCommandDataImplToJson(this);
  }
}

abstract class _UnlockCommandData implements UnlockCommandData {
  const factory _UnlockCommandData({
    required final String ip,
    required final String message,
  }) = _$UnlockCommandDataImpl;

  factory _UnlockCommandData.fromJson(Map<String, dynamic> json) =
      _$UnlockCommandDataImpl.fromJson;

  @override
  String get ip;
  @override
  String get message;

  /// Create a copy of UnlockCommandData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UnlockCommandDataImplCopyWith<_$UnlockCommandDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
