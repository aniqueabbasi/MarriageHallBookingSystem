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

        [HttpPost("refresh")]
        public async Task<ActionResult<TokenResponseDto>> Refresh(RefreshTokenRequestDto dto)
            => Ok(await _authService.RefreshTokenAsync(dto.RefreshToken));

        [HttpPost("revoke")]
        public async Task<IActionResult> Revoke(RefreshTokenRequestDto dto)
        {
            await _authService.RevokeRefreshTokenAsync(dto.RefreshToken);
            return NoContent();
        }
    }
}
