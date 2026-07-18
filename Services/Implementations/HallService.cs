using System.ComponentModel.DataAnnotations;
using System.Text.Json;
using marriage_hall_backend.Data;
using marriage_hall_backend.DTOs.Halls;
using marriage_hall_backend.Helpers;
using marriage_hall_backend.Models.Entities;
using marriage_hall_backend.Models.Enums;
using marriage_hall_backend.Services.Interfaces;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;

namespace marriage_hall_backend.Services.Implementations
{
    public class HallService : IHallService
    {
        private const long MaxImageSizeBytes = 5 * 1024 * 1024;

        private static readonly Dictionary<string, string> AllowedImageExtensions = new()
        {
            ["image/jpeg"] = ".jpg",
            ["image/png"] = ".png",
            ["image/webp"] = ".webp"
        };

        private readonly AppDbContext _db;
        private readonly IWebHostEnvironment _env;

        public HallService(AppDbContext db, IWebHostEnvironment env)
        {
            _db = db;
            _env = env;
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
                .Include(h => h.VirtualTours.Where(t => t.IsActive))
                .Include(h => h.FoodPackages.Where(f => f.IsActive))
                .Include(h => h.ExtraServices.Where(e => e.IsActive))
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
            if (dto.Images is null || dto.Images.Count == 0)
                throw new BadRequestException("At least one image is required.");

            var extensions = ValidateImages(dto.Images);
            var foodPackages = ParseJsonArray<CreateFoodPackageDto>(dto.FoodPackages, "FoodPackages");
            var extraServices = ParseJsonArray<CreateExtraServiceDto>(dto.ExtraServices, "ExtraServices");

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

            await SaveImagesAsync(hall.Id, dto.Images, extensions, markFirstAsPrimary: true);

            foreach (var fp in foodPackages)
                _db.FoodPackages.Add(new FoodPackage { HallId = hall.Id, Name = fp.Name, Description = fp.Description, PricePerHead = fp.PricePerHead });

            foreach (var es in extraServices)
                _db.ExtraServices.Add(new ExtraService { HallId = hall.Id, Name = es.Name, Description = es.Description, Price = es.Price });

            await _db.SaveChangesAsync();

            return await GetByIdAsync(hall.Id);
        }

        private static string[] ValidateImages(List<IFormFile> images)
        {
            var extensions = new string[images.Count];
            for (var i = 0; i < images.Count; i++)
            {
                var image = images[i];
                if (image.Length == 0)
                    throw new BadRequestException("An uploaded image file is empty.");
                if (image.Length > MaxImageSizeBytes)
                    throw new BadRequestException("Each image must not exceed 5MB.");
                if (!AllowedImageExtensions.TryGetValue(image.ContentType, out var extension))
                    throw new BadRequestException("Only JPEG, PNG, and WEBP images are allowed.");

                extensions[i] = extension;
            }

            return extensions;
        }

        private async Task SaveImagesAsync(int hallId, List<IFormFile> images, string[] extensions, bool markFirstAsPrimary)
        {
            var uploadsDir = Path.Combine(_env.WebRootPath, "uploads", "halls");
            Directory.CreateDirectory(uploadsDir);

            for (var i = 0; i < images.Count; i++)
            {
                var fileName = $"{Guid.NewGuid():N}{extensions[i]}";
                await using (var stream = new FileStream(Path.Combine(uploadsDir, fileName), FileMode.Create))
                {
                    await images[i].CopyToAsync(stream);
                }

                _db.HallImages.Add(new HallImage { HallId = hallId, ImageUrl = $"/uploads/halls/{fileName}", IsPrimary = markFirstAsPrimary && i == 0 });
            }
        }

        private static List<T> ParseJsonArray<T>(string? json, string fieldName)
        {
            if (string.IsNullOrWhiteSpace(json))
                return new List<T>();

            List<T>? items;
            try
            {
                items = JsonSerializer.Deserialize<List<T>>(json, new JsonSerializerOptions { PropertyNameCaseInsensitive = true });
            }
            catch (JsonException)
            {
                throw new BadRequestException($"{fieldName} must be a valid JSON array, e.g. [{{\"name\":\"...\"}}].");
            }

            items ??= new List<T>();

            foreach (var item in items)
            {
                var results = new List<ValidationResult>();
                if (!Validator.TryValidateObject(item!, new ValidationContext(item!), results, validateAllProperties: true))
                    throw new BadRequestException($"Invalid {fieldName} entry: {results[0].ErrorMessage}");
            }

            return items;
        }

