// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event_model.dart';

// dart format off
T _$identity<T>(T value) => value;

mixin _$EventModel {

 int get id; String get name;@JsonKey(name: 'leagueId') int get leagueId;@JsonKey(name: 'leagueName') String? get leagueName;@JsonKey(name: 'startDate') String get startDate;@JsonKey(name: 'isLive') bool get isLive;@JsonKey(name: 'homeTeam') TeamModel? get homeTeam;@JsonKey(name: 'awayTeam') TeamModel? get awayTeam;@JsonKey(name: 'score') ScoreModel? get score;@JsonKey(name: 'minute') int? get minute;@JsonKey(name: 'markets') List<MarketModel> get markets;@JsonKey(name: 'featured') bool get featured;@JsonKey(name: 'popularityScore') double? get popularityScore;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventModelCopyWith<EventModel> get copyWith => _$EventModelCopyWithImpl<EventModel>(this as EventModel, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.leagueId, leagueId) || other.leagueId == leagueId)&&(identical(other.leagueName, leagueName) || other.leagueName == leagueName)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.isLive, isLive) || other.isLive == isLive)&&(identical(other.homeTeam, homeTeam) || other.homeTeam == homeTeam)&&(identical(other.awayTeam, awayTeam) || other.awayTeam == awayTeam)&&(identical(other.score, score) || other.score == score)&&(identical(other.minute, minute) || other.minute == minute)&&const DeepCollectionEquality().equals(other.markets, markets)&&(identical(other.featured, featured) || other.featured == featured)&&(identical(other.popularityScore, popularityScore) || other.popularityScore == popularityScore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,leagueId,leagueName,startDate,isLive,homeTeam,awayTeam,score,minute,const DeepCollectionEquality().hash(markets),featured,popularityScore);

@override
String toString() {
  return 'EventModel(id: $id, name: $name, leagueId: $leagueId, leagueName: $leagueName, startDate: $startDate, isLive: $isLive, homeTeam: $homeTeam, awayTeam: $awayTeam, score: $score, minute: $minute, markets: $markets, featured: $featured, popularityScore: $popularityScore)';
}

}

abstract mixin class $EventModelCopyWith<$Res>  {
  factory $EventModelCopyWith(EventModel value, $Res Function(EventModel) _then) = _$EventModelCopyWithImpl;
@useResult
$Res call({
 int id, String name,@JsonKey(name: 'leagueId') int leagueId,@JsonKey(name: 'leagueName') String? leagueName,@JsonKey(name: 'startDate') String startDate,@JsonKey(name: 'isLive') bool isLive,@JsonKey(name: 'homeTeam') TeamModel? homeTeam,@JsonKey(name: 'awayTeam') TeamModel? awayTeam,@JsonKey(name: 'score') ScoreModel? score,@JsonKey(name: 'minute') int? minute,@JsonKey(name: 'markets') List<MarketModel> markets,@JsonKey(name: 'featured') bool featured,@JsonKey(name: 'popularityScore') double? popularityScore
});

$TeamModelCopyWith<$Res>? get homeTeam;$TeamModelCopyWith<$Res>? get awayTeam;$ScoreModelCopyWith<$Res>? get score;

}
class _$EventModelCopyWithImpl<$Res>
    implements $EventModelCopyWith<$Res> {
  _$EventModelCopyWithImpl(this._self, this._then);

  final EventModel _self;
  final $Res Function(EventModel) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? leagueId = null,Object? leagueName = freezed,Object? startDate = null,Object? isLive = null,Object? homeTeam = freezed,Object? awayTeam = freezed,Object? score = freezed,Object? minute = freezed,Object? markets = null,Object? featured = null,Object? popularityScore = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,leagueId: null == leagueId ? _self.leagueId : leagueId // ignore: cast_nullable_to_non_nullable
as int,leagueName: freezed == leagueName ? _self.leagueName : leagueName // ignore: cast_nullable_to_non_nullable
as String?,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String,isLive: null == isLive ? _self.isLive : isLive // ignore: cast_nullable_to_non_nullable
as bool,homeTeam: freezed == homeTeam ? _self.homeTeam : homeTeam // ignore: cast_nullable_to_non_nullable
as TeamModel?,awayTeam: freezed == awayTeam ? _self.awayTeam : awayTeam // ignore: cast_nullable_to_non_nullable
as TeamModel?,score: freezed == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as ScoreModel?,minute: freezed == minute ? _self.minute : minute // ignore: cast_nullable_to_non_nullable
as int?,markets: null == markets ? _self.markets : markets // ignore: cast_nullable_to_non_nullable
as List<MarketModel>,featured: null == featured ? _self.featured : featured // ignore: cast_nullable_to_non_nullable
as bool,popularityScore: freezed == popularityScore ? _self.popularityScore : popularityScore // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}
@override
@pragma('vm:prefer-inline')
$TeamModelCopyWith<$Res>? get homeTeam {
    if (_self.homeTeam == null) {
    return null;
  }

  return $TeamModelCopyWith<$Res>(_self.homeTeam!, (value) {
    return _then(_self.copyWith(homeTeam: value));
  });
}
@override
@pragma('vm:prefer-inline')
$TeamModelCopyWith<$Res>? get awayTeam {
    if (_self.awayTeam == null) {
    return null;
  }

  return $TeamModelCopyWith<$Res>(_self.awayTeam!, (value) {
    return _then(_self.copyWith(awayTeam: value));
  });
}
@override
@pragma('vm:prefer-inline')
$ScoreModelCopyWith<$Res>? get score {
    if (_self.score == null) {
    return null;
  }

  return $ScoreModelCopyWith<$Res>(_self.score!, (value) {
    return _then(_self.copyWith(score: value));
  });
}
}

