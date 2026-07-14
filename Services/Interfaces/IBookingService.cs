using marriage_hall_backend.DTOs.Bookings;
using marriage_hall_backend.Models.Enums;

namespace marriage_hall_backend.Services.Interfaces
{
    public interface IBookingService
    {
        Task<BookingResponseDto> CreateAsync(int customerId, CreateBookingDto dto);
        Task<BookingResponseDto> GetByIdAsync(int bookingId, int actingUserId, UserRole actingRole);
        Task<List<BookingResponseDto>> GetForCustomerAsync(int customerId);
        Task<List<BookingResponseDto>> GetForHallOwnerAsync(int ownerId);
        Task<BookingResponseDto> UpdateStatusAsync(int bookingId, int actingUserId, UserRole actingRole, UpdateBookingStatusDto dto);
    }
}
