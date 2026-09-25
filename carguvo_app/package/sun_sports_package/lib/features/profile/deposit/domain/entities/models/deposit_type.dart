import 'package:freezed_annotation/freezed_annotation.dart';

part 'deposit_type.freezed.dart';
part 'deposit_type.g.dart';

@freezed
sealed class DepositType with _$DepositType {
  const factory DepositType({required String description, required int id}) =
      _DepositType;

  factory DepositType.fromJson(Map<String, dynamic> json) =>
      _$DepositTypeFromJson(json);
}
