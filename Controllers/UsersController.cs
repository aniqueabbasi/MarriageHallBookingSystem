using marriage_hall_backend.DTOs.Auth;
using marriage_hall_backend.DTOs.Users;
using marriage_hall_backend.Helpers;
using marriage_hall_backend.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace marriage_hall_backend.Controllers
{
    [ApiController]
    [Route("api/users")]
    [Authorize]
    public class UsersController : ControllerBase
    {
        private readonly IUserService _userService;

        public UsersController(IUserService userService)
        {
            _userService = userService;
        }

        [HttpGet("me")]
        public async Task<ActionResult<UserDto>> GetMe()
            => Ok(await _userService.GetMeAsync(User.GetUserId()));

        [HttpPut("me")]
        public async Task<ActionResult<UserDto>> UpdateMe(UpdateProfileDto dto)
            => Ok(await _userService.UpdateMeAsync(User.GetUserId(), dto));

        [HttpPut("me/cnic")]
        public async Task<ActionResult<CnicDetailsResponseDto>> SaveCnicDetails(CnicDetailsDto dto)
            => Ok(await _userService.SaveCnicDetailsAsync(User.GetUserId(), dto));
    }
}
