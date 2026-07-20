using Domain.Entities;

namespace Domain.Interfaces;

public interface IActivoRepository
{
    Task<List<Activo>> GetAllAsync();
    Task<Activo?> GetByIdAsync(int id);
    Task<Activo> AddAsync(Activo activo);
    Task<bool> UpdateAsync(Activo activo);
    Task<bool> DeleteAsync(Activo activo);
    Task<List<Activo>> SearchAsync(string? query, double? lat, double? lng, double? radiusInMeters);
}