import 'package:freezed_annotation/freezed_annotation.dart';

part 'unlock_command_response.freezed.dart';
part 'unlock_command_response.g.dart';

@freezed
class UnlockCommandResponse with _$UnlockCommandResponse {
  const factory UnlockCommandResponse({
    required UnlockCommandData data,
    required int status,
  }) = _UnlockCommandResponse;

  factory UnlockCommandResponse.fromJson(Map<String, dynamic> json) =>
      _$UnlockCommandResponseFromJson(json);
}

@freezed
class UnlockCommandData with _$UnlockCommandData {
  const factory UnlockCommandData({
    required String ip,
    required String message,
  }) = _UnlockCommandData;

  factory UnlockCommandData.fromJson(Map<String, dynamic> json) =>
      _$UnlockCommandDataFromJson(json);
}
