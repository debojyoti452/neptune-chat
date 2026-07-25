// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChatState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ChatState()';
}


}

/// @nodoc
class $ChatStateCopyWith<$Res>  {
$ChatStateCopyWith(ChatState _, $Res Function(ChatState) __);
}


/// Adds pattern-matching-related methods to [ChatState].
extension ChatStatePatterns on ChatState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ChatInitial value)?  initial,TResult Function( ChatConnecting value)?  connecting,TResult Function( ChatActive value)?  active,TResult Function( ChatError value)?  error,TResult Function( ChatEnded value)?  ended,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ChatInitial() when initial != null:
return initial(_that);case ChatConnecting() when connecting != null:
return connecting(_that);case ChatActive() when active != null:
return active(_that);case ChatError() when error != null:
return error(_that);case ChatEnded() when ended != null:
return ended(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ChatInitial value)  initial,required TResult Function( ChatConnecting value)  connecting,required TResult Function( ChatActive value)  active,required TResult Function( ChatError value)  error,required TResult Function( ChatEnded value)  ended,}){
final _that = this;
switch (_that) {
case ChatInitial():
return initial(_that);case ChatConnecting():
return connecting(_that);case ChatActive():
return active(_that);case ChatError():
return error(_that);case ChatEnded():
return ended(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ChatInitial value)?  initial,TResult? Function( ChatConnecting value)?  connecting,TResult? Function( ChatActive value)?  active,TResult? Function( ChatError value)?  error,TResult? Function( ChatEnded value)?  ended,}){
final _that = this;
switch (_that) {
case ChatInitial() when initial != null:
return initial(_that);case ChatConnecting() when connecting != null:
return connecting(_that);case ChatActive() when active != null:
return active(_that);case ChatError() when error != null:
return error(_that);case ChatEnded() when ended != null:
return ended(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  connecting,TResult Function( ChatSession session,  List<Message> messages,  bool isSending)?  active,TResult Function( String message)?  error,TResult Function()?  ended,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ChatInitial() when initial != null:
return initial();case ChatConnecting() when connecting != null:
return connecting();case ChatActive() when active != null:
return active(_that.session,_that.messages,_that.isSending);case ChatError() when error != null:
return error(_that.message);case ChatEnded() when ended != null:
return ended();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  connecting,required TResult Function( ChatSession session,  List<Message> messages,  bool isSending)  active,required TResult Function( String message)  error,required TResult Function()  ended,}) {final _that = this;
switch (_that) {
case ChatInitial():
return initial();case ChatConnecting():
return connecting();case ChatActive():
return active(_that.session,_that.messages,_that.isSending);case ChatError():
return error(_that.message);case ChatEnded():
return ended();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  connecting,TResult? Function( ChatSession session,  List<Message> messages,  bool isSending)?  active,TResult? Function( String message)?  error,TResult? Function()?  ended,}) {final _that = this;
switch (_that) {
case ChatInitial() when initial != null:
return initial();case ChatConnecting() when connecting != null:
return connecting();case ChatActive() when active != null:
return active(_that.session,_that.messages,_that.isSending);case ChatError() when error != null:
return error(_that.message);case ChatEnded() when ended != null:
return ended();case _:
  return null;

}
}

}

/// @nodoc


class ChatInitial implements ChatState {
  const ChatInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ChatState.initial()';
}


}




/// @nodoc


class ChatConnecting implements ChatState {
  const ChatConnecting();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatConnecting);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ChatState.connecting()';
}


}




/// @nodoc


class ChatActive implements ChatState {
  const ChatActive({required this.session, required final  List<Message> messages, this.isSending = false}): _messages = messages;
  

 final  ChatSession session;
 final  List<Message> _messages;
 List<Message> get messages {
  if (_messages is EqualUnmodifiableListView) return _messages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_messages);
}

@JsonKey() final  bool isSending;

/// Create a copy of ChatState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatActiveCopyWith<ChatActive> get copyWith => _$ChatActiveCopyWithImpl<ChatActive>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatActive&&(identical(other.session, session) || other.session == session)&&const DeepCollectionEquality().equals(other._messages, _messages)&&(identical(other.isSending, isSending) || other.isSending == isSending));
}


@override
int get hashCode => Object.hash(runtimeType,session,const DeepCollectionEquality().hash(_messages),isSending);

@override
String toString() {
  return 'ChatState.active(session: $session, messages: $messages, isSending: $isSending)';
}


}

/// @nodoc
abstract mixin class $ChatActiveCopyWith<$Res> implements $ChatStateCopyWith<$Res> {
  factory $ChatActiveCopyWith(ChatActive value, $Res Function(ChatActive) _then) = _$ChatActiveCopyWithImpl;
@useResult
$Res call({
 ChatSession session, List<Message> messages, bool isSending
});




}
/// @nodoc
class _$ChatActiveCopyWithImpl<$Res>
    implements $ChatActiveCopyWith<$Res> {
  _$ChatActiveCopyWithImpl(this._self, this._then);

  final ChatActive _self;
  final $Res Function(ChatActive) _then;

/// Create a copy of ChatState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? session = null,Object? messages = null,Object? isSending = null,}) {
  return _then(ChatActive(
session: null == session ? _self.session : session // ignore: cast_nullable_to_non_nullable
as ChatSession,messages: null == messages ? _self._messages : messages // ignore: cast_nullable_to_non_nullable
as List<Message>,isSending: null == isSending ? _self.isSending : isSending // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class ChatError implements ChatState {
  const ChatError({required this.message});
  

 final  String message;

/// Create a copy of ChatState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatErrorCopyWith<ChatError> get copyWith => _$ChatErrorCopyWithImpl<ChatError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'ChatState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $ChatErrorCopyWith<$Res> implements $ChatStateCopyWith<$Res> {
  factory $ChatErrorCopyWith(ChatError value, $Res Function(ChatError) _then) = _$ChatErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$ChatErrorCopyWithImpl<$Res>
    implements $ChatErrorCopyWith<$Res> {
  _$ChatErrorCopyWithImpl(this._self, this._then);

  final ChatError _self;
  final $Res Function(ChatError) _then;

/// Create a copy of ChatState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(ChatError(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ChatEnded implements ChatState {
  const ChatEnded();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatEnded);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ChatState.ended()';
}


}




// dart format on
