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
        [Consumes("multipart/form-data")]
        public async Task<ActionResult<HallDetailDto>> Create([FromForm] CreateHallDto dto)
            => Ok(await _hallService.CreateAsync(User.GetUserId(), dto));

        [HttpPut("{id:int}")]
        [Authorize(Roles = "HallOwner,Admin")]
        [Consumes("multipart/form-data")]
        public async Task<ActionResult<HallDetailDto>> Update(int id, [FromForm] UpdateHallDto dto)
            => Ok(await _hallService.UpdateAsync(id, User.GetUserId(), User.GetRole(), dto));

        [HttpDelete("{id:int}")]
        [Authorize(Roles = "HallOwner,Admin")]
        public async Task<IActionResult> Delete(int id)
        {
            await _hallService.DeleteAsync(id, User.GetUserId(), User.GetRole());
            return NoContent();
        }

        [HttpDelete("{hallId:int}/food-packages/{packageId:int}")]
        [Authorize(Roles = "HallOwner,Admin")]
        public async Task<IActionResult> DeleteFoodPackage(int hallId, int packageId)
        {
            await _hallService.DeleteFoodPackageAsync(hallId, packageId, User.GetUserId(), User.GetRole());
            return NoContent();
        }

        [HttpDelete("{hallId:int}/extra-services/{serviceId:int}")]
        [Authorize(Roles = "HallOwner,Admin")]
        public async Task<IActionResult> DeleteExtraService(int hallId, int serviceId)
        {
            await _hallService.DeleteExtraServiceAsync(hallId, serviceId, User.GetUserId(), User.GetRole());
            return NoContent();
        }

        [HttpPost("{id:int}/virtual-tours")]
        [Authorize(Roles = "HallOwner,Admin")]
        public async Task<ActionResult<VirtualTourDto>> AddVirtualTour(int id, CreateVirtualTourDto dto)
            => Ok(await _hallService.AddVirtualTourAsync(id, User.GetUserId(), User.GetRole(), dto));

        [HttpDelete("{hallId:int}/virtual-tours/{tourId:int}")]
        [Authorize(Roles = "HallOwner,Admin")]
        public async Task<IActionResult> DeleteVirtualTour(int hallId, int tourId)
        {
            await _hallService.DeleteVirtualTourAsync(hallId, tourId, User.GetUserId(), User.GetRole());
            return NoContent();
        }
    }
}
