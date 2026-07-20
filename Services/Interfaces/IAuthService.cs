using marriage_hall_backend.DTOs.Auth;

namespace marriage_hall_backend.Services.Interfaces
{
    public interface IAuthService
    {
        Task<TokenResponseDto> RegisterAsync(RegisterDto dto);
        Task<TokenResponseDto> LoginAsync(LoginDto dto);
        Task ForgotPasswordAsync(ForgotPasswordDto dto);
        Task<VerifyResetOtpResponseDto> VerifyResetOtpAsync(VerifyResetOtpDto dto);
        Task ResetPasswordAsync(ResetPasswordDto dto);
    }
}
