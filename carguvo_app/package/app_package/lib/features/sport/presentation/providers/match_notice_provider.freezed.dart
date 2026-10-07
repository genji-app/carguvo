// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'match_notice_provider.dart';

// dart format off
T _$identity<T>(T value) => value;
mixin _$MatchNoticeEvent {

 int get eventId; bool get home; int get seq;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MatchNoticeEventCopyWith<MatchNoticeEvent> get copyWith => _$MatchNoticeEventCopyWithImpl<MatchNoticeEvent>(this as MatchNoticeEvent, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MatchNoticeEvent&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.home, home) || other.home == home)&&(identical(other.seq, seq) || other.seq == seq));
}

@override
int get hashCode => Object.hash(runtimeType,eventId,home,seq);

@override
String toString() {
  return 'MatchNoticeEvent(eventId: $eventId, home: $home, seq: $seq)';
}

}

abstract mixin class $MatchNoticeEventCopyWith<$Res>  {
  factory $MatchNoticeEventCopyWith(MatchNoticeEvent value, $Res Function(MatchNoticeEvent) _then) = _$MatchNoticeEventCopyWithImpl;
@useResult
$Res call({
 int eventId, bool home, int seq
});

}
class _$MatchNoticeEventCopyWithImpl<$Res>
    implements $MatchNoticeEventCopyWith<$Res> {
  _$MatchNoticeEventCopyWithImpl(this._self, this._then);

  final MatchNoticeEvent _self;
  final $Res Function(MatchNoticeEvent) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? eventId = null,Object? home = null,Object? seq = null,}) {
  return _then(_self.copyWith(
eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as int,home: null == home ? _self.home : home // ignore: cast_nullable_to_non_nullable
as bool,seq: null == seq ? _self.seq : seq // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}

extension MatchNoticeEventPatterns on MatchNoticeEvent {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Goal value)?  goal,TResult Function( _RedCard value)?  redCard,TResult Function( _YellowCard value)?  yellowCard,TResult Function( _Corner value)?  corner,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Goal() when goal != null:
return goal(_that);case _RedCard() when redCard != null:
return redCard(_that);case _YellowCard() when yellowCard != null:
return yellowCard(_that);case _Corner() when corner != null:
return corner(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Goal value)  goal,required TResult Function( _RedCard value)  redCard,required TResult Function( _YellowCard value)  yellowCard,required TResult Function( _Corner value)  corner,}){
final _that = this;
switch (_that) {
case _Goal():
return goal(_that);case _RedCard():
return redCard(_that);case _YellowCard():
return yellowCard(_that);case _Corner():
return corner(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Goal value)?  goal,TResult? Function( _RedCard value)?  redCard,TResult? Function( _YellowCard value)?  yellowCard,TResult? Function( _Corner value)?  corner,}){
final _that = this;
switch (_that) {
case _Goal() when goal != null:
return goal(_that);case _RedCard() when redCard != null:
return redCard(_that);case _YellowCard() when yellowCard != null:
return yellowCard(_that);case _Corner() when corner != null:
return corner(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( int eventId,  bool home,  int seq)?  goal,TResult Function( int eventId,  bool home,  int seq)?  redCard,TResult Function( int eventId,  bool home,  int seq)?  yellowCard,TResult Function( int eventId,  bool home,  int seq)?  corner,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Goal() when goal != null:
return goal(_that.eventId,_that.home,_that.seq);case _RedCard() when redCard != null:
return redCard(_that.eventId,_that.home,_that.seq);case _YellowCard() when yellowCard != null:
return yellowCard(_that.eventId,_that.home,_that.seq);case _Corner() when corner != null:
return corner(_that.eventId,_that.home,_that.seq);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( int eventId,  bool home,  int seq)  goal,required TResult Function( int eventId,  bool home,  int seq)  redCard,required TResult Function( int eventId,  bool home,  int seq)  yellowCard,required TResult Function( int eventId,  bool home,  int seq)  corner,}) {final _that = this;
switch (_that) {
case _Goal():
return goal(_that.eventId,_that.home,_that.seq);case _RedCard():
return redCard(_that.eventId,_that.home,_that.seq);case _YellowCard():
return yellowCard(_that.eventId,_that.home,_that.seq);case _Corner():
return corner(_that.eventId,_that.home,_that.seq);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( int eventId,  bool home,  int seq)?  goal,TResult? Function( int eventId,  bool home,  int seq)?  redCard,TResult? Function( int eventId,  bool home,  int seq)?  yellowCard,TResult? Function( int eventId,  bool home,  int seq)?  corner,}) {final _that = this;
switch (_that) {
case _Goal() when goal != null:
return goal(_that.eventId,_that.home,_that.seq);case _RedCard() when redCard != null:
return redCard(_that.eventId,_that.home,_that.seq);case _YellowCard() when yellowCard != null:
return yellowCard(_that.eventId,_that.home,_that.seq);case _Corner() when corner != null:
return corner(_that.eventId,_that.home,_that.seq);case _:
  return null;

}
}

}

class _Goal implements MatchNoticeEvent {
  const _Goal({required this.eventId, required this.home, required this.seq});
  
@override final  int eventId;
@override final  bool home;
@override final  int seq;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GoalCopyWith<_Goal> get copyWith => __$GoalCopyWithImpl<_Goal>(this, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Goal&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.home, home) || other.home == home)&&(identical(other.seq, seq) || other.seq == seq));
}

