// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'route_envelope.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RouteEnvelope {

 String get messageId; String get fromPubkey; String get toPubkey; int get kind; int get createdAt; String get payload; String get sig; int get ttl; List<String> get via;
/// Create a copy of RouteEnvelope
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RouteEnvelopeCopyWith<RouteEnvelope> get copyWith => _$RouteEnvelopeCopyWithImpl<RouteEnvelope>(this as RouteEnvelope, _$identity);

  /// Serializes this RouteEnvelope to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RouteEnvelope&&(identical(other.messageId, messageId) || other.messageId == messageId)&&(identical(other.fromPubkey, fromPubkey) || other.fromPubkey == fromPubkey)&&(identical(other.toPubkey, toPubkey) || other.toPubkey == toPubkey)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.payload, payload) || other.payload == payload)&&(identical(other.sig, sig) || other.sig == sig)&&(identical(other.ttl, ttl) || other.ttl == ttl)&&const DeepCollectionEquality().equals(other.via, via));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,messageId,fromPubkey,toPubkey,kind,createdAt,payload,sig,ttl,const DeepCollectionEquality().hash(via));

@override
String toString() {
  return 'RouteEnvelope(messageId: $messageId, fromPubkey: $fromPubkey, toPubkey: $toPubkey, kind: $kind, createdAt: $createdAt, payload: $payload, sig: $sig, ttl: $ttl, via: $via)';
}


}

/// @nodoc
abstract mixin class $RouteEnvelopeCopyWith<$Res>  {
  factory $RouteEnvelopeCopyWith(RouteEnvelope value, $Res Function(RouteEnvelope) _then) = _$RouteEnvelopeCopyWithImpl;
@useResult
$Res call({
 String messageId, String fromPubkey, String toPubkey, int kind, int createdAt, String payload, String sig, int ttl, List<String> via
});




}
/// @nodoc
class _$RouteEnvelopeCopyWithImpl<$Res>
    implements $RouteEnvelopeCopyWith<$Res> {
  _$RouteEnvelopeCopyWithImpl(this._self, this._then);

  final RouteEnvelope _self;
  final $Res Function(RouteEnvelope) _then;

/// Create a copy of RouteEnvelope
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? messageId = null,Object? fromPubkey = null,Object? toPubkey = null,Object? kind = null,Object? createdAt = null,Object? payload = null,Object? sig = null,Object? ttl = null,Object? via = null,}) {
  return _then(_self.copyWith(
messageId: null == messageId ? _self.messageId : messageId // ignore: cast_nullable_to_non_nullable
as String,fromPubkey: null == fromPubkey ? _self.fromPubkey : fromPubkey // ignore: cast_nullable_to_non_nullable
as String,toPubkey: null == toPubkey ? _self.toPubkey : toPubkey // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as int,payload: null == payload ? _self.payload : payload // ignore: cast_nullable_to_non_nullable
as String,sig: null == sig ? _self.sig : sig // ignore: cast_nullable_to_non_nullable
as String,ttl: null == ttl ? _self.ttl : ttl // ignore: cast_nullable_to_non_nullable
as int,via: null == via ? _self.via : via // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [RouteEnvelope].
extension RouteEnvelopePatterns on RouteEnvelope {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RouteEnvelope value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RouteEnvelope() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RouteEnvelope value)  $default,){
final _that = this;
switch (_that) {
case _RouteEnvelope():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RouteEnvelope value)?  $default,){
final _that = this;
switch (_that) {
case _RouteEnvelope() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String messageId,  String fromPubkey,  String toPubkey,  int kind,  int createdAt,  String payload,  String sig,  int ttl,  List<String> via)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RouteEnvelope() when $default != null:
return $default(_that.messageId,_that.fromPubkey,_that.toPubkey,_that.kind,_that.createdAt,_that.payload,_that.sig,_that.ttl,_that.via);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String messageId,  String fromPubkey,  String toPubkey,  int kind,  int createdAt,  String payload,  String sig,  int ttl,  List<String> via)  $default,) {final _that = this;
switch (_that) {
case _RouteEnvelope():
return $default(_that.messageId,_that.fromPubkey,_that.toPubkey,_that.kind,_that.createdAt,_that.payload,_that.sig,_that.ttl,_that.via);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String messageId,  String fromPubkey,  String toPubkey,  int kind,  int createdAt,  String payload,  String sig,  int ttl,  List<String> via)?  $default,) {final _that = this;
switch (_that) {
case _RouteEnvelope() when $default != null:
return $default(_that.messageId,_that.fromPubkey,_that.toPubkey,_that.kind,_that.createdAt,_that.payload,_that.sig,_that.ttl,_that.via);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RouteEnvelope implements RouteEnvelope {
  const _RouteEnvelope({required this.messageId, required this.fromPubkey, required this.toPubkey, required this.kind, required this.createdAt, required this.payload, required this.sig, this.ttl = 7, final  List<String> via = const []}): _via = via;
  factory _RouteEnvelope.fromJson(Map<String, dynamic> json) => _$RouteEnvelopeFromJson(json);

@override final  String messageId;
@override final  String fromPubkey;
@override final  String toPubkey;
@override final  int kind;
@override final  int createdAt;
@override final  String payload;
@override final  String sig;
@override@JsonKey() final  int ttl;
 final  List<String> _via;
@override@JsonKey() List<String> get via {
  if (_via is EqualUnmodifiableListView) return _via;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_via);
}


/// Create a copy of RouteEnvelope
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RouteEnvelopeCopyWith<_RouteEnvelope> get copyWith => __$RouteEnvelopeCopyWithImpl<_RouteEnvelope>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RouteEnvelopeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RouteEnvelope&&(identical(other.messageId, messageId) || other.messageId == messageId)&&(identical(other.fromPubkey, fromPubkey) || other.fromPubkey == fromPubkey)&&(identical(other.toPubkey, toPubkey) || other.toPubkey == toPubkey)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.payload, payload) || other.payload == payload)&&(identical(other.sig, sig) || other.sig == sig)&&(identical(other.ttl, ttl) || other.ttl == ttl)&&const DeepCollectionEquality().equals(other._via, _via));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,messageId,fromPubkey,toPubkey,kind,createdAt,payload,sig,ttl,const DeepCollectionEquality().hash(_via));

