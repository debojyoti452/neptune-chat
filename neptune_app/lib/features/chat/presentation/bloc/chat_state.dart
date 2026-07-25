import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/chat_session.dart';
import '../../domain/entities/message.dart';

part 'chat_state.freezed.dart';

@freezed
sealed class ChatState with _$ChatState {
  const factory ChatState.initial() = ChatInitial;
  const factory ChatState.connecting() = ChatConnecting;
  const factory ChatState.active({
    required ChatSession session,
    required List<Message> messages,
    @Default(false) bool isSending,
  }) = ChatActive;
  const factory ChatState.error({required String message}) = ChatError;
  const factory ChatState.ended() = ChatEnded;
}
