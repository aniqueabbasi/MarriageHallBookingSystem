using marriage_hall_backend.Data;
using marriage_hall_backend.DTOs.Auth;
using marriage_hall_backend.DTOs.Users;
using marriage_hall_backend.Helpers;
using marriage_hall_backend.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace marriage_hall_backend.Services.Implementations
{
    public class UserService : IUserService
    {
        private readonly AppDbContext _db;

        public UserService(AppDbContext db)
        {
            _db = db;
        }

        public async Task<UserDto> GetMeAsync(int userId)
        {
            var user = await _db.Users.SingleOrDefaultAsync(u => u.Id == userId)
                ?? throw new NotFoundException("User not found.");

            return MapToDto(user);
        }

        public async Task<UserDto> UpdateMeAsync(int userId, UpdateProfileDto dto)
        {
            var user = await _db.Users.SingleOrDefaultAsync(u => u.Id == userId)
                ?? throw new NotFoundException("User not found.");

            var emailTaken = await _db.Users.AnyAsync(u => u.Email == dto.Email && u.Id != userId);
            if (emailTaken)
                throw new ConflictException("A user with this email already exists.");

            user.FullName = dto.FullName;
            user.Email = dto.Email;
            user.PhoneNumber = dto.PhoneNumber;
            user.City = dto.City;
            user.UpdatedAt = DateTime.UtcNow;

            await _db.SaveChangesAsync();

            return MapToDto(user);
        }

        private static UserDto MapToDto(Models.Entities.User user) => new()
        {
            Id = user.Id,
            FullName = user.FullName,
            Email = user.Email,
            PhoneNumber = user.PhoneNumber,
            City = user.City,
            Role = user.Role
        };
    }
}
