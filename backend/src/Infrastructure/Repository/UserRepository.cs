using Domain.Entities;
using Domain.Interfaces;
using Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace Infrastructure.Repository;

public class UserRepository : IUserRepository
{
    private readonly AppDbContext _context;
    public UserRepository(AppDbContext context) => _context = context;

    public async Task<Usuario?> GetByUsernameAsync(string username) 
        => await _context.Usuarios.FirstOrDefaultAsync(u => u.Username == username);
}