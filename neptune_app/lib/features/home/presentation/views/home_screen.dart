import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startChat() {
    final key = _controller.text.trim();
    if (key.length != 64) return;
    context.push('/chat/$key');
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final pubkey = authState is AuthAuthenticated ? authState.identity.pubkey : '';

    return Scaffold(
      appBar: AppBar(title: const Text('Neptune')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your identity', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: SelectableText(
                    pubkey,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 18),
                  tooltip: 'Copy public key',
                  onPressed: pubkey.isEmpty
                      ? null
                      : () {
                          Clipboard.setData(ClipboardData(text: pubkey));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Public key copied'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                ),
              ],
            ),
            const Divider(height: 48),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Peer public key (64-char hex)',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _startChat(),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _startChat,
              child: const Text('Start chat'),
            ),
          ],
        ),
      ),
    );
  }
}
