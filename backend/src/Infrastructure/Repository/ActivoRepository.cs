using Domain.Entities;
using Domain.Interfaces;
using Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using NetTopologySuite.Geometries;

namespace Infrastructure.Repositories;

public class ActivoRepository : IActivoRepository
{
    private readonly AppDbContext _context;

    public ActivoRepository(AppDbContext context)
    {
        _context = context;
    }

    public async Task<List<Activo>> GetAllAsync()
    {
        return await _context.Activos.ToListAsync();
    }

    public async Task<Activo?> GetByIdAsync(int id)
    {
        return await _context.Activos.FindAsync(id);
    }

    public async Task<Activo> AddAsync(Activo activo)
    {
        await _context.Activos.AddAsync(activo);
        await _context.SaveChangesAsync();
        return activo;
    }

    public async Task<bool> UpdateAsync(Activo activo)
    {
        _context.Activos.Update(activo);
        try
        {
            await _context.SaveChangesAsync();
            return true;
        }
        catch (DbUpdateConcurrencyException)
        {
            return false;
        }
    }

    public async Task<bool> DeleteAsync(Activo activo)
    {
        _context.Activos.Remove(activo);
        try
        {
            await _context.SaveChangesAsync();
            return true;
        }
        catch (DbUpdateConcurrencyException)
        {
            return false;
        }
    }

    public async Task<List<Activo>> SearchAsync(string? query, double? lat, double? lng, double? radiusInMeters)
    {
        var sqlQuery = _context.Activos.AsQueryable();

        // Búsqueda por texto (Ilike) en Título y Ubicación descriptiva
        if (!string.IsNullOrWhiteSpace(query))
        {
            var cleanQuery = query.ToLower();
            sqlQuery = sqlQuery.Where(a => 
                EF.Functions.ILike(a.Titulo, $"%{cleanQuery}%") || 
                EF.Functions.ILike(a.DescripcionUbicacion, $"%{cleanQuery}%"));
        }

        // Búsqueda espacial por proximidad con ST_DWithin (geography)
        if (lat.HasValue && lng.HasValue && radiusInMeters.HasValue)
        {
            var geometryFactory = new GeometryFactory(new PrecisionModel(), 4326);
            var centerPoint = geometryFactory.CreatePoint(new Coordinate(lng.Value, lat.Value));

            sqlQuery = sqlQuery.Where(a => a.Ubicacion.IsWithinDistance(centerPoint, radiusInMeters.Value));
        }

        return await sqlQuery.ToListAsync();
    }
}