part of 'models.dart';

@freezed
sealed class GameUrlData with _$GameUrlData {
  const factory GameUrlData({required String url}) = _GameUrlData;

  factory GameUrlData.fromJson(Map<String, dynamic> json) => _$GameUrlDataFromJson(json);
}
