using marriage_hall_backend.Data;
using marriage_hall_backend.DTOs.Bookings;
using marriage_hall_backend.Helpers;
using marriage_hall_backend.Models.Entities;
using marriage_hall_backend.Models.Enums;
using marriage_hall_backend.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace marriage_hall_backend.Services.Implementations
{
    public class BookingService : IBookingService
    {
        private static readonly Dictionary<BookingStatus, BookingStatus[]> AllowedTransitions = new()
        {
            [BookingStatus.Pending] = new[] { BookingStatus.Confirmed, BookingStatus.Rejected, BookingStatus.Cancelled },
            [BookingStatus.Confirmed] = new[] { BookingStatus.Completed, BookingStatus.Cancelled },
            [BookingStatus.Completed] = Array.Empty<BookingStatus>(),
            [BookingStatus.Cancelled] = Array.Empty<BookingStatus>(),
            [BookingStatus.Rejected] = Array.Empty<BookingStatus>()
        };

        private readonly AppDbContext _db;
        private readonly INotificationService _notificationService;

        public BookingService(AppDbContext db, INotificationService notificationService)
        {
            _db = db;
            _notificationService = notificationService;
        }

        public async Task<BookingResponseDto> CreateAsync(int customerId, CreateBookingDto dto)
        {
            if (dto.EndTime <= dto.StartTime)
                throw new BadRequestException("End time must be after start time.");
            if (dto.EventDate < DateOnly.FromDateTime(DateTime.UtcNow))
                throw new BadRequestException("Event date cannot be in the past.");

            var hall = await _db.Halls.SingleOrDefaultAsync(h => h.Id == dto.HallId && h.IsActive)
                ?? throw new NotFoundException("Hall not found or is not active.");

            FoodPackage? foodPackage = null;
            if (dto.FoodPackageId.HasValue)
            {
                foodPackage = await _db.FoodPackages.SingleOrDefaultAsync(f => f.Id == dto.FoodPackageId && f.HallId == dto.HallId)
                    ?? throw new BadRequestException("Selected food package does not belong to this hall.");

                if (!foodPackage.IsActive)
                    throw new BadRequestException("This food package is no longer offered. Please refresh and select again.");
            }

            var distinctExtraServiceIds = dto.ExtraServiceIds.Distinct().ToList();
            var extraServices = await _db.ExtraServices
                .Where(e => distinctExtraServiceIds.Contains(e.Id) && e.HallId == dto.HallId)
                .ToListAsync();
            if (extraServices.Count != distinctExtraServiceIds.Count)
                throw new BadRequestException("One or more selected extra services do not belong to this hall.");

            if (extraServices.Any(e => !e.IsActive))
                throw new BadRequestException("This extra service is no longer offered. Please refresh and select again.");

            var hasConflict = await _db.Bookings.AnyAsync(b =>
                b.HallId == dto.HallId &&
                b.EventDate == dto.EventDate &&
                b.Status != BookingStatus.Cancelled && b.Status != BookingStatus.Rejected &&
                b.StartTime < dto.EndTime && b.EndTime > dto.StartTime);
            if (hasConflict)
                throw new ConflictException("This hall is already booked for the selected date and time.");

            var totalAmount = hall.PricePerDay
                + (foodPackage?.PricePerHead * dto.GuestCount ?? 0)
                + extraServices.Sum(e => e.Price);

            var booking = new Booking
            {
                UserId = customerId,
                HallId = dto.HallId,
                FoodPackageId = dto.FoodPackageId,
                EventDate = dto.EventDate,
                StartTime = dto.StartTime,
                EndTime = dto.EndTime,
                GuestCount = dto.GuestCount,
                Status = BookingStatus.Pending,
                TotalAmount = totalAmount,
                AdvanceAmount = 0
            };

            foreach (var extra in extraServices)
                booking.ExtraServices.Add(new BookingExtraService { ExtraService = extra, Price = extra.Price });

            _db.Bookings.Add(booking);
            await _db.SaveChangesAsync();

            await _notificationService.CreateAsync(hall.OwnerId, NotificationType.BookingRequested,
                "New booking request",
                $"A new booking request was submitted for \"{hall.Name}\" on {dto.EventDate:yyyy-MM-dd}.");

            return await GetByIdAsync(booking.Id, customerId, UserRole.Customer);
        }

        public async Task<BookingResponseDto> GetByIdAsync(int bookingId, int actingUserId, UserRole actingRole)
        {
            var booking = await LoadBookingAsync(bookingId);
            EnsureCanView(booking, actingUserId, actingRole);
            return MapToResponse(booking);
        }

        public async Task<List<BookingResponseDto>> GetForCustomerAsync(int customerId)
        {
            var bookings = await QueryWithIncludes().Where(b => b.UserId == customerId).ToListAsync();
            return bookings.Select(MapToResponse).ToList();
        }

        public async Task<List<BookingResponseDto>> GetForHallOwnerAsync(int ownerId)
        {
            var bookings = await QueryWithIncludes().Where(b => b.Hall.OwnerId == ownerId).ToListAsync();
            return bookings.Select(MapToResponse).ToList();
        }

        public async Task<BookingResponseDto> UpdateStatusAsync(int bookingId, int actingUserId, UserRole actingRole, UpdateBookingStatusDto dto)
        {
            var booking = await LoadBookingAsync(bookingId);

            var isOwnerOrAdmin = actingRole == UserRole.Admin || booking.Hall.OwnerId == actingUserId;
            var isCustomer = booking.UserId == actingUserId;

            if (dto.Status == BookingStatus.Cancelled)
            {
                if (!isOwnerOrAdmin && !isCustomer)
                    throw new ForbiddenException("You do not have permission to cancel this booking.");
            }
            else if (!isOwnerOrAdmin)
            {
                throw new ForbiddenException("Only the hall owner or an admin can change this booking's status.");
            }

            if (!AllowedTransitions.TryGetValue(booking.Status, out var allowed) || !allowed.Contains(dto.Status))
                throw new BadRequestException($"Cannot move a booking from {booking.Status} to {dto.Status}.");

            if (dto.Status == BookingStatus.Confirmed)
            {
                if (!dto.AdvanceAmount.HasValue || dto.AdvanceAmount <= 0 || dto.AdvanceAmount > booking.TotalAmount)
                    throw new BadRequestException("A valid advance amount (greater than 0 and no more than the total) is required to confirm a booking.");

                booking.AdvanceAmount = dto.AdvanceAmount.Value;
            }

            booking.Status = dto.Status;
            booking.UpdatedAt = DateTime.UtcNow;
            await _db.SaveChangesAsync();

            var notificationType = dto.Status switch
            {
                BookingStatus.Confirmed => NotificationType.BookingConfirmed,
                BookingStatus.Rejected => NotificationType.BookingRejected,
                BookingStatus.Cancelled => NotificationType.BookingCancelled,
                _ => NotificationType.General
            };

            await _notificationService.CreateAsync(booking.UserId, notificationType,
                $"Booking {dto.Status}",
                $"Your booking for \"{booking.Hall.Name}\" on {booking.EventDate:yyyy-MM-dd} is now {dto.Status}.");

            return MapToResponse(booking);
        }

        private IQueryable<Booking> QueryWithIncludes()
        {
            return _db.Bookings
                .Include(b => b.Hall)
                .Include(b => b.User)
                .Include(b => b.FoodPackage)
                .Include(b => b.ExtraServices).ThenInclude(x => x.ExtraService)
                .Include(b => b.Payments);
        }

        private async Task<Booking> LoadBookingAsync(int bookingId)
        {
            return await QueryWithIncludes().SingleOrDefaultAsync(b => b.Id == bookingId)
                ?? throw new NotFoundException("Booking not found.");
        }

        private static void EnsureCanView(Booking booking, int actingUserId, UserRole actingRole)
        {
            if (actingRole == UserRole.Admin) return;
            if (booking.UserId == actingUserId) return;
            if (booking.Hall.OwnerId == actingUserId) return;
            throw new ForbiddenException("You do not have permission to view this booking.");
        }

        private static BookingResponseDto MapToResponse(Booking booking) => new()
        {
            Id = booking.Id,
            HallId = booking.HallId,
            HallName = booking.Hall.Name,
            UserId = booking.UserId,
            CustomerName = booking.User.FullName,
            EventDate = booking.EventDate,
            StartTime = booking.StartTime,
            EndTime = booking.EndTime,
            GuestCount = booking.GuestCount,
            Status = booking.Status,
            TotalAmount = booking.TotalAmount,
            AdvanceAmount = booking.AdvanceAmount,
            AmountPaid = booking.Payments.Where(p => p.Status == PaymentStatus.Completed).Sum(p => p.Amount),
            FoodPackageName = booking.FoodPackage?.Name,
            ExtraServiceNames = booking.ExtraServices.Select(x => x.ExtraService.Name).ToList(),
            CreatedAt = booking.CreatedAt
        };
    }
}
