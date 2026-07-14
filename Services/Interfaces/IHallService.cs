using marriage_hall_backend.DTOs.Halls;
using marriage_hall_backend.Models.Enums;

namespace marriage_hall_backend.Services.Interfaces
{
    public interface IHallService
    {
        Task<List<HallListDto>> SearchAsync(string? city, int? minCapacity, decimal? maxPrice);
        Task<HallDetailDto> GetByIdAsync(int hallId);
        Task<List<HallListDto>> GetByOwnerAsync(int ownerId);
        Task<HallDetailDto> CreateAsync(int ownerId, CreateHallDto dto);
        Task<HallDetailDto> UpdateAsync(int hallId, int actingUserId, UserRole actingRole, UpdateHallDto dto);
        Task DeleteAsync(int hallId, int actingUserId, UserRole actingRole);
        Task<HallImageDto> AddImageAsync(int hallId, int actingUserId, UserRole actingRole, CreateHallImageDto dto);
        Task<FoodPackageDto> AddFoodPackageAsync(int hallId, int actingUserId, UserRole actingRole, CreateFoodPackageDto dto);
        Task<ExtraServiceDto> AddExtraServiceAsync(int hallId, int actingUserId, UserRole actingRole, CreateExtraServiceDto dto);
        Task<VirtualTourDto> AddVirtualTourAsync(int hallId, int actingUserId, UserRole actingRole, CreateVirtualTourDto dto);
    }
}
