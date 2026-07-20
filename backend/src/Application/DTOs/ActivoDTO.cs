namespace Application.DTOs;

// Incluimos TipoActivo para que el API sepa si instanciar Poste o Medidor
public record CreateActivoRequest(
    string TipoActivo, // "Poste" o "Medidor"
    string Titulo, 
    string DescripcionUbicacion, 
    string DireccionAnalitica, 
    double Latitud, 
    double Longitud,
    int CreadoPorId
);

public record UpdateActivoRequest(
    string Titulo,
    string DescripcionUbicacion,
    string DireccionAnalitica,
    double Latitud,
    double Longitud,
    int ActualizadoPorId,
    uint Version // Vital para la concurrencia optimista
);

public record ActivoResponse(
    int Id, 
    string TipoActivo,
    string Titulo, 
    string DescripcionUbicacion,
    string DireccionAnalitica, 
    double Latitud, 
    double Longitud,
    uint Version
);