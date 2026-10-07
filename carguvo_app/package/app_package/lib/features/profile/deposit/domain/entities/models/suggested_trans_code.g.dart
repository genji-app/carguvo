
part of 'suggested_trans_code.dart';

_SuggestedTransCode _$SuggestedTransCodeFromJson(Map<String, dynamic> json) =>
    _SuggestedTransCode(
      text: json['text'] as String,
      type: (json['type'] as num).toInt(),
    );

Map<String, dynamic> _$SuggestedTransCodeToJson(_SuggestedTransCode instance) =>
    <String, dynamic>{'text': instance.text, 'type': instance.type};
