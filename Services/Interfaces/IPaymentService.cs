using marriage_hall_backend.DTOs.Payments;
using marriage_hall_backend.Models.Enums;

namespace marriage_hall_backend.Services.Interfaces
{
    public interface IPaymentService
    {
        Task<PaymentResponseDto> CreateAsync(int customerId, CreatePaymentDto dto);
        Task<List<PaymentResponseDto>> GetForBookingAsync(int bookingId, int actingUserId, UserRole actingRole);
        Task<PaymentResponseDto> UpdateStatusAsync(int paymentId, int actingUserId, UserRole actingRole, UpdatePaymentStatusDto dto);
    }
}