        public async Task<HallDetailDto> UpdateAsync(int hallId, int actingUserId, UserRole actingRole, UpdateHallDto dto)
        {
            var hall = await _db.Halls.SingleOrDefaultAsync(h => h.Id == hallId)
                ?? throw new NotFoundException("Hall not found.");

            EnsureCanManage(hall, actingUserId, actingRole);

            var extensions = ValidateImages(dto.Images);
            var foodPackages = ParseJsonArray<CreateFoodPackageDto>(dto.FoodPackages, "FoodPackages");
            var extraServices = ParseJsonArray<CreateExtraServiceDto>(dto.ExtraServices, "ExtraServices");

            hall.Name = dto.Name;
            hall.Description = dto.Description;
            hall.Address = dto.Address;
            hall.City = dto.City;
            hall.Capacity = dto.Capacity;
            hall.PricePerDay = dto.PricePerDay;
            hall.IsActive = dto.IsActive;
            hall.UpdatedAt = DateTime.UtcNow;

            var existingFoodPackages = await _db.FoodPackages.Where(f => f.HallId == hallId && f.IsActive).ToListAsync();
            foreach (var existing in existingFoodPackages)
                existing.IsActive = false;

            foreach (var fp in foodPackages)
                _db.FoodPackages.Add(new FoodPackage { HallId = hallId, Name = fp.Name, Description = fp.Description, PricePerHead = fp.PricePerHead });

            var existingExtraServices = await _db.ExtraServices.Where(e => e.HallId == hallId && e.IsActive).ToListAsync();
            foreach (var existing in existingExtraServices)
                existing.IsActive = false;

            foreach (var es in extraServices)
                _db.ExtraServices.Add(new ExtraService { HallId = hallId, Name = es.Name, Description = es.Description, Price = es.Price });

            if (dto.Images.Count > 0)
                await SaveImagesAsync(hallId, dto.Images, extensions, markFirstAsPrimary: false);

            await _db.SaveChangesAsync();
            _db.ChangeTracker.Clear();

            return await GetByIdAsync(hallId);
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

        public async Task DeleteFoodPackageAsync(int hallId, int packageId, int actingUserId, UserRole actingRole)
        {
            var hall = await _db.Halls.SingleOrDefaultAsync(h => h.Id == hallId)
                ?? throw new NotFoundException("Hall not found.");

            EnsureCanManage(hall, actingUserId, actingRole);

            var package = await _db.FoodPackages.SingleOrDefaultAsync(f => f.Id == packageId && f.HallId == hallId)
                ?? throw new NotFoundException("Food package not found.");

            package.IsActive = false;
            await _db.SaveChangesAsync();
        }

        public async Task DeleteExtraServiceAsync(int hallId, int serviceId, int actingUserId, UserRole actingRole)
        {
            var hall = await _db.Halls.SingleOrDefaultAsync(h => h.Id == hallId)
                ?? throw new NotFoundException("Hall not found.");

            EnsureCanManage(hall, actingUserId, actingRole);

            var service = await _db.ExtraServices.SingleOrDefaultAsync(e => e.Id == serviceId && e.HallId == hallId)
                ?? throw new NotFoundException("Extra service not found.");

            service.IsActive = false;
            await _db.SaveChangesAsync();
        }

        public async Task<VirtualTourDto> AddVirtualTourAsync(int hallId, int actingUserId, UserRole actingRole, CreateVirtualTourDto dto)
        {
            await GetHallForManagementAsync(hallId, actingUserId, actingRole);

            var tour = new VirtualTour { HallId = hallId, Title = dto.Title, TourUrl = dto.TourUrl };
            _db.VirtualTours.Add(tour);
            await _db.SaveChangesAsync();

            return new VirtualTourDto { Id = tour.Id, Title = tour.Title, TourUrl = tour.TourUrl };
        }

        public async Task DeleteVirtualTourAsync(int hallId, int tourId, int actingUserId, UserRole actingRole)
        {
            var hall = await _db.Halls.SingleOrDefaultAsync(h => h.Id == hallId)
                ?? throw new NotFoundException("Hall not found.");

            EnsureCanManage(hall, actingUserId, actingRole);

            var tour = await _db.VirtualTours.SingleOrDefaultAsync(t => t.Id == tourId && t.HallId == hallId)
                ?? throw new NotFoundException("Virtual tour not found.");

            tour.IsActive = false;
            await _db.SaveChangesAsync();
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
