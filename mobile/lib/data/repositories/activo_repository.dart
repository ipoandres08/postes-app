import 'package:dio/dio.dart';
import 'package:mobile/domain/models/activo_response.dart';
import '../../core/network/dio.client.dart';
import '../../domain/models/activo_request.dart';

class ActivoRepository {
  final DioClient _client;

  ActivoRepository(this._client);

  Future<bool> createActivo(CreateActivoRequest request) async {
    try {
      final response = await _client.dio.post(
        '/Activos',
        data: request.toJson(),
      );
      
      return response.statusCode == 201; // Created
    } on DioException catch (e) {
      print('Error al crear activo: ${e.response?.data}');
      return false;
    }
  }

  Future<List<ActivoResponse>> getActivos() async {
    try {
      final response = await _client.dio.get('/Activos');
      final List<dynamic> data = response.data;
      return data.map((json) => ActivoResponse.fromJson(json)).toList();
    } on DioException catch (e) {
      print('Error al obtener activos: ${e.response?.data}');
      return [];
    }
  }
}