extension EventModelPatterns on EventModel {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EventModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EventModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EventModel value)  $default,){
final _that = this;
switch (_that) {
case _EventModel():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EventModel value)?  $default,){
final _that = this;
switch (_that) {
case _EventModel() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name, @JsonKey(name: 'leagueId')  int leagueId, @JsonKey(name: 'leagueName')  String? leagueName, @JsonKey(name: 'startDate')  String startDate, @JsonKey(name: 'isLive')  bool isLive, @JsonKey(name: 'homeTeam')  TeamModel? homeTeam, @JsonKey(name: 'awayTeam')  TeamModel? awayTeam, @JsonKey(name: 'score')  ScoreModel? score, @JsonKey(name: 'minute')  int? minute, @JsonKey(name: 'markets')  List<MarketModel> markets, @JsonKey(name: 'featured')  bool featured, @JsonKey(name: 'popularityScore')  double? popularityScore)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EventModel() when $default != null:
return $default(_that.id,_that.name,_that.leagueId,_that.leagueName,_that.startDate,_that.isLive,_that.homeTeam,_that.awayTeam,_that.score,_that.minute,_that.markets,_that.featured,_that.popularityScore);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name, @JsonKey(name: 'leagueId')  int leagueId, @JsonKey(name: 'leagueName')  String? leagueName, @JsonKey(name: 'startDate')  String startDate, @JsonKey(name: 'isLive')  bool isLive, @JsonKey(name: 'homeTeam')  TeamModel? homeTeam, @JsonKey(name: 'awayTeam')  TeamModel? awayTeam, @JsonKey(name: 'score')  ScoreModel? score, @JsonKey(name: 'minute')  int? minute, @JsonKey(name: 'markets')  List<MarketModel> markets, @JsonKey(name: 'featured')  bool featured, @JsonKey(name: 'popularityScore')  double? popularityScore)  $default,) {final _that = this;
switch (_that) {
case _EventModel():
return $default(_that.id,_that.name,_that.leagueId,_that.leagueName,_that.startDate,_that.isLive,_that.homeTeam,_that.awayTeam,_that.score,_that.minute,_that.markets,_that.featured,_that.popularityScore);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name, @JsonKey(name: 'leagueId')  int leagueId, @JsonKey(name: 'leagueName')  String? leagueName, @JsonKey(name: 'startDate')  String startDate, @JsonKey(name: 'isLive')  bool isLive, @JsonKey(name: 'homeTeam')  TeamModel? homeTeam, @JsonKey(name: 'awayTeam')  TeamModel? awayTeam, @JsonKey(name: 'score')  ScoreModel? score, @JsonKey(name: 'minute')  int? minute, @JsonKey(name: 'markets')  List<MarketModel> markets, @JsonKey(name: 'featured')  bool featured, @JsonKey(name: 'popularityScore')  double? popularityScore)?  $default,) {final _that = this;
switch (_that) {
case _EventModel() when $default != null:
return $default(_that.id,_that.name,_that.leagueId,_that.leagueName,_that.startDate,_that.isLive,_that.homeTeam,_that.awayTeam,_that.score,_that.minute,_that.markets,_that.featured,_that.popularityScore);case _:
  return null;

}
}

}

