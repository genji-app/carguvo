import 'package:freezed_annotation/freezed_annotation.dart';

part 'deposit_type.freezed.dart';
part 'deposit_type.g.dart';

@freezed
sealed class DepositType with _$DepositType {
  const factory DepositType({
    @JsonKey(name: 'id') required int id,
    @JsonKey(name: 'description') required String description,
  }) = _DepositType;

  factory DepositType.fromJson(Map<String, Object?> json) =>
      _$DepositTypeFromJson(json);
}
