using Application.Common;
using Application.DTOs;

namespace Application.Interfaces;

public interface IActivoService
{
    Task<List<ActivoResponse>> GetAllAsync();
    Task<ActivoResponse?> GetByIdAsync(int id);
    Task<ActivoResponse> CreateAsync(CreateActivoRequest request);
    Task<OperationResult> UpdateAsync(int id, UpdateActivoRequest request);
    Task<OperationResult> DeleteAsync(int id);
    Task<List<ActivoResponse>> SearchAsync(string? query, double? lat, double? lng, double? radiusInMeters);
}