@JsonSerializable()

class _EventModel implements EventModel {
  const _EventModel({required this.id, required this.name, @JsonKey(name: 'leagueId') required this.leagueId, @JsonKey(name: 'leagueName') this.leagueName, @JsonKey(name: 'startDate') required this.startDate, @JsonKey(name: 'isLive') this.isLive = false, @JsonKey(name: 'homeTeam') this.homeTeam, @JsonKey(name: 'awayTeam') this.awayTeam, @JsonKey(name: 'score') this.score, @JsonKey(name: 'minute') this.minute, @JsonKey(name: 'markets') final  List<MarketModel> markets = const [], @JsonKey(name: 'featured') this.featured = false, @JsonKey(name: 'popularityScore') this.popularityScore}): _markets = markets;
  factory _EventModel.fromJson(Map<String, dynamic> json) => _$EventModelFromJson(json);

@override final  int id;
@override final  String name;
@override@JsonKey(name: 'leagueId') final  int leagueId;
@override@JsonKey(name: 'leagueName') final  String? leagueName;
@override@JsonKey(name: 'startDate') final  String startDate;
@override@JsonKey(name: 'isLive') final  bool isLive;
@override@JsonKey(name: 'homeTeam') final  TeamModel? homeTeam;
@override@JsonKey(name: 'awayTeam') final  TeamModel? awayTeam;
@override@JsonKey(name: 'score') final  ScoreModel? score;
@override@JsonKey(name: 'minute') final  int? minute;
 final  List<MarketModel> _markets;
@override@JsonKey(name: 'markets') List<MarketModel> get markets {
  if (_markets is EqualUnmodifiableListView) return _markets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_markets);
}

@override@JsonKey(name: 'featured') final  bool featured;
@override@JsonKey(name: 'popularityScore') final  double? popularityScore;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventModelCopyWith<_EventModel> get copyWith => __$EventModelCopyWithImpl<_EventModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EventModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EventModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.leagueId, leagueId) || other.leagueId == leagueId)&&(identical(other.leagueName, leagueName) || other.leagueName == leagueName)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.isLive, isLive) || other.isLive == isLive)&&(identical(other.homeTeam, homeTeam) || other.homeTeam == homeTeam)&&(identical(other.awayTeam, awayTeam) || other.awayTeam == awayTeam)&&(identical(other.score, score) || other.score == score)&&(identical(other.minute, minute) || other.minute == minute)&&const DeepCollectionEquality().equals(other._markets, _markets)&&(identical(other.featured, featured) || other.featured == featured)&&(identical(other.popularityScore, popularityScore) || other.popularityScore == popularityScore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,leagueId,leagueName,startDate,isLive,homeTeam,awayTeam,score,minute,const DeepCollectionEquality().hash(_markets),featured,popularityScore);

@override
String toString() {
  return 'EventModel(id: $id, name: $name, leagueId: $leagueId, leagueName: $leagueName, startDate: $startDate, isLive: $isLive, homeTeam: $homeTeam, awayTeam: $awayTeam, score: $score, minute: $minute, markets: $markets, featured: $featured, popularityScore: $popularityScore)';
}

}

