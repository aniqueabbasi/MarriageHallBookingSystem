using marriage_hall_backend.DTOs.Halls;
using marriage_hall_backend.Helpers;
using marriage_hall_backend.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace marriage_hall_backend.Controllers
{
    [ApiController]
    [Route("api/halls")]
    public class HallsController : ControllerBase
    {
        private readonly IHallService _hallService;

        public HallsController(IHallService hallService)
        {
            _hallService = hallService;
        }

        [HttpGet]
        [AllowAnonymous]
        public async Task<ActionResult<List<HallListDto>>> Search([FromQuery] string? city, [FromQuery] int? minCapacity, [FromQuery] decimal? maxPrice)
            => Ok(await _hallService.SearchAsync(city, minCapacity, maxPrice));

        [HttpGet("{id:int}")]
        [AllowAnonymous]
        public async Task<ActionResult<HallDetailDto>> GetById(int id)
            => Ok(await _hallService.GetByIdAsync(id));

        [HttpGet("mine")]
        [Authorize(Roles = "HallOwner,Admin")]
        public async Task<ActionResult<List<HallListDto>>> GetMine()
            => Ok(await _hallService.GetByOwnerAsync(User.GetUserId()));

        [HttpPost]
        [Authorize(Roles = "HallOwner,Admin")]
        public async Task<ActionResult<HallDetailDto>> Create(CreateHallDto dto)
            => Ok(await _hallService.CreateAsync(User.GetUserId(), dto));

        [HttpPut("{id:int}")]
        [Authorize(Roles = "HallOwner,Admin")]
        public async Task<ActionResult<HallDetailDto>> Update(int id, UpdateHallDto dto)
            => Ok(await _hallService.UpdateAsync(id, User.GetUserId(), User.GetRole(), dto));

        [HttpDelete("{id:int}")]
        [Authorize(Roles = "HallOwner,Admin")]
        public async Task<IActionResult> Delete(int id)
        {
            await _hallService.DeleteAsync(id, User.GetUserId(), User.GetRole());
            return NoContent();
        }

        [HttpPost("{id:int}/images")]
        [Authorize(Roles = "HallOwner,Admin")]
        public async Task<ActionResult<HallImageDto>> AddImage(int id, CreateHallImageDto dto)
            => Ok(await _hallService.AddImageAsync(id, User.GetUserId(), User.GetRole(), dto));

        [HttpPost("{id:int}/food-packages")]
        [Authorize(Roles = "HallOwner,Admin")]
        public async Task<ActionResult<FoodPackageDto>> AddFoodPackage(int id, CreateFoodPackageDto dto)
            => Ok(await _hallService.AddFoodPackageAsync(id, User.GetUserId(), User.GetRole(), dto));

        [HttpPost("{id:int}/extra-services")]
        [Authorize(Roles = "HallOwner,Admin")]
        public async Task<ActionResult<ExtraServiceDto>> AddExtraService(int id, CreateExtraServiceDto dto)
            => Ok(await _hallService.AddExtraServiceAsync(id, User.GetUserId(), User.GetRole(), dto));

        [HttpPost("{id:int}/virtual-tours")]
        [Authorize(Roles = "HallOwner,Admin")]
        public async Task<ActionResult<VirtualTourDto>> AddVirtualTour(int id, CreateVirtualTourDto dto)
            => Ok(await _hallService.AddVirtualTourAsync(id, User.GetUserId(), User.GetRole(), dto));
    }
}
