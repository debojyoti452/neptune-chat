import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/message.dart';

part 'chat_event.freezed.dart';

@freezed
sealed class ChatEvent with _$ChatEvent {
  const factory ChatEvent.sessionStarted({required String peerPubkey}) =
      ChatSessionStarted;
  const factory ChatEvent.messageSent({required String content}) =
      ChatMessageSent;
  const factory ChatEvent.messageReceived({required Message message}) =
      ChatMessageReceived;
  const factory ChatEvent.historyLoaded({required List<Message> messages}) =
      ChatHistoryLoaded;
  const factory ChatEvent.sessionEnded() = ChatSessionEnded;
  const factory ChatEvent.errorOccurred({required String message}) =
      ChatErrorOccurred;
}
