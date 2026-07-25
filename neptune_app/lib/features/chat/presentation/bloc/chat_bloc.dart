import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/message.dart';
import '../../domain/usecases/load_local_history.dart';
import '../../domain/usecases/send_message.dart';
import '../../domain/repositories/chat_repository.dart';
import 'chat_event.dart';
import 'chat_state.dart';

@injectable
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _repository;
  final SendMessage _sendMessage;
  final LoadLocalHistory _loadHistory;

  StreamSubscription<Message>? _incomingSub;

  ChatBloc(this._repository, this._sendMessage, this._loadHistory)
    : super(const ChatState.initial()) {
    on<ChatSessionStarted>(_onSessionStarted);
    on<ChatMessageSent>(_onMessageSent);
    on<ChatMessageReceived>(_onMessageReceived);
    on<ChatHistoryLoaded>(_onHistoryLoaded);
    on<ChatSessionEnded>(_onSessionEnded);
    on<ChatErrorOccurred>(_onError);
  }

  Future<void> _onSessionStarted(
    ChatSessionStarted event,
    Emitter<ChatState> emit,
  ) async {
    emit(const ChatState.connecting());

    final result = await _repository.startSession(event.peerPubkey);
    result.fold(
      (failure) => emit(ChatState.error(message: failure.toString())),
      (session) {
        emit(ChatState.active(session: session, messages: const []));

        _incomingSub = _repository
            .incomingMessages(session.id)
            .listen((msg) => add(ChatEvent.messageReceived(message: msg)));

        add(ChatEvent.historyLoaded(messages: const []));
        _loadHistory(session.id).then(
          (result) => result.fold(
            (_) {},
            (msgs) => add(ChatEvent.historyLoaded(messages: msgs)),
          ),
        );
      },
    );
  }

  Future<void> _onMessageSent(
    ChatMessageSent event,
    Emitter<ChatState> emit,
  ) async {
    final current = state;
    if (current is! ChatActive) return;

    emit(
      ChatState.active(
        session: current.session,
        messages: current.messages,
        isSending: true,
      ),
    );

    final result = await _sendMessage(current.session.id, event.content);
    if (result.isLeft()) {
      result.fold(
        (failure) => emit(ChatState.error(message: failure.toString())),
        (_) {},
      );
      return;
    }

    final historyResult = await _loadHistory(current.session.id);
    final updated = historyResult.fold((_) => current.messages, (msgs) => msgs);
    emit(ChatState.active(session: current.session, messages: updated));
  }

  void _onMessageReceived(ChatMessageReceived event, Emitter<ChatState> emit) {
    final current = state;
    if (current is! ChatActive) return;

    emit(
      ChatState.active(
        session: current.session,
        messages: [...current.messages, event.message],
      ),
    );
  }

  void _onHistoryLoaded(ChatHistoryLoaded event, Emitter<ChatState> emit) {
    final current = state;
    if (current is! ChatActive) return;

    emit(ChatState.active(session: current.session, messages: event.messages));
  }

  Future<void> _onSessionEnded(
    ChatSessionEnded event,
    Emitter<ChatState> emit,
  ) async {
    final current = state;
    if (current is! ChatActive) return;

    await _incomingSub?.cancel();
    await _repository.endSession(current.session.id);
    emit(const ChatState.ended());
  }

  void _onError(ChatErrorOccurred event, Emitter<ChatState> emit) {
    emit(ChatState.error(message: event.message));
  }

  @override
  Future<void> close() {
    _incomingSub?.cancel();
    return super.close();
  }
}
