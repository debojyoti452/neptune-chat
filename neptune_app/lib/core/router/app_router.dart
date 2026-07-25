import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../di/injection.dart';
import '../../features/auth/presentation/bloc/auth_cubit.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/views/auth_screen.dart';
import '../../features/chat/presentation/bloc/chat_bloc.dart';
import '../../features/chat/presentation/views/chat_screen.dart';
import '../../features/home/presentation/views/home_screen.dart';
import 'go_router_refresh_stream.dart';

abstract final class AppRouter {
  static GoRouter build(AuthCubit authCubit) => GoRouter(
        initialLocation: Routes.auth,
        refreshListenable: GoRouterRefreshStream(authCubit.stream),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state is AuthAuthenticated;
          final location = state.matchedLocation;

          if (!isAuthenticated && location != Routes.auth) return Routes.auth;
          if (isAuthenticated && location == Routes.auth) return Routes.home;
          return null;
        },
        routes: [
          GoRoute(
            path: Routes.auth,
            builder: (_, s) => const AuthScreen(),
          ),
          GoRoute(
            path: Routes.home,
            builder: (_, s) => const HomeScreen(),
          ),
          GoRoute(
            path: Routes.chat,
            builder: (context, state) {
              final peerPubkey = state.pathParameters['peerPubkey']!;
              return BlocProvider(
                create: (_) => getIt<ChatBloc>(),
                child: ChatScreen(peerPubkey: peerPubkey),
              );
            },
          ),
        ],
      );
}

abstract final class Routes {
  static const auth = '/';
  static const home = '/home';
  static const chat = '/chat/:peerPubkey';
}
