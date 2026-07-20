namespace Domain.Entities;

public class Poste : Activo
{
    public string Material { get; set; } = string.Empty;
    public double AlturaMetros { get; set; }
}