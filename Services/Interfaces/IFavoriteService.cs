using marriage_hall_backend.DTOs.Favorites;

namespace marriage_hall_backend.Services.Interfaces
{
    public interface IFavoriteService
    {
        Task<FavoriteResponseDto> AddAsync(int customerId, int hallId);
        Task RemoveAsync(int customerId, int hallId);
        Task<List<FavoriteResponseDto>> GetForUserAsync(int customerId);
    }
}
