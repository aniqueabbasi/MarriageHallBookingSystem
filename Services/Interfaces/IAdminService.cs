using marriage_hall_backend.DTOs.Auth;
using marriage_hall_backend.DTOs.Bookings;
using marriage_hall_backend.DTOs.Halls;
using marriage_hall_backend.Models.Enums;

namespace marriage_hall_backend.Services.Interfaces
{
    public interface IAdminService
    {
        Task<List<UserDto>> GetAllUsersAsync();
        Task<UserDto> ChangeUserRoleAsync(int userId, UserRole newRole);
        Task<List<HallListDto>> GetAllHallsAsync();
        Task<List<BookingResponseDto>> GetAllBookingsAsync();
    }
}
