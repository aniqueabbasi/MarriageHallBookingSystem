using marriage_hall_backend.DTOs.Auth;
using marriage_hall_backend.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace marriage_hall_backend.Controllers
{
    [ApiController]
    [Route("api/auth")]
    public class AuthController : ControllerBase
    {
        private readonly IAuthService _authService;

        public AuthController(IAuthService authService)
        {
            _authService = authService;
        }

        [HttpPost("register")]
        public async Task<ActionResult<TokenResponseDto>> Register(RegisterDto dto)
            => Ok(await _authService.RegisterAsync(dto));

        [HttpPost("login")]
        public async Task<ActionResult<TokenResponseDto>> Login(LoginDto dto)
            => Ok(await _authService.LoginAsync(dto));
    }
}
