import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AuthCubit>().initialize();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go(Routes.home);
        }
      },
      child: Scaffold(
        body: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) => switch (state) {
            AuthInitial() || AuthLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
            AuthAuthenticated() => const SizedBox.shrink(),
            AuthError(:final message) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(message),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => context.read<AuthCubit>().initialize(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
          },
        ),
      ),
    );
  }
}
