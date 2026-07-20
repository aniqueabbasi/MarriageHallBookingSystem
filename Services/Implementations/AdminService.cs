using marriage_hall_backend.Data;
using marriage_hall_backend.DTOs.Auth;
using marriage_hall_backend.DTOs.Bookings;
using marriage_hall_backend.DTOs.Halls;
using marriage_hall_backend.Helpers;
using marriage_hall_backend.Models.Enums;
using marriage_hall_backend.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace marriage_hall_backend.Services.Implementations
{
    public class AdminService : IAdminService
    {
        private readonly AppDbContext _db;

        public AdminService(AppDbContext db)
        {
            _db = db;
        }

        public async Task<List<UserDto>> GetAllUsersAsync()
        {
            return await _db.Users
                .Select(u => new UserDto { Id = u.Id, FullName = u.FullName, Email = u.Email, PhoneNumber = u.PhoneNumber, City = u.City, Role = u.Role })
                .ToListAsync();
        }

        public async Task<UserDto> ChangeUserRoleAsync(int userId, UserRole newRole)
        {
            var user = await _db.Users.SingleOrDefaultAsync(u => u.Id == userId)
                ?? throw new NotFoundException("User not found.");

            user.Role = newRole;
            user.UpdatedAt = DateTime.UtcNow;
            await _db.SaveChangesAsync();

            return new UserDto { Id = user.Id, FullName = user.FullName, Email = user.Email, PhoneNumber = user.PhoneNumber, City = user.City, Role = user.Role };
        }

        public async Task<List<HallListDto>> GetAllHallsAsync()
        {
            return await _db.Halls
                .Select(h => new HallListDto
                {
                    Id = h.Id,
                    Name = h.Name,
                    City = h.City,
                    Capacity = h.Capacity,
                    PricePerDay = h.PricePerDay,
                    IsActive = h.IsActive,
                    PrimaryImageUrl = h.Images.Where(i => i.IsPrimary).Select(i => i.ImageUrl).FirstOrDefault(),
                    AverageRating = h.Reviews.Any() ? h.Reviews.Average(r => r.Rating) : 0,
                    ReviewCount = h.Reviews.Count
                })
                .ToListAsync();
        }

        public async Task<List<BookingResponseDto>> GetAllBookingsAsync()
        {
            var bookings = await _db.Bookings
                .Include(b => b.Hall)
                .Include(b => b.User)
                .Include(b => b.FoodPackage)
                .Include(b => b.ExtraServices).ThenInclude(x => x.ExtraService)
                .Include(b => b.Payments)
                .ToListAsync();

            return bookings.Select(b => new BookingResponseDto
            {
                Id = b.Id,
                HallId = b.HallId,
                HallName = b.Hall.Name,
                UserId = b.UserId,
                CustomerName = b.User.FullName,
                EventDate = b.EventDate,
                StartTime = b.StartTime,
                EndTime = b.EndTime,
                GuestCount = b.GuestCount,
                Status = b.Status,
                TotalAmount = b.TotalAmount,
                AdvanceAmount = b.AdvanceAmount,
                AmountPaid = b.Payments.Where(p => p.Status == PaymentStatus.Completed).Sum(p => p.Amount),
                FoodPackageName = b.FoodPackage?.Name,
                ExtraServiceNames = b.ExtraServices.Select(x => x.ExtraService.Name).ToList(),
                CreatedAt = b.CreatedAt
            }).ToList();
        }
    }
}
