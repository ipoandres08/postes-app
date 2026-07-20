using Application.Common;
using Application.DTOs;
using Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Api.Controllers;

[Authorize]
[ApiController]
[Route("api/[controller]")]
public class ActivosController : ControllerBase
{
    private readonly IActivoService _activoService;

    public ActivosController(IActivoService activoService)
    {
        _activoService = activoService;
    }

    [HttpGet]
    public async Task<ActionResult<List<ActivoResponse>>> GetAll()
    {
        var activos = await _activoService.GetAllAsync();
        return Ok(activos);
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<ActivoResponse>> GetById(int id)
    {
        var activo = await _activoService.GetByIdAsync(id);
        if (activo == null) return NotFound(new { message = $"El activo con ID {id} no existe." });
        return Ok(activo);
    }

    [HttpGet("buscar")]
    public async Task<ActionResult<List<ActivoResponse>>> Search(
        [FromQuery] string? texto,
        [FromQuery] double? lat,
        [FromQuery] double? lng,
        [FromQuery] double? radio)
    {
        var resultados = await _activoService.SearchAsync(texto, lat, lng, radio);
        return Ok(resultados);
    }

    [HttpPost]
    public async Task<ActionResult<ActivoResponse>> Create([FromBody] CreateActivoRequest request)
    {
        try
        {
            var result = await _activoService.CreateAsync(request);
            return CreatedAtAction(nameof(GetById), new { id = result.Id }, result);
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> Update(int id, [FromBody] UpdateActivoRequest request)
    {
        var result = await _activoService.UpdateAsync(id, request);

        return result switch
        {
            OperationResult.Success => NoContent(),
            OperationResult.NotFound => NotFound(new { message = $"El activo con ID {id} no existe." }),
            OperationResult.Conflict => Conflict(new { message = "Conflicto de concurrencia: el activo fue modificado por otro usuario de forma simultánea." }),
            _ => StatusCode(500)
        };
    }

    // ⛔ Solo Administradores pueden borrar activos (RBAC estricto online)
    [Authorize(Policy = "AdminOnly")] 
    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(int id)
    {
        var result = await _activoService.DeleteAsync(id);

        return result switch
        {
            OperationResult.Success => NoContent(),
            OperationResult.NotFound => NotFound(new { message = $"El activo con ID {id} no existe." }),
            OperationResult.Conflict => Conflict(new { message = "No se pudo eliminar el activo debido a un conflicto de concurrencia." }),
            _ => StatusCode(500)
        };
    }
}