abstract mixin class _$EventModelCopyWith<$Res> implements $EventModelCopyWith<$Res> {
  factory _$EventModelCopyWith(_EventModel value, $Res Function(_EventModel) _then) = __$EventModelCopyWithImpl;
@override @useResult
$Res call({
 int id, String name,@JsonKey(name: 'leagueId') int leagueId,@JsonKey(name: 'leagueName') String? leagueName,@JsonKey(name: 'startDate') String startDate,@JsonKey(name: 'isLive') bool isLive,@JsonKey(name: 'homeTeam') TeamModel? homeTeam,@JsonKey(name: 'awayTeam') TeamModel? awayTeam,@JsonKey(name: 'score') ScoreModel? score,@JsonKey(name: 'minute') int? minute,@JsonKey(name: 'markets') List<MarketModel> markets,@JsonKey(name: 'featured') bool featured,@JsonKey(name: 'popularityScore') double? popularityScore
});

@override $TeamModelCopyWith<$Res>? get homeTeam;@override $TeamModelCopyWith<$Res>? get awayTeam;@override $ScoreModelCopyWith<$Res>? get score;

}
class __$EventModelCopyWithImpl<$Res>
    implements _$EventModelCopyWith<$Res> {
  __$EventModelCopyWithImpl(this._self, this._then);

  final _EventModel _self;
  final $Res Function(_EventModel) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? leagueId = null,Object? leagueName = freezed,Object? startDate = null,Object? isLive = null,Object? homeTeam = freezed,Object? awayTeam = freezed,Object? score = freezed,Object? minute = freezed,Object? markets = null,Object? featured = null,Object? popularityScore = freezed,}) {
  return _then(_EventModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,leagueId: null == leagueId ? _self.leagueId : leagueId // ignore: cast_nullable_to_non_nullable
as int,leagueName: freezed == leagueName ? _self.leagueName : leagueName // ignore: cast_nullable_to_non_nullable
as String?,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String,isLive: null == isLive ? _self.isLive : isLive // ignore: cast_nullable_to_non_nullable
as bool,homeTeam: freezed == homeTeam ? _self.homeTeam : homeTeam // ignore: cast_nullable_to_non_nullable
as TeamModel?,awayTeam: freezed == awayTeam ? _self.awayTeam : awayTeam // ignore: cast_nullable_to_non_nullable
as TeamModel?,score: freezed == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as ScoreModel?,minute: freezed == minute ? _self.minute : minute // ignore: cast_nullable_to_non_nullable
as int?,markets: null == markets ? _self._markets : markets // ignore: cast_nullable_to_non_nullable
as List<MarketModel>,featured: null == featured ? _self.featured : featured // ignore: cast_nullable_to_non_nullable
as bool,popularityScore: freezed == popularityScore ? _self.popularityScore : popularityScore // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

@override
@pragma('vm:prefer-inline')
$TeamModelCopyWith<$Res>? get homeTeam {
    if (_self.homeTeam == null) {
    return null;
  }

  return $TeamModelCopyWith<$Res>(_self.homeTeam!, (value) {
    return _then(_self.copyWith(homeTeam: value));
  });
}
@override
@pragma('vm:prefer-inline')
$TeamModelCopyWith<$Res>? get awayTeam {
    if (_self.awayTeam == null) {
    return null;
  }

  return $TeamModelCopyWith<$Res>(_self.awayTeam!, (value) {
    return _then(_self.copyWith(awayTeam: value));
  });
}
@override
@pragma('vm:prefer-inline')
$ScoreModelCopyWith<$Res>? get score {
    if (_self.score == null) {
    return null;
  }

  return $ScoreModelCopyWith<$Res>(_self.score!, (value) {
    return _then(_self.copyWith(score: value));
  });
}
}

mixin _$TeamModel {

 int get id; String get name; String? get logo; String? get shortName;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TeamModelCopyWith<TeamModel> get copyWith => _$TeamModelCopyWithImpl<TeamModel>(this as TeamModel, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TeamModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.logo, logo) || other.logo == logo)&&(identical(other.shortName, shortName) || other.shortName == shortName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,logo,shortName);

@override
String toString() {
  return 'TeamModel(id: $id, name: $name, logo: $logo, shortName: $shortName)';
}

}

abstract mixin class $TeamModelCopyWith<$Res>  {
  factory $TeamModelCopyWith(TeamModel value, $Res Function(TeamModel) _then) = _$TeamModelCopyWithImpl;
@useResult
$Res call({
 int id, String name, String? logo, String? shortName
});

}
class _$TeamModelCopyWithImpl<$Res>
    implements $TeamModelCopyWith<$Res> {
  _$TeamModelCopyWithImpl(this._self, this._then);

  final TeamModel _self;
  final $Res Function(TeamModel) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? logo = freezed,Object? shortName = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,logo: freezed == logo ? _self.logo : logo // ignore: cast_nullable_to_non_nullable
as String?,shortName: freezed == shortName ? _self.shortName : shortName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}

extension TeamModelPatterns on TeamModel {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TeamModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TeamModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TeamModel value)  $default,){
final _that = this;
switch (_that) {
case _TeamModel():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TeamModel value)?  $default,){
final _that = this;
switch (_that) {
case _TeamModel() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String? logo,  String? shortName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TeamModel() when $default != null:
return $default(_that.id,_that.name,_that.logo,_that.shortName);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String? logo,  String? shortName)  $default,) {final _that = this;
switch (_that) {
case _TeamModel():
return $default(_that.id,_that.name,_that.logo,_that.shortName);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String? logo,  String? shortName)?  $default,) {final _that = this;
switch (_that) {
case _TeamModel() when $default != null:
return $default(_that.id,_that.name,_that.logo,_that.shortName);case _:
  return null;

}
}

}

