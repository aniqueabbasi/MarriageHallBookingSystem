using marriage_hall_backend.Data;
using marriage_hall_backend.DTOs.Reviews;
using marriage_hall_backend.Helpers;
using marriage_hall_backend.Models.Entities;
using marriage_hall_backend.Models.Enums;
using marriage_hall_backend.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace marriage_hall_backend.Services.Implementations
{
    public class ReviewService : IReviewService
    {
        private readonly AppDbContext _db;

        public ReviewService(AppDbContext db)
        {
            _db = db;
        }

        public async Task<ReviewResponseDto> CreateAsync(int customerId, CreateReviewDto dto)
        {
            var booking = await _db.Bookings.SingleOrDefaultAsync(b => b.Id == dto.BookingId)
                ?? throw new NotFoundException("Booking not found.");

            if (booking.UserId != customerId)
                throw new ForbiddenException("You can only review your own bookings.");

            if (booking.Status != BookingStatus.Completed)
                throw new BadRequestException("You can only review a booking after the event is completed.");

            var alreadyReviewed = await _db.Reviews.AnyAsync(r => r.BookingId == dto.BookingId);
            if (alreadyReviewed)
                throw new ConflictException("You have already reviewed this booking.");

            var review = new Review
            {
                UserId = customerId,
                HallId = booking.HallId,
                BookingId = booking.Id,
                Rating = dto.Rating,
                Comment = dto.Comment
            };

            _db.Reviews.Add(review);
            await _db.SaveChangesAsync();

            var user = await _db.Users.SingleAsync(u => u.Id == customerId);
            return new ReviewResponseDto
            {
                Id = review.Id,
                HallId = review.HallId,
                UserId = review.UserId,
                CustomerName = user.FullName,
                Rating = review.Rating,
                Comment = review.Comment,
                CreatedAt = review.CreatedAt
            };
        }

        public async Task<List<ReviewResponseDto>> GetForHallAsync(int hallId)
        {
            return await _db.Reviews
                .Where(r => r.HallId == hallId)
                .Include(r => r.User)
                .Select(r => new ReviewResponseDto
                {
                    Id = r.Id,
                    HallId = r.HallId,
                    UserId = r.UserId,
                    CustomerName = r.User.FullName,
                    Rating = r.Rating,
                    Comment = r.Comment,
                    CreatedAt = r.CreatedAt
                })
                .ToListAsync();
        }
    }
}
