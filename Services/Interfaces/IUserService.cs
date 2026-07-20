using marriage_hall_backend.DTOs.Auth;
using marriage_hall_backend.DTOs.Users;

namespace marriage_hall_backend.Services.Interfaces
{
    public interface IUserService
    {
        Task<UserDto> GetMeAsync(int userId);
        Task<UserDto> UpdateMeAsync(int userId, UpdateProfileDto dto);
    }
}
