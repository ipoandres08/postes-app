using Domain.Entities;
using Microsoft.EntityFrameworkCore;
using NetTopologySuite.Geometries;

namespace Infrastructure.Persistence;

public static class DbInitializer
{
    public static async Task SeedAsync(AppDbContext context)
    {
        // 1. Asegurar que la BD esté creada y migrada
        await context.Database.MigrateAsync();

        // 2. Semilla de Usuarios (Admin, Tecnico, Jefe)
        if (!await context.Usuarios.AnyAsync())
        {
            var usuarios = new List<Usuario>
            {
                new()
                {
                    Username = "admin",
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword("admin123"),
                    Role = "Administrador" // Permisos totales
                },
                new()
                {
                    Username = "tecnico",
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword("tecnico123"),
                    Role = "Tecnico" // Permiso de lectura/escritura, no borrado
                },
                new()
                {
                    Username = "jefe",
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword("jefe123"),
                    Role = "Administrador" // El jefe hereda políticas de Admin
                }
            };

            await context.Usuarios.AddRangeAsync(usuarios);
            await context.SaveChangesAsync();
        }

        // 3. Semilla de Activos de Prueba (Con coordenadas reales)
        if (!await context.Activos.AnyAsync())
        {
            var geometryFactory = new GeometryFactory(new PrecisionModel(), 4326);
            var adminUser = await context.Usuarios.FirstAsync(u => u.Role == "Administrador");

            var activos = new List<Activo>
            {
                new Poste
                {
                    Titulo = "Poste Eléctrico H-104",
                    DescripcionUbicacion = "Cerca de la plaza principal, acera oeste",
                    DireccionAnalitica = "Av. de la Cultura #450",
                    Ubicacion = geometryFactory.CreatePoint(new Coordinate(-66.1568, -17.3895)), // Longitud, Latitud (WGS84)
                    CreadoPorId = adminUser.Id,
                    ActualizadoPorId = adminUser.Id,
                    Material = "Concreto Reforzado",
                    AlturaMetros = 12.0,
                    CreatedAt = DateTime.UtcNow,
                    UpdatedAt = DateTime.UtcNow
                },
                new Medidor
                {
                    Titulo = "Medidor Residencial M-099",
                    DescripcionUbicacion = "Frente a casa de fachada amarilla",
                    DireccionAnalitica = "Calle Los Álamos #120",
                    Ubicacion = geometryFactory.CreatePoint(new Coordinate(-66.1582, -17.3912)),
                    CreadoPorId = adminUser.Id,
                    ActualizadoPorId = adminUser.Id,
                    NumeroSerie = "MED-2026-X89",
                    CreatedAt = DateTime.UtcNow,
                    UpdatedAt = DateTime.UtcNow
                }
            };

            await context.Activos.AddRangeAsync(activos);
            await context.SaveChangesAsync();
        }
    }
}