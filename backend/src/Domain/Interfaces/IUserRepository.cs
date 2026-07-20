using Domain.Entities;

namespace Domain.Interfaces;

public interface IUserRepository
{
    Task<Usuario?> GetByUsernameAsync(string username);
}
