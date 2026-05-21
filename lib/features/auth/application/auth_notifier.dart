import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/supabase_auth_repository.dart';
import '../domain/auth_repository.dart';
import '../domain/models/auth_session.dart';
import '../domain/models/sign_up_result.dart';

class AuthSessionController extends Notifier<AuthSession> {
  StreamSubscription<AuthSession>? _sub;

  @override
  AuthSession build() {
    final repo = ref.watch(authRepositoryProvider);
    _sub = repo.watchSession().listen((s) {
      state = s;
    });
    ref.onDispose(() => _sub?.cancel());
    return repo.currentSession;
  }
}

final authSessionControllerProvider =
    NotifierProvider<AuthSessionController, AuthSession>(
  AuthSessionController.new,
);

class AuthActions extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  Future<EmailSession> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    try {
      final s = await _repo.signInWithEmail(email: email, password: password);
      await _repo.ensureBootstrap();
      state = const AsyncData(null);
      return s;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<SignUpResult> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    try {
      final res = await _repo.signUpWithEmail(email: email, password: password);
      if (res is SignUpConfirmed) {
        await _repo.ensureBootstrap();
      }
      state = const AsyncData(null);
      return res;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<GuestSession> signInAsGuest() async {
    state = const AsyncLoading();
    try {
      final s = await _repo.signInAsGuest();
      await _repo.ensureBootstrap();
      state = const AsyncData(null);
      return s;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    try {
      await _repo.signOut();
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final authActionsProvider =
    AsyncNotifierProvider<AuthActions, void>(AuthActions.new);
