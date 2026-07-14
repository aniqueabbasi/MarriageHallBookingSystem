using marriage_hall_backend.Data;
using marriage_hall_backend.DTOs.Favorites;
using marriage_hall_backend.Helpers;
using marriage_hall_backend.Models.Entities;
using marriage_hall_backend.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace marriage_hall_backend.Services.Implementations
{
    public class FavoriteService : IFavoriteService
    {
        private readonly AppDbContext _db;

        public FavoriteService(AppDbContext db)
        {
            _db = db;
        }

        public async Task<FavoriteResponseDto> AddAsync(int customerId, int hallId)
        {
            var hall = await _db.Halls.SingleOrDefaultAsync(h => h.Id == hallId)
                ?? throw new NotFoundException("Hall not found.");

            var existing = await _db.Favorites.AnyAsync(f => f.UserId == customerId && f.HallId == hallId);
            if (existing)
                throw new ConflictException("This hall is already in your favorites.");

            var favorite = new Favorite { UserId = customerId, HallId = hallId };
            _db.Favorites.Add(favorite);
            await _db.SaveChangesAsync();

            var primaryImage = await _db.HallImages
                .Where(i => i.HallId == hallId && i.IsPrimary)
                .Select(i => i.ImageUrl)
                .FirstOrDefaultAsync();

            return new FavoriteResponseDto
            {
                Id = favorite.Id,
                HallId = hall.Id,
                HallName = hall.Name,
                City = hall.City,
                PricePerDay = hall.PricePerDay,
                PrimaryImageUrl = primaryImage,
                CreatedAt = favorite.CreatedAt
            };
        }

        public async Task RemoveAsync(int customerId, int hallId)
        {
            var favorite = await _db.Favorites.SingleOrDefaultAsync(f => f.UserId == customerId && f.HallId == hallId)
                ?? throw new NotFoundException("Favorite not found.");

            _db.Favorites.Remove(favorite);
            await _db.SaveChangesAsync();
        }

        public async Task<List<FavoriteResponseDto>> GetForUserAsync(int customerId)
        {
            return await _db.Favorites
                .Where(f => f.UserId == customerId)
                .Include(f => f.Hall).ThenInclude(h => h.Images)
                .Select(f => new FavoriteResponseDto
                {
                    Id = f.Id,
                    HallId = f.HallId,
                    HallName = f.Hall.Name,
                    City = f.Hall.City,
                    PricePerDay = f.Hall.PricePerDay,
                    PrimaryImageUrl = f.Hall.Images.Where(i => i.IsPrimary).Select(i => i.ImageUrl).FirstOrDefault(),
                    CreatedAt = f.CreatedAt
                })
                .ToListAsync();
        }
    }
}
