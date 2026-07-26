// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChatEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ChatEvent()';
}


}

/// @nodoc
class $ChatEventCopyWith<$Res>  {
$ChatEventCopyWith(ChatEvent _, $Res Function(ChatEvent) __);
}


/// Adds pattern-matching-related methods to [ChatEvent].
extension ChatEventPatterns on ChatEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ChatSessionStarted value)?  sessionStarted,TResult Function( ChatSessionRestored value)?  sessionRestored,TResult Function( ChatMessageSent value)?  messageSent,TResult Function( ChatMessageReceived value)?  messageReceived,TResult Function( ChatHistoryLoaded value)?  historyLoaded,TResult Function( ChatSessionEnded value)?  sessionEnded,TResult Function( ChatErrorOccurred value)?  errorOccurred,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ChatSessionStarted() when sessionStarted != null:
return sessionStarted(_that);case ChatSessionRestored() when sessionRestored != null:
return sessionRestored(_that);case ChatMessageSent() when messageSent != null:
return messageSent(_that);case ChatMessageReceived() when messageReceived != null:
return messageReceived(_that);case ChatHistoryLoaded() when historyLoaded != null:
return historyLoaded(_that);case ChatSessionEnded() when sessionEnded != null:
return sessionEnded(_that);case ChatErrorOccurred() when errorOccurred != null:
return errorOccurred(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ChatSessionStarted value)  sessionStarted,required TResult Function( ChatSessionRestored value)  sessionRestored,required TResult Function( ChatMessageSent value)  messageSent,required TResult Function( ChatMessageReceived value)  messageReceived,required TResult Function( ChatHistoryLoaded value)  historyLoaded,required TResult Function( ChatSessionEnded value)  sessionEnded,required TResult Function( ChatErrorOccurred value)  errorOccurred,}){
final _that = this;
switch (_that) {
case ChatSessionStarted():
return sessionStarted(_that);case ChatSessionRestored():
return sessionRestored(_that);case ChatMessageSent():
return messageSent(_that);case ChatMessageReceived():
return messageReceived(_that);case ChatHistoryLoaded():
return historyLoaded(_that);case ChatSessionEnded():
return sessionEnded(_that);case ChatErrorOccurred():
return errorOccurred(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ChatSessionStarted value)?  sessionStarted,TResult? Function( ChatSessionRestored value)?  sessionRestored,TResult? Function( ChatMessageSent value)?  messageSent,TResult? Function( ChatMessageReceived value)?  messageReceived,TResult? Function( ChatHistoryLoaded value)?  historyLoaded,TResult? Function( ChatSessionEnded value)?  sessionEnded,TResult? Function( ChatErrorOccurred value)?  errorOccurred,}){
final _that = this;
switch (_that) {
case ChatSessionStarted() when sessionStarted != null:
return sessionStarted(_that);case ChatSessionRestored() when sessionRestored != null:
return sessionRestored(_that);case ChatMessageSent() when messageSent != null:
return messageSent(_that);case ChatMessageReceived() when messageReceived != null:
return messageReceived(_that);case ChatHistoryLoaded() when historyLoaded != null:
return historyLoaded(_that);case ChatSessionEnded() when sessionEnded != null:
return sessionEnded(_that);case ChatErrorOccurred() when errorOccurred != null:
return errorOccurred(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String peerPubkey)?  sessionStarted,TResult Function( String sessionId)?  sessionRestored,TResult Function( String content)?  messageSent,TResult Function( Message message)?  messageReceived,TResult Function( List<Message> messages)?  historyLoaded,TResult Function()?  sessionEnded,TResult Function( String message)?  errorOccurred,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ChatSessionStarted() when sessionStarted != null:
return sessionStarted(_that.peerPubkey);case ChatSessionRestored() when sessionRestored != null:
return sessionRestored(_that.sessionId);case ChatMessageSent() when messageSent != null:
return messageSent(_that.content);case ChatMessageReceived() when messageReceived != null:
return messageReceived(_that.message);case ChatHistoryLoaded() when historyLoaded != null:
return historyLoaded(_that.messages);case ChatSessionEnded() when sessionEnded != null:
return sessionEnded();case ChatErrorOccurred() when errorOccurred != null:
return errorOccurred(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String peerPubkey)  sessionStarted,required TResult Function( String sessionId)  sessionRestored,required TResult Function( String content)  messageSent,required TResult Function( Message message)  messageReceived,required TResult Function( List<Message> messages)  historyLoaded,required TResult Function()  sessionEnded,required TResult Function( String message)  errorOccurred,}) {final _that = this;
switch (_that) {
case ChatSessionStarted():
return sessionStarted(_that.peerPubkey);case ChatSessionRestored():
return sessionRestored(_that.sessionId);case ChatMessageSent():
return messageSent(_that.content);case ChatMessageReceived():
return messageReceived(_that.message);case ChatHistoryLoaded():
return historyLoaded(_that.messages);case ChatSessionEnded():
return sessionEnded();case ChatErrorOccurred():
return errorOccurred(_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String peerPubkey)?  sessionStarted,TResult? Function( String sessionId)?  sessionRestored,TResult? Function( String content)?  messageSent,TResult? Function( Message message)?  messageReceived,TResult? Function( List<Message> messages)?  historyLoaded,TResult? Function()?  sessionEnded,TResult? Function( String message)?  errorOccurred,}) {final _that = this;
switch (_that) {
case ChatSessionStarted() when sessionStarted != null:
return sessionStarted(_that.peerPubkey);case ChatSessionRestored() when sessionRestored != null:
return sessionRestored(_that.sessionId);case ChatMessageSent() when messageSent != null:
return messageSent(_that.content);case ChatMessageReceived() when messageReceived != null:
return messageReceived(_that.message);case ChatHistoryLoaded() when historyLoaded != null:
return historyLoaded(_that.messages);case ChatSessionEnded() when sessionEnded != null:
return sessionEnded();case ChatErrorOccurred() when errorOccurred != null:
return errorOccurred(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class ChatSessionStarted implements ChatEvent {
  const ChatSessionStarted({required this.peerPubkey});
  

 final  String peerPubkey;

/// Create a copy of ChatEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatSessionStartedCopyWith<ChatSessionStarted> get copyWith => _$ChatSessionStartedCopyWithImpl<ChatSessionStarted>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatSessionStarted&&(identical(other.peerPubkey, peerPubkey) || other.peerPubkey == peerPubkey));
}


@override
int get hashCode => Object.hash(runtimeType,peerPubkey);

@override
String toString() {
  return 'ChatEvent.sessionStarted(peerPubkey: $peerPubkey)';
}


}

/// @nodoc
abstract mixin class $ChatSessionStartedCopyWith<$Res> implements $ChatEventCopyWith<$Res> {
  factory $ChatSessionStartedCopyWith(ChatSessionStarted value, $Res Function(ChatSessionStarted) _then) = _$ChatSessionStartedCopyWithImpl;
@useResult
$Res call({
 String peerPubkey
});




}
/// @nodoc
class _$ChatSessionStartedCopyWithImpl<$Res>
    implements $ChatSessionStartedCopyWith<$Res> {
  _$ChatSessionStartedCopyWithImpl(this._self, this._then);

  final ChatSessionStarted _self;
  final $Res Function(ChatSessionStarted) _then;

/// Create a copy of ChatEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? peerPubkey = null,}) {
  return _then(ChatSessionStarted(
peerPubkey: null == peerPubkey ? _self.peerPubkey : peerPubkey // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ChatSessionRestored implements ChatEvent {
  const ChatSessionRestored({required this.sessionId});
  

 final  String sessionId;

/// Create a copy of ChatEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatSessionRestoredCopyWith<ChatSessionRestored> get copyWith => _$ChatSessionRestoredCopyWithImpl<ChatSessionRestored>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatSessionRestored&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId));
}


@override
int get hashCode => Object.hash(runtimeType,sessionId);

@override
String toString() {
  return 'ChatEvent.sessionRestored(sessionId: $sessionId)';
}


}

/// @nodoc
abstract mixin class $ChatSessionRestoredCopyWith<$Res> implements $ChatEventCopyWith<$Res> {
  factory $ChatSessionRestoredCopyWith(ChatSessionRestored value, $Res Function(ChatSessionRestored) _then) = _$ChatSessionRestoredCopyWithImpl;
@useResult
$Res call({
 String sessionId
});




}
/// @nodoc
class _$ChatSessionRestoredCopyWithImpl<$Res>
    implements $ChatSessionRestoredCopyWith<$Res> {
  _$ChatSessionRestoredCopyWithImpl(this._self, this._then);

  final ChatSessionRestored _self;
  final $Res Function(ChatSessionRestored) _then;

/// Create a copy of ChatEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? sessionId = null,}) {
  return _then(ChatSessionRestored(
sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ChatMessageSent implements ChatEvent {
  const ChatMessageSent({required this.content});
  

 final  String content;

/// Create a copy of ChatEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatMessageSentCopyWith<ChatMessageSent> get copyWith => _$ChatMessageSentCopyWithImpl<ChatMessageSent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatMessageSent&&(identical(other.content, content) || other.content == content));
}


@override
int get hashCode => Object.hash(runtimeType,content);

@override
String toString() {
  return 'ChatEvent.messageSent(content: $content)';
}


}

/// @nodoc
abstract mixin class $ChatMessageSentCopyWith<$Res> implements $ChatEventCopyWith<$Res> {
  factory $ChatMessageSentCopyWith(ChatMessageSent value, $Res Function(ChatMessageSent) _then) = _$ChatMessageSentCopyWithImpl;
@useResult
$Res call({
 String content
});




}
/// @nodoc
class _$ChatMessageSentCopyWithImpl<$Res>
    implements $ChatMessageSentCopyWith<$Res> {
  _$ChatMessageSentCopyWithImpl(this._self, this._then);

  final ChatMessageSent _self;
  final $Res Function(ChatMessageSent) _then;

/// Create a copy of ChatEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? content = null,}) {
  return _then(ChatMessageSent(
content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ChatMessageReceived implements ChatEvent {
  const ChatMessageReceived({required this.message});
  

 final  Message message;

/// Create a copy of ChatEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatMessageReceivedCopyWith<ChatMessageReceived> get copyWith => _$ChatMessageReceivedCopyWithImpl<ChatMessageReceived>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatMessageReceived&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'ChatEvent.messageReceived(message: $message)';
}


}

/// @nodoc
abstract mixin class $ChatMessageReceivedCopyWith<$Res> implements $ChatEventCopyWith<$Res> {
  factory $ChatMessageReceivedCopyWith(ChatMessageReceived value, $Res Function(ChatMessageReceived) _then) = _$ChatMessageReceivedCopyWithImpl;
@useResult
$Res call({
 Message message
});




}
/// @nodoc
class _$ChatMessageReceivedCopyWithImpl<$Res>
    implements $ChatMessageReceivedCopyWith<$Res> {
  _$ChatMessageReceivedCopyWithImpl(this._self, this._then);

  final ChatMessageReceived _self;
  final $Res Function(ChatMessageReceived) _then;

/// Create a copy of ChatEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(ChatMessageReceived(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as Message,
  ));
}


}

/// @nodoc


class ChatHistoryLoaded implements ChatEvent {
  const ChatHistoryLoaded({required final  List<Message> messages}): _messages = messages;
  

 final  List<Message> _messages;
 List<Message> get messages {
  if (_messages is EqualUnmodifiableListView) return _messages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_messages);
}


/// Create a copy of ChatEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatHistoryLoadedCopyWith<ChatHistoryLoaded> get copyWith => _$ChatHistoryLoadedCopyWithImpl<ChatHistoryLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatHistoryLoaded&&const DeepCollectionEquality().equals(other._messages, _messages));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_messages));

@override
String toString() {
  return 'ChatEvent.historyLoaded(messages: $messages)';
}


}

/// @nodoc
abstract mixin class $ChatHistoryLoadedCopyWith<$Res> implements $ChatEventCopyWith<$Res> {
  factory $ChatHistoryLoadedCopyWith(ChatHistoryLoaded value, $Res Function(ChatHistoryLoaded) _then) = _$ChatHistoryLoadedCopyWithImpl;
@useResult
$Res call({
 List<Message> messages
});




}
/// @nodoc
class _$ChatHistoryLoadedCopyWithImpl<$Res>
    implements $ChatHistoryLoadedCopyWith<$Res> {
  _$ChatHistoryLoadedCopyWithImpl(this._self, this._then);

  final ChatHistoryLoaded _self;
  final $Res Function(ChatHistoryLoaded) _then;

/// Create a copy of ChatEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? messages = null,}) {
  return _then(ChatHistoryLoaded(
messages: null == messages ? _self._messages : messages // ignore: cast_nullable_to_non_nullable
as List<Message>,
  ));
}


}

/// @nodoc


class ChatSessionEnded implements ChatEvent {
  const ChatSessionEnded();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatSessionEnded);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ChatEvent.sessionEnded()';
}


}




/// @nodoc


class ChatErrorOccurred implements ChatEvent {
  const ChatErrorOccurred({required this.message});
  

 final  String message;

/// Create a copy of ChatEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatErrorOccurredCopyWith<ChatErrorOccurred> get copyWith => _$ChatErrorOccurredCopyWithImpl<ChatErrorOccurred>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatErrorOccurred&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'ChatEvent.errorOccurred(message: $message)';
}


}

/// @nodoc
abstract mixin class $ChatErrorOccurredCopyWith<$Res> implements $ChatEventCopyWith<$Res> {
  factory $ChatErrorOccurredCopyWith(ChatErrorOccurred value, $Res Function(ChatErrorOccurred) _then) = _$ChatErrorOccurredCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$ChatErrorOccurredCopyWithImpl<$Res>
    implements $ChatErrorOccurredCopyWith<$Res> {
  _$ChatErrorOccurredCopyWithImpl(this._self, this._then);

  final ChatErrorOccurred _self;
  final $Res Function(ChatErrorOccurred) _then;

/// Create a copy of ChatEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(ChatErrorOccurred(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
