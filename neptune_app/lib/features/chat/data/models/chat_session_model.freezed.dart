// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_session_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChatSessionModel {

 String get id; String get peerPubkey; String get conversationKeyHex; String get transport; int get startedAt;
/// Create a copy of ChatSessionModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatSessionModelCopyWith<ChatSessionModel> get copyWith => _$ChatSessionModelCopyWithImpl<ChatSessionModel>(this as ChatSessionModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatSessionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.peerPubkey, peerPubkey) || other.peerPubkey == peerPubkey)&&(identical(other.conversationKeyHex, conversationKeyHex) || other.conversationKeyHex == conversationKeyHex)&&(identical(other.transport, transport) || other.transport == transport)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,peerPubkey,conversationKeyHex,transport,startedAt);

@override
String toString() {
  return 'ChatSessionModel(id: $id, peerPubkey: $peerPubkey, conversationKeyHex: $conversationKeyHex, transport: $transport, startedAt: $startedAt)';
}


}

/// @nodoc
abstract mixin class $ChatSessionModelCopyWith<$Res>  {
  factory $ChatSessionModelCopyWith(ChatSessionModel value, $Res Function(ChatSessionModel) _then) = _$ChatSessionModelCopyWithImpl;
@useResult
$Res call({
 String id, String peerPubkey, String conversationKeyHex, String transport, int startedAt
});




}
/// @nodoc
class _$ChatSessionModelCopyWithImpl<$Res>
    implements $ChatSessionModelCopyWith<$Res> {
  _$ChatSessionModelCopyWithImpl(this._self, this._then);

  final ChatSessionModel _self;
  final $Res Function(ChatSessionModel) _then;

/// Create a copy of ChatSessionModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? peerPubkey = null,Object? conversationKeyHex = null,Object? transport = null,Object? startedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,peerPubkey: null == peerPubkey ? _self.peerPubkey : peerPubkey // ignore: cast_nullable_to_non_nullable
as String,conversationKeyHex: null == conversationKeyHex ? _self.conversationKeyHex : conversationKeyHex // ignore: cast_nullable_to_non_nullable
as String,transport: null == transport ? _self.transport : transport // ignore: cast_nullable_to_non_nullable
as String,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatSessionModel].
extension ChatSessionModelPatterns on ChatSessionModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatSessionModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatSessionModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatSessionModel value)  $default,){
final _that = this;
switch (_that) {
case _ChatSessionModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatSessionModel value)?  $default,){
final _that = this;
switch (_that) {
case _ChatSessionModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String peerPubkey,  String conversationKeyHex,  String transport,  int startedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatSessionModel() when $default != null:
return $default(_that.id,_that.peerPubkey,_that.conversationKeyHex,_that.transport,_that.startedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String peerPubkey,  String conversationKeyHex,  String transport,  int startedAt)  $default,) {final _that = this;
switch (_that) {
case _ChatSessionModel():
return $default(_that.id,_that.peerPubkey,_that.conversationKeyHex,_that.transport,_that.startedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String peerPubkey,  String conversationKeyHex,  String transport,  int startedAt)?  $default,) {final _that = this;
switch (_that) {
case _ChatSessionModel() when $default != null:
return $default(_that.id,_that.peerPubkey,_that.conversationKeyHex,_that.transport,_that.startedAt);case _:
  return null;

}
}

}

/// @nodoc


class _ChatSessionModel implements ChatSessionModel {
  const _ChatSessionModel({required this.id, required this.peerPubkey, required this.conversationKeyHex, required this.transport, required this.startedAt});
  

@override final  String id;
@override final  String peerPubkey;
@override final  String conversationKeyHex;
@override final  String transport;
@override final  int startedAt;

/// Create a copy of ChatSessionModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatSessionModelCopyWith<_ChatSessionModel> get copyWith => __$ChatSessionModelCopyWithImpl<_ChatSessionModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatSessionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.peerPubkey, peerPubkey) || other.peerPubkey == peerPubkey)&&(identical(other.conversationKeyHex, conversationKeyHex) || other.conversationKeyHex == conversationKeyHex)&&(identical(other.transport, transport) || other.transport == transport)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,peerPubkey,conversationKeyHex,transport,startedAt);

@override
String toString() {
  return 'ChatSessionModel(id: $id, peerPubkey: $peerPubkey, conversationKeyHex: $conversationKeyHex, transport: $transport, startedAt: $startedAt)';
}


}

/// @nodoc
abstract mixin class _$ChatSessionModelCopyWith<$Res> implements $ChatSessionModelCopyWith<$Res> {
  factory _$ChatSessionModelCopyWith(_ChatSessionModel value, $Res Function(_ChatSessionModel) _then) = __$ChatSessionModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String peerPubkey, String conversationKeyHex, String transport, int startedAt
});




}
/// @nodoc
class __$ChatSessionModelCopyWithImpl<$Res>
    implements _$ChatSessionModelCopyWith<$Res> {
  __$ChatSessionModelCopyWithImpl(this._self, this._then);

  final _ChatSessionModel _self;
  final $Res Function(_ChatSessionModel) _then;

/// Create a copy of ChatSessionModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? peerPubkey = null,Object? conversationKeyHex = null,Object? transport = null,Object? startedAt = null,}) {
  return _then(_ChatSessionModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,peerPubkey: null == peerPubkey ? _self.peerPubkey : peerPubkey // ignore: cast_nullable_to_non_nullable
as String,conversationKeyHex: null == conversationKeyHex ? _self.conversationKeyHex : conversationKeyHex // ignore: cast_nullable_to_non_nullable
as String,transport: null == transport ? _self.transport : transport // ignore: cast_nullable_to_non_nullable
as String,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
