using marriage_hall_backend.DTOs.Favorites;
using marriage_hall_backend.Helpers;
using marriage_hall_backend.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace marriage_hall_backend.Controllers
{
    [ApiController]
    [Route("api/favorites")]
    [Authorize(Roles = "Customer")]
    public class FavoritesController : ControllerBase
    {
        private readonly IFavoriteService _favoriteService;

        public FavoritesController(IFavoriteService favoriteService)
        {
            _favoriteService = favoriteService;
        }

        [HttpGet]
        public async Task<ActionResult<List<FavoriteResponseDto>>> GetMine()
            => Ok(await _favoriteService.GetForUserAsync(User.GetUserId()));

        [HttpPost("{hallId:int}")]
        public async Task<ActionResult<FavoriteResponseDto>> Add(int hallId)
            => Ok(await _favoriteService.AddAsync(User.GetUserId(), hallId));

        [HttpDelete("{hallId:int}")]
        public async Task<IActionResult> Remove(int hallId)
        {
            await _favoriteService.RemoveAsync(User.GetUserId(), hallId);
            return NoContent();
        }
    }
}
