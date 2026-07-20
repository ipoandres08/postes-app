class ActivoResponse {
  final int id;
  final String tipoActivo;
  final String titulo;
  final String descripcionUbicacion;
  final String direccionAnalitica;
  final double latitud;
  final double longitud;

  ActivoResponse({
    required this.id,
    required this.tipoActivo,
    required this.titulo,
    required this.descripcionUbicacion,
    required this.direccionAnalitica,
    required this.latitud,
    required this.longitud,
  });

  factory ActivoResponse.fromJson(Map<String, dynamic> json) {
    return ActivoResponse(
      id: json['id'],
      tipoActivo: json['tipoActivo'] ?? 'Desconocido',
      titulo: json['titulo'] ?? '',
      descripcionUbicacion: json['descripcionUbicacion'] ?? '',
      direccionAnalitica: json['direccionAnalitica'] ?? '',
      latitud: (json['latitud'] as num).toDouble(),
      longitud: (json['longitud'] as num).toDouble(),
    );
  }
}