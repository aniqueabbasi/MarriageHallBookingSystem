using marriage_hall_backend.Data;
using marriage_hall_backend.DTOs.Payments;
using marriage_hall_backend.Helpers;
using marriage_hall_backend.Models.Entities;
using marriage_hall_backend.Models.Enums;
using marriage_hall_backend.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace marriage_hall_backend.Services.Implementations
{
    public class PaymentService : IPaymentService
    {
        private readonly AppDbContext _db;
        private readonly INotificationService _notificationService;

        public PaymentService(AppDbContext db, INotificationService notificationService)
        {
            _db = db;
            _notificationService = notificationService;
        }

        public async Task<PaymentResponseDto> CreateAsync(int customerId, CreatePaymentDto dto)
        {
            var booking = await _db.Bookings.Include(b => b.Hall).SingleOrDefaultAsync(b => b.Id == dto.BookingId)
                ?? throw new NotFoundException("Booking not found.");

            if (booking.UserId != customerId)
                throw new ForbiddenException("You can only submit payments for your own bookings.");

            if (booking.Status is BookingStatus.Cancelled or BookingStatus.Rejected)
                throw new BadRequestException("Cannot submit a payment for a cancelled or rejected booking.");

            var payment = new Payment
            {
                BookingId = dto.BookingId,
                Amount = dto.Amount,
                Method = dto.Method,
                TransactionId = dto.TransactionId,
                Status = PaymentStatus.Pending
            };

            _db.Payments.Add(payment);
            await _db.SaveChangesAsync();

            await _notificationService.CreateAsync(booking.Hall.OwnerId, NotificationType.PaymentReceived,
                "Payment submitted",
                $"A payment of {dto.Amount:0.00} was submitted for the booking at \"{booking.Hall.Name}\" on {booking.EventDate:yyyy-MM-dd}. Please verify.");

            return MapToResponse(payment);
        }

        public async Task<List<PaymentResponseDto>> GetForBookingAsync(int bookingId, int actingUserId, UserRole actingRole)
        {
            var booking = await _db.Bookings.Include(b => b.Hall).SingleOrDefaultAsync(b => b.Id == bookingId)
                ?? throw new NotFoundException("Booking not found.");

            if (actingRole != UserRole.Admin && booking.UserId != actingUserId && booking.Hall.OwnerId != actingUserId)
                throw new ForbiddenException("You do not have permission to view payments for this booking.");

            var payments = await _db.Payments.Where(p => p.BookingId == bookingId).ToListAsync();
            return payments.Select(MapToResponse).ToList();
        }

        public async Task<PaymentResponseDto> UpdateStatusAsync(int paymentId, int actingUserId, UserRole actingRole, UpdatePaymentStatusDto dto)
        {
            var payment = await _db.Payments
                .Include(p => p.Booking).ThenInclude(b => b.Hall)
                .SingleOrDefaultAsync(p => p.Id == paymentId)
                ?? throw new NotFoundException("Payment not found.");

            if (actingRole != UserRole.Admin && payment.Booking.Hall.OwnerId != actingUserId)
                throw new ForbiddenException("Only the hall owner or an admin can verify this payment.");

            payment.Status = dto.Status;
            payment.PaidAt = dto.Status == PaymentStatus.Completed ? DateTime.UtcNow : payment.PaidAt;
            await _db.SaveChangesAsync();

            await _notificationService.CreateAsync(payment.Booking.UserId, NotificationType.PaymentReceived,
                $"Payment {dto.Status}",
                $"Your payment for the booking at \"{payment.Booking.Hall.Name}\" is now marked as {dto.Status}.");

            return MapToResponse(payment);
        }

        private static PaymentResponseDto MapToResponse(Payment payment) => new()
        {
            Id = payment.Id,
            BookingId = payment.BookingId,
            Amount = payment.Amount,
            Method = payment.Method,
            Status = payment.Status,
            TransactionId = payment.TransactionId,
            PaidAt = payment.PaidAt,
            CreatedAt = payment.CreatedAt
        };
    }
}
