using marriage_hall_backend.DTOs.Reviews;

namespace marriage_hall_backend.Services.Interfaces
{
    public interface IReviewService
    {
        Task<ReviewResponseDto> CreateAsync(int customerId, CreateReviewDto dto);
        Task<List<ReviewResponseDto>> GetForHallAsync(int hallId);
    }
}
