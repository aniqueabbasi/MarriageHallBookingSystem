using marriage_hall_backend.DTOs.Reviews;
using marriage_hall_backend.Helpers;
using marriage_hall_backend.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace marriage_hall_backend.Controllers
{
    [ApiController]
    [Route("api/reviews")]
    public class ReviewsController : ControllerBase
    {
        private readonly IReviewService _reviewService;

        public ReviewsController(IReviewService reviewService)
        {
            _reviewService = reviewService;
        }

        [HttpPost]
        [Authorize(Roles = "Customer")]
        public async Task<ActionResult<ReviewResponseDto>> Create(CreateReviewDto dto)
            => Ok(await _reviewService.CreateAsync(User.GetUserId(), dto));

        [HttpGet("hall/{hallId:int}")]
        [AllowAnonymous]
        public async Task<ActionResult<List<ReviewResponseDto>>> GetForHall(int hallId)
            => Ok(await _reviewService.GetForHallAsync(hallId));
    }
}
