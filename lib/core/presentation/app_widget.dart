import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:repo_viewer/auth/application/auth_notifier.dart';
import 'package:repo_viewer/auth/shared/providers.dart';
import 'package:repo_viewer/core/presentation/routes/app_router.gr.dart';

final initializationProvider = FutureProvider(
  (ref) async {
    final authNotifier = ref.read(authNotifierProvider.notifier);
    await authNotifier.checkAndUpdateAuthStatus();
  },
);

class AppWidget extends ConsumerWidget {
  AppWidget({Key? key}) : super(key: key);
  final appRouter = AppRouter();
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(initializationProvider, (previous, next) {});
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      next.maybeWhen(
          orElse: () {},
          authenticated: () {
            appRouter.pushAndPopUntil(
              const StarredReposRoute(),
              predicate: (route) => false,
            );
          },
          unAuthenticated: () {
            appRouter.pushAndPopUntil(
              const SignInRoute(),
              predicate: (route) => false,
            );
          });
    });
    return MaterialApp.router(
      title: 'Repo Viewer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routerDelegate: appRouter.delegate(),
      routeInformationParser: appRouter.defaultRouteParser(),
    );
  }
}


// class AppWidget extends StatelessWidget {
//   AppWidget({Key? key}) : super(key: key);
//   final appRouter = AppRouter();
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return ProviderListener(
//       provider: initializationProvider,
//       onChange: (context, provider, child) {},
//       child: MaterialApp.router(
//         title: 'Repo Viewer',
//         theme: ThemeData(
//           primarySwatch: Colors.blue,
//         ),
//         routerDelegate: appRouter.delegate(),
//         routeInformationParser: appRouter.defaultRouteParser(),
//       ),
//     );
//   }
// }
