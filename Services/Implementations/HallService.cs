using marriage_hall_backend.Data;
using marriage_hall_backend.DTOs.Halls;
using marriage_hall_backend.Helpers;
using marriage_hall_backend.Models.Entities;
using marriage_hall_backend.Models.Enums;
using marriage_hall_backend.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace marriage_hall_backend.Services.Implementations
{
    public class HallService : IHallService
    {
        private readonly AppDbContext _db;

        public HallService(AppDbContext db)
        {
            _db = db;
        }

        public async Task<List<HallListDto>> SearchAsync(string? city, int? minCapacity, decimal? maxPrice)
        {
            var query = _db.Halls.Where(h => h.IsActive).AsQueryable();

            if (!string.IsNullOrWhiteSpace(city))
                query = query.Where(h => h.City.Contains(city));
            if (minCapacity.HasValue)
                query = query.Where(h => h.Capacity >= minCapacity.Value);
            if (maxPrice.HasValue)
                query = query.Where(h => h.PricePerDay <= maxPrice.Value);

            var halls = await query.Include(h => h.Images).Include(h => h.Reviews).ToListAsync();
            return halls.Select(ProjectToListDto).ToList();
        }

        public async Task<HallDetailDto> GetByIdAsync(int hallId)
        {
            var hall = await _db.Halls
                .Include(h => h.Owner)
                .Include(h => h.Images)
                .Include(h => h.VirtualTours)
                .Include(h => h.FoodPackages)
                .Include(h => h.ExtraServices)
                .Include(h => h.Reviews)
                .SingleOrDefaultAsync(h => h.Id == hallId)
                ?? throw new NotFoundException("Hall not found.");

            return MapToDetail(hall);
        }

        public async Task<List<HallListDto>> GetByOwnerAsync(int ownerId)
        {
            var halls = await _db.Halls
                .Where(h => h.OwnerId == ownerId)
                .Include(h => h.Images)
                .Include(h => h.Reviews)
                .ToListAsync();

            return halls.Select(ProjectToListDto).ToList();
        }

        public async Task<HallDetailDto> CreateAsync(int ownerId, CreateHallDto dto)
        {
            var hall = new Hall
            {
                OwnerId = ownerId,
                Name = dto.Name,
                Description = dto.Description,
                Address = dto.Address,
                City = dto.City,
                Capacity = dto.Capacity,
                PricePerDay = dto.PricePerDay
            };

            _db.Halls.Add(hall);
            await _db.SaveChangesAsync();

            return await GetByIdAsync(hall.Id);
        }

        public async Task<HallDetailDto> UpdateAsync(int hallId, int actingUserId, UserRole actingRole, UpdateHallDto dto)
        {
            var hall = await _db.Halls.SingleOrDefaultAsync(h => h.Id == hallId)
                ?? throw new NotFoundException("Hall not found.");

            EnsureCanManage(hall, actingUserId, actingRole);

            hall.Name = dto.Name;
            hall.Description = dto.Description;
            hall.Address = dto.Address;
            hall.City = dto.City;
            hall.Capacity = dto.Capacity;
            hall.PricePerDay = dto.PricePerDay;
            hall.IsActive = dto.IsActive;
            hall.UpdatedAt = DateTime.UtcNow;

            await _db.SaveChangesAsync();

            return await GetByIdAsync(hall.Id);
        }

        public async Task DeleteAsync(int hallId, int actingUserId, UserRole actingRole)
        {
            var hall = await _db.Halls.SingleOrDefaultAsync(h => h.Id == hallId)
                ?? throw new NotFoundException("Hall not found.");

            EnsureCanManage(hall, actingUserId, actingRole);

            var hasBookings = await _db.Bookings.AnyAsync(b => b.HallId == hallId);
            if (hasBookings)
                throw new ConflictException("Cannot delete a hall that has bookings. Deactivate it instead.");

            _db.Halls.Remove(hall);
            await _db.SaveChangesAsync();
        }

        public async Task<HallImageDto> AddImageAsync(int hallId, int actingUserId, UserRole actingRole, CreateHallImageDto dto)
        {
            var hall = await GetHallForManagementAsync(hallId, actingUserId, actingRole);

            if (dto.IsPrimary)
                foreach (var img in hall.Images)
                    img.IsPrimary = false;

            var image = new HallImage { HallId = hallId, ImageUrl = dto.ImageUrl, IsPrimary = dto.IsPrimary };
            _db.HallImages.Add(image);
            await _db.SaveChangesAsync();

            return new HallImageDto { Id = image.Id, ImageUrl = image.ImageUrl, IsPrimary = image.IsPrimary };
        }

        public async Task<FoodPackageDto> AddFoodPackageAsync(int hallId, int actingUserId, UserRole actingRole, CreateFoodPackageDto dto)
        {
            await GetHallForManagementAsync(hallId, actingUserId, actingRole);

            var package = new FoodPackage { HallId = hallId, Name = dto.Name, Description = dto.Description, PricePerHead = dto.PricePerHead };
            _db.FoodPackages.Add(package);
            await _db.SaveChangesAsync();

            return new FoodPackageDto { Id = package.Id, Name = package.Name, Description = package.Description, PricePerHead = package.PricePerHead };
        }

        public async Task<ExtraServiceDto> AddExtraServiceAsync(int hallId, int actingUserId, UserRole actingRole, CreateExtraServiceDto dto)
        {
            await GetHallForManagementAsync(hallId, actingUserId, actingRole);

            var service = new ExtraService { HallId = hallId, Name = dto.Name, Description = dto.Description, Price = dto.Price };
            _db.ExtraServices.Add(service);
            await _db.SaveChangesAsync();

            return new ExtraServiceDto { Id = service.Id, Name = service.Name, Description = service.Description, Price = service.Price };
        }

        public async Task<VirtualTourDto> AddVirtualTourAsync(int hallId, int actingUserId, UserRole actingRole, CreateVirtualTourDto dto)
        {
            await GetHallForManagementAsync(hallId, actingUserId, actingRole);

            var tour = new VirtualTour { HallId = hallId, Title = dto.Title, TourUrl = dto.TourUrl };
            _db.VirtualTours.Add(tour);
            await _db.SaveChangesAsync();

            return new VirtualTourDto { Id = tour.Id, Title = tour.Title, TourUrl = tour.TourUrl };
        }

        private async Task<Hall> GetHallForManagementAsync(int hallId, int actingUserId, UserRole actingRole)
        {
            var hall = await _db.Halls.Include(h => h.Images).SingleOrDefaultAsync(h => h.Id == hallId)
                ?? throw new NotFoundException("Hall not found.");

            EnsureCanManage(hall, actingUserId, actingRole);
            return hall;
        }

        private static void EnsureCanManage(Hall hall, int actingUserId, UserRole actingRole)
        {
            if (actingRole != UserRole.Admin && hall.OwnerId != actingUserId)
                throw new ForbiddenException("You do not have permission to manage this hall.");
        }

        private static HallListDto ProjectToListDto(Hall h) => new()
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
        };

        private static HallDetailDto MapToDetail(Hall hall) => new()
        {
            Id = hall.Id,
            OwnerId = hall.OwnerId,
            OwnerName = hall.Owner.FullName,
            Name = hall.Name,
            Description = hall.Description,
            Address = hall.Address,
            City = hall.City,
            Capacity = hall.Capacity,
            PricePerDay = hall.PricePerDay,
            IsActive = hall.IsActive,
            AverageRating = hall.Reviews.Any() ? hall.Reviews.Average(r => r.Rating) : 0,
            ReviewCount = hall.Reviews.Count,
            Images = hall.Images.Select(i => new HallImageDto { Id = i.Id, ImageUrl = i.ImageUrl, IsPrimary = i.IsPrimary }).ToList(),
            VirtualTours = hall.VirtualTours.Select(t => new VirtualTourDto { Id = t.Id, Title = t.Title, TourUrl = t.TourUrl }).ToList(),
            FoodPackages = hall.FoodPackages.Select(f => new FoodPackageDto { Id = f.Id, Name = f.Name, Description = f.Description, PricePerHead = f.PricePerHead }).ToList(),
            ExtraServices = hall.ExtraServices.Select(e => new ExtraServiceDto { Id = e.Id, Name = e.Name, Description = e.Description, Price = e.Price }).ToList()
        };
    }
}
