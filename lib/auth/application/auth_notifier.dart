import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:repo_viewer/auth/domain/auth_failure.dart';
import 'package:repo_viewer/auth/infrastructure/github_authenticator.dart';

part 'auth_notifier.freezed.dart';

@freezed
abstract class AuthState with _$AuthState {
  const AuthState._();
  const factory AuthState.initial() = _Initial;
  const factory AuthState.authenticated() = _Authenticated;
  const factory AuthState.unAuthenticated() = _Unauthenticated;
  const factory AuthState.failure(AuthFailure failure) = _Failure;
}

typedef AuthUriCallback = Future<Uri> Function(Uri authorizationUrl);

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._authenticator) : super(const AuthState.initial());
  final GithubAuthenticator _authenticator;

  Future<void> checkAndUpdateAuthStatus() async {
    state = (await _authenticator.isSignedIn())
        ? const AuthState.authenticated()
        : const AuthState.unAuthenticated();
  }

  Future<void> signIn(AuthUriCallback authorizationCallback) async {
    final grant = _authenticator.createGrant();

    final redirectUrl =
        await authorizationCallback(_authenticator.getAuthorizationUrl(grant));
    final successOrFailure = await _authenticator.handleAuthorizationResponse(
        grant, redirectUrl.queryParameters);
    state = successOrFailure.fold(
      (failure) => AuthState.failure(failure),
      (success) => const AuthState.authenticated(),
    );
    grant.close();
  }

  Future<void> signOut() async {
    final failureOrSuccess = await _authenticator.signOut();
    failureOrSuccess.fold(
      (l) => AuthState.failure(l),
      (r) => AuthState.unAuthenticated,
    );
  }
}