@JsonSerializable()

class _TeamModel implements TeamModel {
  const _TeamModel({required this.id, required this.name, this.logo, this.shortName});
  factory _TeamModel.fromJson(Map<String, dynamic> json) => _$TeamModelFromJson(json);

@override final  int id;
@override final  String name;
@override final  String? logo;
@override final  String? shortName;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TeamModelCopyWith<_TeamModel> get copyWith => __$TeamModelCopyWithImpl<_TeamModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TeamModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TeamModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.logo, logo) || other.logo == logo)&&(identical(other.shortName, shortName) || other.shortName == shortName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,logo,shortName);

@override
String toString() {
  return 'TeamModel(id: $id, name: $name, logo: $logo, shortName: $shortName)';
}

}

abstract mixin class _$TeamModelCopyWith<$Res> implements $TeamModelCopyWith<$Res> {
  factory _$TeamModelCopyWith(_TeamModel value, $Res Function(_TeamModel) _then) = __$TeamModelCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String? logo, String? shortName
});

}
class __$TeamModelCopyWithImpl<$Res>
    implements _$TeamModelCopyWith<$Res> {
  __$TeamModelCopyWithImpl(this._self, this._then);

  final _TeamModel _self;
  final $Res Function(_TeamModel) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? logo = freezed,Object? shortName = freezed,}) {
  return _then(_TeamModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,logo: freezed == logo ? _self.logo : logo // ignore: cast_nullable_to_non_nullable
as String?,shortName: freezed == shortName ? _self.shortName : shortName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}

mixin _$ScoreModel {

 int get home; int get away;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScoreModelCopyWith<ScoreModel> get copyWith => _$ScoreModelCopyWithImpl<ScoreModel>(this as ScoreModel, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScoreModel&&(identical(other.home, home) || other.home == home)&&(identical(other.away, away) || other.away == away));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,home,away);

@override
String toString() {
  return 'ScoreModel(home: $home, away: $away)';
}

}

abstract mixin class $ScoreModelCopyWith<$Res>  {
  factory $ScoreModelCopyWith(ScoreModel value, $Res Function(ScoreModel) _then) = _$ScoreModelCopyWithImpl;
@useResult
$Res call({
 int home, int away
});

}
class _$ScoreModelCopyWithImpl<$Res>
    implements $ScoreModelCopyWith<$Res> {
  _$ScoreModelCopyWithImpl(this._self, this._then);

  final ScoreModel _self;
  final $Res Function(ScoreModel) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? home = null,Object? away = null,}) {
  return _then(_self.copyWith(
home: null == home ? _self.home : home // ignore: cast_nullable_to_non_nullable
as int,away: null == away ? _self.away : away // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}

extension ScoreModelPatterns on ScoreModel {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ScoreModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ScoreModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ScoreModel value)  $default,){
final _that = this;
switch (_that) {
case _ScoreModel():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ScoreModel value)?  $default,){
final _that = this;
switch (_that) {
case _ScoreModel() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int home,  int away)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ScoreModel() when $default != null:
return $default(_that.home,_that.away);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int home,  int away)  $default,) {final _that = this;
switch (_that) {
case _ScoreModel():
return $default(_that.home,_that.away);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int home,  int away)?  $default,) {final _that = this;
switch (_that) {
case _ScoreModel() when $default != null:
return $default(_that.home,_that.away);case _:
  return null;

}
}

}

@JsonSerializable()

class _ScoreModel implements ScoreModel {
  const _ScoreModel({this.home = 0, this.away = 0});
  factory _ScoreModel.fromJson(Map<String, dynamic> json) => _$ScoreModelFromJson(json);

@override@JsonKey() final  int home;
@override@JsonKey() final  int away;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScoreModelCopyWith<_ScoreModel> get copyWith => __$ScoreModelCopyWithImpl<_ScoreModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ScoreModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ScoreModel&&(identical(other.home, home) || other.home == home)&&(identical(other.away, away) || other.away == away));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,home,away);

@override
String toString() {
  return 'ScoreModel(home: $home, away: $away)';
}

}

