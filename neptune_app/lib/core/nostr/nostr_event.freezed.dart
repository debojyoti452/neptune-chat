// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'nostr_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NostrEvent {

 String get id; String get pubkey;@JsonKey(name: 'created_at') int get createdAt; int get kind; List<List<String>> get tags; String get content; String get sig;
/// Create a copy of NostrEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NostrEventCopyWith<NostrEvent> get copyWith => _$NostrEventCopyWithImpl<NostrEvent>(this as NostrEvent, _$identity);

  /// Serializes this NostrEvent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NostrEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.pubkey, pubkey) || other.pubkey == pubkey)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.kind, kind) || other.kind == kind)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.content, content) || other.content == content)&&(identical(other.sig, sig) || other.sig == sig));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,pubkey,createdAt,kind,const DeepCollectionEquality().hash(tags),content,sig);

@override
String toString() {
  return 'NostrEvent(id: $id, pubkey: $pubkey, createdAt: $createdAt, kind: $kind, tags: $tags, content: $content, sig: $sig)';
}


}

/// @nodoc
abstract mixin class $NostrEventCopyWith<$Res>  {
  factory $NostrEventCopyWith(NostrEvent value, $Res Function(NostrEvent) _then) = _$NostrEventCopyWithImpl;
@useResult
$Res call({
 String id, String pubkey,@JsonKey(name: 'created_at') int createdAt, int kind, List<List<String>> tags, String content, String sig
});




}
/// @nodoc
class _$NostrEventCopyWithImpl<$Res>
    implements $NostrEventCopyWith<$Res> {
  _$NostrEventCopyWithImpl(this._self, this._then);

  final NostrEvent _self;
  final $Res Function(NostrEvent) _then;

/// Create a copy of NostrEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? pubkey = null,Object? createdAt = null,Object? kind = null,Object? tags = null,Object? content = null,Object? sig = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,pubkey: null == pubkey ? _self.pubkey : pubkey // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as int,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as int,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<List<String>>,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,sig: null == sig ? _self.sig : sig // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [NostrEvent].
extension NostrEventPatterns on NostrEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NostrEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NostrEvent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NostrEvent value)  $default,){
final _that = this;
switch (_that) {
case _NostrEvent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NostrEvent value)?  $default,){
final _that = this;
switch (_that) {
case _NostrEvent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String pubkey, @JsonKey(name: 'created_at')  int createdAt,  int kind,  List<List<String>> tags,  String content,  String sig)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NostrEvent() when $default != null:
return $default(_that.id,_that.pubkey,_that.createdAt,_that.kind,_that.tags,_that.content,_that.sig);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String pubkey, @JsonKey(name: 'created_at')  int createdAt,  int kind,  List<List<String>> tags,  String content,  String sig)  $default,) {final _that = this;
switch (_that) {
case _NostrEvent():
return $default(_that.id,_that.pubkey,_that.createdAt,_that.kind,_that.tags,_that.content,_that.sig);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String pubkey, @JsonKey(name: 'created_at')  int createdAt,  int kind,  List<List<String>> tags,  String content,  String sig)?  $default,) {final _that = this;
switch (_that) {
case _NostrEvent() when $default != null:
return $default(_that.id,_that.pubkey,_that.createdAt,_that.kind,_that.tags,_that.content,_that.sig);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NostrEvent implements NostrEvent {
  const _NostrEvent({required this.id, required this.pubkey, @JsonKey(name: 'created_at') required this.createdAt, required this.kind, required final  List<List<String>> tags, required this.content, required this.sig}): _tags = tags;
  factory _NostrEvent.fromJson(Map<String, dynamic> json) => _$NostrEventFromJson(json);

@override final  String id;
@override final  String pubkey;
@override@JsonKey(name: 'created_at') final  int createdAt;
@override final  int kind;
 final  List<List<String>> _tags;
@override List<List<String>> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

@override final  String content;
@override final  String sig;

/// Create a copy of NostrEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NostrEventCopyWith<_NostrEvent> get copyWith => __$NostrEventCopyWithImpl<_NostrEvent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NostrEventToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NostrEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.pubkey, pubkey) || other.pubkey == pubkey)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.kind, kind) || other.kind == kind)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.content, content) || other.content == content)&&(identical(other.sig, sig) || other.sig == sig));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,pubkey,createdAt,kind,const DeepCollectionEquality().hash(_tags),content,sig);

@override
String toString() {
  return 'NostrEvent(id: $id, pubkey: $pubkey, createdAt: $createdAt, kind: $kind, tags: $tags, content: $content, sig: $sig)';
}


}

/// @nodoc
abstract mixin class _$NostrEventCopyWith<$Res> implements $NostrEventCopyWith<$Res> {
  factory _$NostrEventCopyWith(_NostrEvent value, $Res Function(_NostrEvent) _then) = __$NostrEventCopyWithImpl;
@override @useResult
$Res call({
 String id, String pubkey,@JsonKey(name: 'created_at') int createdAt, int kind, List<List<String>> tags, String content, String sig
});




}
/// @nodoc
class __$NostrEventCopyWithImpl<$Res>
    implements _$NostrEventCopyWith<$Res> {
  __$NostrEventCopyWithImpl(this._self, this._then);

  final _NostrEvent _self;
  final $Res Function(_NostrEvent) _then;

/// Create a copy of NostrEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? pubkey = null,Object? createdAt = null,Object? kind = null,Object? tags = null,Object? content = null,Object? sig = null,}) {
  return _then(_NostrEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,pubkey: null == pubkey ? _self.pubkey : pubkey // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as int,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as int,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<List<String>>,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,sig: null == sig ? _self.sig : sig // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
