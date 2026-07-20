using Application.Common;
using Application.DTOs;
using Application.Interfaces;
using Domain.Entities;
using Domain.Interfaces;
using NetTopologySuite.Geometries;

namespace Application.Services;

public class ActivoService : IActivoService
{
    private readonly IActivoRepository _repository;
    private readonly GeometryFactory _geometryFactory = new(new PrecisionModel(), 4326);

    public ActivoService(IActivoRepository repository)
    {
        _repository = repository;
    }

    public async Task<List<ActivoResponse>> GetAllAsync()
    {
        var activos = await _repository.GetAllAsync();
        return activos.Select(MapToResponse).ToList();
    }

    public async Task<ActivoResponse?> GetByIdAsync(int id)
    {
        var activo = await _repository.GetByIdAsync(id);
        return activo == null ? null : MapToResponse(activo);
    }

    public async Task<ActivoResponse> CreateAsync(CreateActivoRequest request)
    {
        Activo activo = request.TipoActivo.ToLower() switch
        {
            "poste" => new Poste(),
            "medidor" => new Medidor(),
            _ => throw new ArgumentException("El tipo de activo debe ser 'Poste' o 'Medidor'")
        };

        activo.Titulo = request.Titulo;
        activo.DescripcionUbicacion = request.DescripcionUbicacion;
        activo.DireccionAnalitica = request.DireccionAnalitica;
        activo.CreadoPorId = request.CreadoPorId;
        activo.ActualizadoPorId = request.CreadoPorId;
        activo.CreatedAt = DateTime.UtcNow;
        activo.UpdatedAt = DateTime.UtcNow;
        
        // NetTopologySuite recibe: X = Longitud, Y = Latitud
        activo.Ubicacion = _geometryFactory.CreatePoint(new Coordinate(request.Longitud, request.Latitud));

        var creado = await _repository.AddAsync(activo);
        return MapToResponse(creado);
    }

    public async Task<OperationResult> UpdateAsync(int id, UpdateActivoRequest request)
    {
        var activo = await _repository.GetByIdAsync(id);
        if (activo == null) return OperationResult.NotFound;

        activo.Titulo = request.Titulo;
        activo.DescripcionUbicacion = request.DescripcionUbicacion;
        activo.DireccionAnalitica = request.DireccionAnalitica;
        activo.ActualizadoPorId = request.ActualizadoPorId;
        activo.UpdatedAt = DateTime.UtcNow;
        activo.Ubicacion = _geometryFactory.CreatePoint(new Coordinate(request.Longitud, request.Latitud));
        
        // Se adjunta la versión enviada por el cliente para la concurrencia optimista
        activo.Version = request.Version;

        var success = await _repository.UpdateAsync(activo);
        return success ? OperationResult.Success : OperationResult.Conflict;
    }

    public async Task<OperationResult> DeleteAsync(int id)
    {
        var activo = await _repository.GetByIdAsync(id);
        if (activo == null) return OperationResult.NotFound;

        var success = await _repository.DeleteAsync(activo);
        return success ? OperationResult.Success : OperationResult.Conflict;
    }

    public async Task<List<ActivoResponse>> SearchAsync(string? query, double? lat, double? lng, double? radiusInMeters)
    {
        var resultados = await _repository.SearchAsync(query, lat, lng, radiusInMeters);
        return resultados.Select(MapToResponse).ToList();
    }

    private ActivoResponse MapToResponse(Activo activo)
    {
        return new ActivoResponse(
            Id: activo.Id,
            TipoActivo: activo is Poste ? "Poste" : "Medidor",
            Titulo: activo.Titulo,
            DescripcionUbicacion: activo.DescripcionUbicacion,
            DireccionAnalitica: activo.DireccionAnalitica,
            Latitud: activo.Ubicacion.Y, 
            Longitud: activo.Ubicacion.X, 
            Version: activo.Version
        );
    }
}