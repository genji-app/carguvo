import 'package:freezed_annotation/freezed_annotation.dart';

part 'suggested_trans_code.freezed.dart';
part 'suggested_trans_code.g.dart';

@freezed
sealed class SuggestedTransCode with _$SuggestedTransCode {
  const factory SuggestedTransCode({required String text, required int type}) =
      _SuggestedTransCode;

  factory SuggestedTransCode.fromJson(Map<String, dynamic> json) =>
      _$SuggestedTransCodeFromJson(json);
}
