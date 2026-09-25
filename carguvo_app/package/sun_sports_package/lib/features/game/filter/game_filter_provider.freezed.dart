// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_filter_provider.dart';

// dart format off
T _$identity<T>(T value) => value;
mixin _$GameFilterState {

 String get searchQuery; GameCategorySelection get categorySelection; List<LobbyGame> get results; GameFilterStatus get status;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameFilterStateCopyWith<GameFilterState> get copyWith => _$GameFilterStateCopyWithImpl<GameFilterState>(this as GameFilterState, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameFilterState&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.categorySelection, categorySelection) || other.categorySelection == categorySelection)&&const DeepCollectionEquality().equals(other.results, results)&&(identical(other.status, status) || other.status == status));
}

@override
int get hashCode => Object.hash(runtimeType,searchQuery,categorySelection,const DeepCollectionEquality().hash(results),status);

@override
String toString() {
  return 'GameFilterState(searchQuery: $searchQuery, categorySelection: $categorySelection, results: $results, status: $status)';
}

}

abstract mixin class $GameFilterStateCopyWith<$Res>  {
  factory $GameFilterStateCopyWith(GameFilterState value, $Res Function(GameFilterState) _then) = _$GameFilterStateCopyWithImpl;
@useResult
$Res call({
 String searchQuery, GameCategorySelection categorySelection, List<LobbyGame> results, GameFilterStatus status
});

}
class _$GameFilterStateCopyWithImpl<$Res>
    implements $GameFilterStateCopyWith<$Res> {
  _$GameFilterStateCopyWithImpl(this._self, this._then);

  final GameFilterState _self;
  final $Res Function(GameFilterState) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? searchQuery = null,Object? categorySelection = null,Object? results = null,Object? status = null,}) {
  return _then(_self.copyWith(
searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,categorySelection: null == categorySelection ? _self.categorySelection : categorySelection // ignore: cast_nullable_to_non_nullable
as GameCategorySelection,results: null == results ? _self.results : results // ignore: cast_nullable_to_non_nullable
as List<LobbyGame>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as GameFilterStatus,
  ));
}

}

extension GameFilterStatePatterns on GameFilterState {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GameFilterState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GameFilterState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GameFilterState value)  $default,){
final _that = this;
switch (_that) {
case _GameFilterState():
return $default(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GameFilterState value)?  $default,){
final _that = this;
switch (_that) {
case _GameFilterState() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String searchQuery,  GameCategorySelection categorySelection,  List<LobbyGame> results,  GameFilterStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GameFilterState() when $default != null:
return $default(_that.searchQuery,_that.categorySelection,_that.results,_that.status);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String searchQuery,  GameCategorySelection categorySelection,  List<LobbyGame> results,  GameFilterStatus status)  $default,) {final _that = this;
switch (_that) {
case _GameFilterState():
return $default(_that.searchQuery,_that.categorySelection,_that.results,_that.status);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String searchQuery,  GameCategorySelection categorySelection,  List<LobbyGame> results,  GameFilterStatus status)?  $default,) {final _that = this;
switch (_that) {
case _GameFilterState() when $default != null:
return $default(_that.searchQuery,_that.categorySelection,_that.results,_that.status);case _:
  return null;

}
}

}

class _GameFilterState implements GameFilterState {
  const _GameFilterState({this.searchQuery = '', this.categorySelection = const GameCategorySelection(), final  List<LobbyGame> results = const [], this.status = GameFilterStatus.initial}): _results = results;
  
@override@JsonKey() final  String searchQuery;
@override@JsonKey() final  GameCategorySelection categorySelection;
 final  List<LobbyGame> _results;
@override@JsonKey() List<LobbyGame> get results {
  if (_results is EqualUnmodifiableListView) return _results;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_results);
}

@override@JsonKey() final  GameFilterStatus status;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GameFilterStateCopyWith<_GameFilterState> get copyWith => __$GameFilterStateCopyWithImpl<_GameFilterState>(this, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GameFilterState&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.categorySelection, categorySelection) || other.categorySelection == categorySelection)&&const DeepCollectionEquality().equals(other._results, _results)&&(identical(other.status, status) || other.status == status));
}

@override
int get hashCode => Object.hash(runtimeType,searchQuery,categorySelection,const DeepCollectionEquality().hash(_results),status);

@override
String toString() {
  return 'GameFilterState(searchQuery: $searchQuery, categorySelection: $categorySelection, results: $results, status: $status)';
}

}

abstract mixin class _$GameFilterStateCopyWith<$Res> implements $GameFilterStateCopyWith<$Res> {
  factory _$GameFilterStateCopyWith(_GameFilterState value, $Res Function(_GameFilterState) _then) = __$GameFilterStateCopyWithImpl;
@override @useResult
$Res call({
 String searchQuery, GameCategorySelection categorySelection, List<LobbyGame> results, GameFilterStatus status
});

}
class __$GameFilterStateCopyWithImpl<$Res>
    implements _$GameFilterStateCopyWith<$Res> {
  __$GameFilterStateCopyWithImpl(this._self, this._then);

  final _GameFilterState _self;
  final $Res Function(_GameFilterState) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? searchQuery = null,Object? categorySelection = null,Object? results = null,Object? status = null,}) {
  return _then(_GameFilterState(
searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,categorySelection: null == categorySelection ? _self.categorySelection : categorySelection // ignore: cast_nullable_to_non_nullable
as GameCategorySelection,results: null == results ? _self._results : results // ignore: cast_nullable_to_non_nullable
as List<LobbyGame>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as GameFilterStatus,
  ));
}

}

// dart format on
