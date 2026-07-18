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
        Task DeleteFoodPackageAsync(int hallId, int packageId, int actingUserId, UserRole actingRole);
        Task DeleteExtraServiceAsync(int hallId, int serviceId, int actingUserId, UserRole actingRole);
        Task<VirtualTourDto> AddVirtualTourAsync(int hallId, int actingUserId, UserRole actingRole, CreateVirtualTourDto dto);
        Task DeleteVirtualTourAsync(int hallId, int tourId, int actingUserId, UserRole actingRole);
    }
}
