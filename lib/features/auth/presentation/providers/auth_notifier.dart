import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/auth_state.dart' as domain;
import '../../data/auth_repository.dart';

final supabaseClientProvider = Provider<SupabaseClient>(
  (_) => Supabase.instance.client,
);

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(supabaseClientProvider));
});

String _traducirError(String msg) {
  if (msg.contains('Invalid login credentials')) {
    return 'Correo o contraseña incorrectos';
  }
  if (msg.contains('Email not confirmed')) {
    return 'Confirma tu correo antes de iniciar sesión';
  }
  if (msg.contains('User already registered')) {
    return 'Este correo ya está registrado';
  }
  if (msg.contains('Password should be at least 6')) {
    return 'La contraseña debe tener al menos 6 caracteres';
  }
  if (msg.contains('invalid format') || msg.contains('Unable to validate email')) {
    return 'El correo no tiene un formato válido';
  }
  return msg;
}

class AuthNotifier extends StateNotifier<domain.AuthState> {
  final AuthRepository _repo;

  AuthNotifier(this._repo) : super(const domain.AuthInitial()) {
    _init();
  }

  void _init() {
    final user = _repo.currentUser;
    state = user != null
        ? domain.AuthAuthenticated(user)
        : const domain.AuthUnauthenticated();

    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null) {
        state = domain.AuthAuthenticated(session.user);
      } else {
        state = const domain.AuthUnauthenticated();
      }
    });
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = const domain.AuthLoading();
    try {
      await _repo.signInWithEmail(email, password);
    } on AuthException catch (e) {
      state = domain.AuthError(_traducirError(e.message));
    } catch (e) {
      state = domain.AuthError(_traducirError(e.toString()));
    }
  }

  Future<void> signUpWithEmail(String email, String password) async {
    state = const domain.AuthLoading();
    try {
      await _repo.signUpWithEmail(email, password);
      // onAuthStateChange manejará el estado si confirma sesión directamente
      // Si requiere confirmación de email, permanecemos en AuthUnauthenticated
      state = const domain.AuthUnauthenticated();
    } on AuthException catch (e) {
      state = domain.AuthError(_traducirError(e.message));
    } catch (e) {
      state = domain.AuthError(_traducirError(e.toString()));
    }
  }

  Future<bool> resetPasswordForEmail(String email) async {
    state = const domain.AuthLoading();
    try {
      await _repo.resetPasswordForEmail(email);
      state = const domain.AuthUnauthenticated();
      return true;
    } on AuthException catch (e) {
      state = domain.AuthError(_traducirError(e.message));
      return false;
    } catch (e) {
      state = domain.AuthError(_traducirError(e.toString()));
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _repo.signOut();
    } catch (_) {
      state = const domain.AuthUnauthenticated();
    }
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, domain.AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});
