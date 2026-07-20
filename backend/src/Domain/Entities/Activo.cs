using NetTopologySuite.Geometries;

namespace Domain.Entities;

public abstract class Activo
{
    public int Id { get; set; }
    public string Titulo { get; set; } = string.Empty;
    public string DescripcionUbicacion { get; set; } = string.Empty;
    public string DireccionAnalitica { get; set; } = string.Empty;
    public Point Ubicacion { get; set; } = null!; // PostGIS Point
    public int CreadoPorId { get; set; }
    public int ActualizadoPorId { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

    public uint Version { get; set; }
}