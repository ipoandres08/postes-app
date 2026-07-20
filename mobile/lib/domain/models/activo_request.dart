class CreateActivoRequest {
  final String tipoActivo; // "Poste" o "Medidor"
  final String titulo;
  final String descripcionUbicacion;
  final String direccionAnalitica;
  final double latitud;
  final double longitud;
  final int creadoPorId; 

  CreateActivoRequest({
    required this.tipoActivo,
    required this.titulo,
    required this.descripcionUbicacion,
    required this.direccionAnalitica,
    required this.latitud,
    required this.longitud,
    required this.creadoPorId,
  });

  Map<String, dynamic> toJson() => {
        'tipoActivo': tipoActivo,
        'titulo': titulo,
        'descripcionUbicacion': descripcionUbicacion,
        'direccionAnalitica': direccionAnalitica,
        'latitud': latitud,
        'longitud': longitud,
        'creadoPorId': creadoPorId,
      };
}