@override
String toString() {
  return 'RouteEnvelope(messageId: $messageId, fromPubkey: $fromPubkey, toPubkey: $toPubkey, kind: $kind, createdAt: $createdAt, payload: $payload, sig: $sig, ttl: $ttl, via: $via)';
}


}

/// @nodoc
abstract mixin class _$RouteEnvelopeCopyWith<$Res> implements $RouteEnvelopeCopyWith<$Res> {
  factory _$RouteEnvelopeCopyWith(_RouteEnvelope value, $Res Function(_RouteEnvelope) _then) = __$RouteEnvelopeCopyWithImpl;
@override @useResult
$Res call({
 String messageId, String fromPubkey, String toPubkey, int kind, int createdAt, String payload, String sig, int ttl, List<String> via
});




}
/// @nodoc
class __$RouteEnvelopeCopyWithImpl<$Res>
    implements _$RouteEnvelopeCopyWith<$Res> {
  __$RouteEnvelopeCopyWithImpl(this._self, this._then);

  final _RouteEnvelope _self;
  final $Res Function(_RouteEnvelope) _then;

/// Create a copy of RouteEnvelope
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? messageId = null,Object? fromPubkey = null,Object? toPubkey = null,Object? kind = null,Object? createdAt = null,Object? payload = null,Object? sig = null,Object? ttl = null,Object? via = null,}) {
  return _then(_RouteEnvelope(
messageId: null == messageId ? _self.messageId : messageId // ignore: cast_nullable_to_non_nullable
as String,fromPubkey: null == fromPubkey ? _self.fromPubkey : fromPubkey // ignore: cast_nullable_to_non_nullable
as String,toPubkey: null == toPubkey ? _self.toPubkey : toPubkey // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as int,payload: null == payload ? _self.payload : payload // ignore: cast_nullable_to_non_nullable
as String,sig: null == sig ? _self.sig : sig // ignore: cast_nullable_to_non_nullable
as String,ttl: null == ttl ? _self.ttl : ttl // ignore: cast_nullable_to_non_nullable
as int,via: null == via ? _self._via : via // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
