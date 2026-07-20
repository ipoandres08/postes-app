import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/domain/models/activo_request.dart';
import 'package:mobile/domain/models/activo_response.dart';
import '../../core/network/dio.client.dart';
import '../../data/repositories/activo_repository.dart';
import 'auth_provider.dart';

final activoRepositoryProvider = Provider<ActivoRepository>((ref) {
  final client = ref.watch(dioClientProvider);
  return ActivoRepository(client);
});

class ActivoFormState {
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  ActivoFormState({this.isLoading = false, this.errorMessage, this.isSuccess = false});
}

class ActivoNotifier extends Notifier<ActivoFormState> {
  ActivoRepository get _repository => ref.read(activoRepositoryProvider);

  @override
  ActivoFormState build() {
    return ActivoFormState();
  }

  Future<void> crearActivo(CreateActivoRequest request) async {
    state = ActivoFormState(isLoading: true);
    
    final success = await _repository.createActivo(request);
    
    if (success) {
      state = ActivoFormState(isSuccess: true);
    } else {
      state = ActivoFormState(errorMessage: 'Error al registrar el activo en el servidor.');
    }
  }
}

final activoFormProvider = NotifierProvider<ActivoNotifier, ActivoFormState>(() {
  return ActivoNotifier();
});

final activosListProvider = FutureProvider.autoDispose<List<ActivoResponse>>((ref) async {
  final repository = ref.watch(activoRepositoryProvider);
  return repository.getActivos();
});