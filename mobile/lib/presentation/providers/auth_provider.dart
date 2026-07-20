import 'package:flutter_riverpod/flutter_riverpod.dart';
// Corregimos los imports para que apunten a las carpetas correctas
import '../../core/network/dio.client.dart'; 
import '../../domain/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';

// Proveedor de la instancia del cliente HTTP
final dioClientProvider = Provider<DioClient>((ref) => DioClient());

// Proveedor del Repositorio
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.watch(dioClientProvider);
  return AuthRepositoryImpl(client);
});

// Estado global de la Autenticación
class AuthState {
  final bool isLoading;
  final bool isAuthed;
  final String? errorMessage;

  AuthState({this.isLoading = false, this.isAuthed = false, this.errorMessage});

  AuthState copyWith({bool? isLoading, bool? isAuthed, String? errorMessage}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthed: isAuthed ?? this.isAuthed,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// 🚀 Modernización: Usamos Notifier en lugar de StateNotifier
class AuthNotifier extends Notifier<AuthState> {
  
  // Obtenemos el repositorio directamente usando ref.read
  AuthRepository get _repository => ref.read(authRepositoryProvider);

  @override
  AuthState build() {
    // Al inicializarse el estado, mandamos a verificar la sesión
    _checkStatus();
    // Retornamos el estado inicial por defecto
    return AuthState();
  }

  void _checkStatus() async {
    final authed = await _repository.isAuthenticated();
    state = AuthState(isAuthed: authed);
  }

  Future<void> login(String username, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final success = await _repository.login(username, password);
    
    if (success) {
      state = AuthState(isAuthed: true);
    } else {
      state = AuthState(isAuthed: false, errorMessage: 'Credenciales inválidas o sin conexión a internet.');
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = AuthState(isAuthed: false);
  }
}

// 🚀 Modernización: Usamos NotifierProvider
final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});