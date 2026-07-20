using Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace Infrastructure.Persistence;

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

    public DbSet<Usuario> Usuarios { get; set; }
    public DbSet<Activo> Activos { get; set; }
    public DbSet<Poste> Postes { get; set; }
    public DbSet<Medidor> Medidores { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.Entity<Activo>(entity =>
        {
            // Estrategia TPH (Table-Per-Hierarchy) para herencia
            entity.UseTphMappingStrategy();

            // Configuración PostGIS para coordenadas geográficas reales
            entity.Property(e => e.Ubicacion)
                  .HasColumnType("geography (point)")
                  .HasDefaultValueSql("ST_SetSRID(ST_MakePoint(0, 0), 4326)");

            // Concurrencia optimista estándar (online simultáneo)
            entity.Property(e => e.Version).IsRowVersion();
        });
    }
}