@override
int get hashCode => Object.hash(runtimeType,eventId,home,seq);

@override
String toString() {
  return 'MatchNoticeEvent.goal(eventId: $eventId, home: $home, seq: $seq)';
}

}

abstract mixin class _$GoalCopyWith<$Res> implements $MatchNoticeEventCopyWith<$Res> {
  factory _$GoalCopyWith(_Goal value, $Res Function(_Goal) _then) = __$GoalCopyWithImpl;
@override @useResult
$Res call({
 int eventId, bool home, int seq
});

}
class __$GoalCopyWithImpl<$Res>
    implements _$GoalCopyWith<$Res> {
  __$GoalCopyWithImpl(this._self, this._then);

  final _Goal _self;
  final $Res Function(_Goal) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? eventId = null,Object? home = null,Object? seq = null,}) {
  return _then(_Goal(
eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as int,home: null == home ? _self.home : home // ignore: cast_nullable_to_non_nullable
as bool,seq: null == seq ? _self.seq : seq // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}

class _RedCard implements MatchNoticeEvent {
  const _RedCard({required this.eventId, required this.home, required this.seq});
  
@override final  int eventId;
@override final  bool home;
@override final  int seq;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RedCardCopyWith<_RedCard> get copyWith => __$RedCardCopyWithImpl<_RedCard>(this, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RedCard&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.home, home) || other.home == home)&&(identical(other.seq, seq) || other.seq == seq));
}

@override
int get hashCode => Object.hash(runtimeType,eventId,home,seq);

@override
String toString() {
  return 'MatchNoticeEvent.redCard(eventId: $eventId, home: $home, seq: $seq)';
}

}

abstract mixin class _$RedCardCopyWith<$Res> implements $MatchNoticeEventCopyWith<$Res> {
  factory _$RedCardCopyWith(_RedCard value, $Res Function(_RedCard) _then) = __$RedCardCopyWithImpl;
@override @useResult
$Res call({
 int eventId, bool home, int seq
});

}
class __$RedCardCopyWithImpl<$Res>
    implements _$RedCardCopyWith<$Res> {
  __$RedCardCopyWithImpl(this._self, this._then);

  final _RedCard _self;
  final $Res Function(_RedCard) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? eventId = null,Object? home = null,Object? seq = null,}) {
  return _then(_RedCard(
eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as int,home: null == home ? _self.home : home // ignore: cast_nullable_to_non_nullable
as bool,seq: null == seq ? _self.seq : seq // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}

class _YellowCard implements MatchNoticeEvent {
  const _YellowCard({required this.eventId, required this.home, required this.seq});
  
@override final  int eventId;
@override final  bool home;
@override final  int seq;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$YellowCardCopyWith<_YellowCard> get copyWith => __$YellowCardCopyWithImpl<_YellowCard>(this, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _YellowCard&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.home, home) || other.home == home)&&(identical(other.seq, seq) || other.seq == seq));
}

@override
int get hashCode => Object.hash(runtimeType,eventId,home,seq);

@override
String toString() {
  return 'MatchNoticeEvent.yellowCard(eventId: $eventId, home: $home, seq: $seq)';
}

}

abstract mixin class _$YellowCardCopyWith<$Res> implements $MatchNoticeEventCopyWith<$Res> {
  factory _$YellowCardCopyWith(_YellowCard value, $Res Function(_YellowCard) _then) = __$YellowCardCopyWithImpl;
@override @useResult
$Res call({
 int eventId, bool home, int seq
});

}
class __$YellowCardCopyWithImpl<$Res>
    implements _$YellowCardCopyWith<$Res> {
  __$YellowCardCopyWithImpl(this._self, this._then);

  final _YellowCard _self;
  final $Res Function(_YellowCard) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? eventId = null,Object? home = null,Object? seq = null,}) {
  return _then(_YellowCard(
eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as int,home: null == home ? _self.home : home // ignore: cast_nullable_to_non_nullable
as bool,seq: null == seq ? _self.seq : seq // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}

class _Corner implements MatchNoticeEvent {
  const _Corner({required this.eventId, required this.home, required this.seq});
  
@override final  int eventId;
@override final  bool home;
@override final  int seq;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CornerCopyWith<_Corner> get copyWith => __$CornerCopyWithImpl<_Corner>(this, _$identity);

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Corner&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.home, home) || other.home == home)&&(identical(other.seq, seq) || other.seq == seq));
}

@override
int get hashCode => Object.hash(runtimeType,eventId,home,seq);

@override
String toString() {
  return 'MatchNoticeEvent.corner(eventId: $eventId, home: $home, seq: $seq)';
}

}

abstract mixin class _$CornerCopyWith<$Res> implements $MatchNoticeEventCopyWith<$Res> {
  factory _$CornerCopyWith(_Corner value, $Res Function(_Corner) _then) = __$CornerCopyWithImpl;
@override @useResult
$Res call({
 int eventId, bool home, int seq
});

}
class __$CornerCopyWithImpl<$Res>
    implements _$CornerCopyWith<$Res> {
  __$CornerCopyWithImpl(this._self, this._then);

  final _Corner _self;
  final $Res Function(_Corner) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? eventId = null,Object? home = null,Object? seq = null,}) {
  return _then(_Corner(
eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as int,home: null == home ? _self.home : home // ignore: cast_nullable_to_non_nullable
as bool,seq: null == seq ? _self.seq : seq // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}

// dart format on