abstract mixin class _$ScoreModelCopyWith<$Res> implements $ScoreModelCopyWith<$Res> {
  factory _$ScoreModelCopyWith(_ScoreModel value, $Res Function(_ScoreModel) _then) = __$ScoreModelCopyWithImpl;
@override @useResult
$Res call({
 int home, int away
});

}
class __$ScoreModelCopyWithImpl<$Res>
    implements _$ScoreModelCopyWith<$Res> {
  __$ScoreModelCopyWithImpl(this._self, this._then);

  final _ScoreModel _self;
  final $Res Function(_ScoreModel) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? home = null,Object? away = null,}) {
  return _then(_ScoreModel(
home: null == home ? _self.home : home // ignore: cast_nullable_to_non_nullable
as int,away: null == away ? _self.away : away // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}

mixin _$EventsResponse {

 List<EventModel> get events; int get total;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventsResponseCopyWith<EventsResponse> get copyWith => _$EventsResponseCopyWithImpl<EventsResponse>(this as EventsResponse, _$identity);

  Map<String, dynamic> toJson();

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventsResponse&&const DeepCollectionEquality().equals(other.events, events)&&(identical(other.total, total) || other.total == total));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(events),total);

@override
String toString() {
  return 'EventsResponse(events: $events, total: $total)';
}

}

abstract mixin class $EventsResponseCopyWith<$Res>  {
  factory $EventsResponseCopyWith(EventsResponse value, $Res Function(EventsResponse) _then) = _$EventsResponseCopyWithImpl;
@useResult
$Res call({
 List<EventModel> events, int total
});

}
class _$EventsResponseCopyWithImpl<$Res>
    implements $EventsResponseCopyWith<$Res> {
  _$EventsResponseCopyWithImpl(this._self, this._then);

  final EventsResponse _self;
  final $Res Function(EventsResponse) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? events = null,Object? total = null,}) {
  return _then(_self.copyWith(
events: null == events ? _self.events : events // ignore: cast_nullable_to_non_nullable
as List<EventModel>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}

extension EventsResponsePatterns on EventsResponse {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EventsResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EventsResponse() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EventsResponse value)  $default,){
final _that = this;
switch (_that) {
case _EventsResponse():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EventsResponse value)?  $default,){
final _that = this;
switch (_that) {
case _EventsResponse() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<EventModel> events,  int total)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EventsResponse() when $default != null:
return $default(_that.events,_that.total);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<EventModel> events,  int total)  $default,) {final _that = this;
switch (_that) {
case _EventsResponse():
return $default(_that.events,_that.total);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<EventModel> events,  int total)?  $default,) {final _that = this;
switch (_that) {
case _EventsResponse() when $default != null:
return $default(_that.events,_that.total);case _:
  return null;

}
}

}

@JsonSerializable()

class _EventsResponse implements EventsResponse {
  const _EventsResponse({final  List<EventModel> events = const [], this.total = 0}): _events = events;
  factory _EventsResponse.fromJson(Map<String, dynamic> json) => _$EventsResponseFromJson(json);

 final  List<EventModel> _events;
@override@JsonKey() List<EventModel> get events {
  if (_events is EqualUnmodifiableListView) return _events;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_events);
}

@override@JsonKey() final  int total;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventsResponseCopyWith<_EventsResponse> get copyWith => __$EventsResponseCopyWithImpl<_EventsResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EventsResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EventsResponse&&const DeepCollectionEquality().equals(other._events, _events)&&(identical(other.total, total) || other.total == total));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_events),total);

@override
String toString() {
  return 'EventsResponse(events: $events, total: $total)';
}

}

abstract mixin class _$EventsResponseCopyWith<$Res> implements $EventsResponseCopyWith<$Res> {
  factory _$EventsResponseCopyWith(_EventsResponse value, $Res Function(_EventsResponse) _then) = __$EventsResponseCopyWithImpl;
@override @useResult
$Res call({
 List<EventModel> events, int total
});

}
class __$EventsResponseCopyWithImpl<$Res>
    implements _$EventsResponseCopyWith<$Res> {
  __$EventsResponseCopyWithImpl(this._self, this._then);

  final _EventsResponse _self;
  final $Res Function(_EventsResponse) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? events = null,Object? total = null,}) {
  return _then(_EventsResponse(
events: null == events ? _self._events : events // ignore: cast_nullable_to_non_nullable
as List<EventModel>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}

// dart format on
