using Application.DTOs;
using FluentValidation;

namespace Application.Validators;

public class CreateActivoRequestValidator : AbstractValidator<CreateActivoRequest>
{
    public CreateActivoRequestValidator()
    {
        RuleFor(x => x.TipoActivo)
            .Must(t => t == "Poste" || t == "Medidor")
            .WithMessage("El tipo debe ser 'Poste' o 'Medidor'.");

        RuleFor(x => x.Titulo).NotEmpty().MaximumLength(100);
        
        // RuleFor(x => x.Latitud)
        //     .InclusiveBetween(-90, 90).WithMessage("Latitud inválida.");
            
        // RuleFor(x => x.Longitud)
        //     .InclusiveBetween(-180, 180).WithMessage("Longitud inválida.");
    }
}