using marriage_hall_backend.DTOs.Auth;
using marriage_hall_backend.DTOs.Bookings;
using marriage_hall_backend.DTOs.Halls;
using marriage_hall_backend.Models.Enums;
using marriage_hall_backend.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace marriage_hall_backend.Controllers
{
    [ApiController]
    [Route("api/admin")]
    [Authorize(Roles = "Admin")]
    public class AdminController : ControllerBase
    {
        private readonly IAdminService _adminService;

        public AdminController(IAdminService adminService)
        {
            _adminService = adminService;
        }

        [HttpGet("users")]
        public async Task<ActionResult<List<UserDto>>> GetUsers()
            => Ok(await _adminService.GetAllUsersAsync());

        [HttpPatch("users/{id:int}/role")]
        public async Task<ActionResult<UserDto>> ChangeUserRole(int id, [FromBody] UserRole role)
            => Ok(await _adminService.ChangeUserRoleAsync(id, role));

        [HttpGet("halls")]
        public async Task<ActionResult<List<HallListDto>>> GetHalls()
            => Ok(await _adminService.GetAllHallsAsync());

        [HttpGet("bookings")]
        public async Task<ActionResult<List<BookingResponseDto>>> GetBookings()
            => Ok(await _adminService.GetAllBookingsAsync());
    }
}
