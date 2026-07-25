import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  final String peerPubkey;

  const ChatScreen({super.key, required this.peerPubkey});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(
      ChatEvent.sessionStarted(peerPubkey: widget.peerPubkey),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    context.read<ChatBloc>().add(ChatEvent.messageSent(content: text));
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.peerPubkey.substring(0, 8)}...',
          style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () =>
                context.read<ChatBloc>().add(const ChatEvent.sessionEnded()),
          ),
        ],
      ),
      body: BlocConsumer<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state is ChatActive && state.messages.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
              );
            });
          }
        },
        builder: (context, state) => switch (state) {
          ChatInitial() ||
          ChatConnecting() => const Center(child: CircularProgressIndicator()),
          ChatActive(:final messages, :final isSending) => Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (_, index) =>
                      MessageBubble(message: messages[index]),
                ),
              ),
              _InputBar(
                controller: _controller,
                isSending: isSending,
                onSend: _send,
              ),
            ],
          ),
          ChatError(:final message) => Center(child: Text(message)),
          ChatEnded() => const Center(child: Text('Session ended')),
        },
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSend;

  const _InputBar({
    required this.controller,
    required this.isSending,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'Message',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                onSubmitted: (_) => onSend(),
              ),
            ),
            const SizedBox(width: 8),
            isSending
                ? const SizedBox(
                    width: 48,
                    height: 48,
                    child: Center(child: CircularProgressIndicator()),
                  )
                : IconButton.filled(
                    onPressed: onSend,
                    icon: const Icon(Icons.send),
                  ),
          ],
        ),
      ),
    );
  }
}
