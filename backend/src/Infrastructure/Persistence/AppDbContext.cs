using Microsoft.EntityFrameworkCore;

namespace Infrastructure.Persistence
{
    public class AppDbContext(DbContextOptions<AppDbContext> options) : DbContext(options)
    {
        public DbSet<Activo> Activos { get; set; }
        public DbSet<Usuario> Usuarios { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Configuración TPH (Table Per Hierarchy)
            _ = modelBuilder.Entity<Activo>()
                .HasDiscriminator<string>("TipoActivo")
                .HasValue<Poste>("Poste")
                .HasValue<Medidor>("Medidor");

            // Índice espacial GIST para la columna Ubicacion
            _ = modelBuilder.Entity<Activo>()
                .HasIndex(a => a.Ubicacion)
                .HasMethod("GIST");

            // Concurrencia optimista
            _ = modelBuilder.Entity<Activo>()
                .Property(a => a.Version)
                .IsRowVersion();
        }
    }
}