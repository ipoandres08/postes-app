import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DioClient {
  final Dio dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  DioClient() : dio = Dio(
          BaseOptions(
            baseUrl: 'http://localhost:5047/api', // Asegúrate de usar la IP de tu máquina si pruebas en dispositivo físico
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
          ),
        ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'jwt_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          if (e.response?.statusCode == 401) {
            // Manejar desautenticación global aquí si expira el token online
          }
          return handler.next(e);
        },
      ),
    );
  }
}